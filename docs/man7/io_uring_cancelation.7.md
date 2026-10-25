---
title: io_uring_cancelation
section: 7
source_path: man/io_uring_cancelation.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b4b3b508a88bad2fc5896900b9cadbb81e9a00d444d612f02d58945f7a85166d
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cancelation(7)

## 名称

io_uring_cancelation - io_uring 请求取消概览

## 描述

io_uring 提供在途请求自然完成前将其取消的机制。这适用于实现超时、处理连接断开、关闭
已消失的连接，或者不再需要某请求的场景。

### 为什么要取消请求？

常见场景包括：超时（取消等待过久的读取或 accept）、连接管理（连接关闭时取消待处理
操作）、资源清理（取消正在关闭文件描述符上的操作），以及终止不再需要的多轮触发操作。

### 基本取消

主要取消机制是 `IORING_OP_ASYNC_CANCEL`（由
[io_uring_prep_cancel(3)](../man3/io_uring_prep_cancel.3.md) 或相关函数设置）。默认
情况下，它取消匹配特定 `user_data` 的请求：

```c
/* 提交 user_data = 1234 的读取请求 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_read(sqe, fd, buf, len, 0);
io_uring_sqe_set_data64(sqe, 1234);
io_uring_submit(ring);

/* 稍后取消该请求 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_cancel64(sqe, 1234, 0);
io_uring_submit(ring);
```

### 取消结果

提交取消操作时会生成两个 CQE。

被取消请求的 CQE：`res` 设置为 `-ECANCELED`（如果操作已经在进行，偶尔为 `-EINTR`）；
`user_data` 标识哪个请求被取消。

取消请求自身的 CQE：成功（找到并取消请求）时 `res` 为 0；没有匹配请求时为 `-ENOENT`；
找到但请求已在完成过程中时为 `-EALREADY`。

这两个 CQE 的顺序没有保证。应用可能在目标请求 CQE 之前或之后收到取消 CQE。

### 取消标志

- `IORING_ASYNC_CANCEL_ALL`：取消所有匹配请求，而不只是第一个。取消 CQE 的 `res`
  表示取消了多少个请求。
- `IORING_ASYNC_CANCEL_FD`：按文件描述符而不是 `user_data` 匹配请求，取消指定 fd 上
  的操作：

```c
io_uring_prep_cancel_fd(sqe, fd, IORING_ASYNC_CANCEL_FD);
```

- `IORING_ASYNC_CANCEL_ANY`：取消任意单个请求，忽略 `user_data` 匹配。与
  `IORING_ASYNC_CANCEL_ALL` 结合可排空环中的所有待处理请求。
- `IORING_ASYNC_CANCEL_FD_FIXED`：文件描述符是固定文件（已注册文件索引），而不是普通
  fd。

标志可以组合：

```c
/* 取消特定 fd 上的所有请求 */
io_uring_prep_cancel_fd(sqe, fd,
    IORING_ASYNC_CANCEL_FD | IORING_ASYNC_CANCEL_ALL);

/* 取消环中所有待处理请求 */
io_uring_prep_cancel(sqe, NULL,
    IORING_ASYNC_CANCEL_ANY | IORING_ASYNC_CANCEL_ALL);
```

### 竞态条件

取消本质上存在竞态。在提交取消请求到内核处理它之间，目标请求可能成功完成、因其他原因
失败，或已经进入不可取消状态。应用必须处理这些情况：

```c
io_uring_wait_cqe(ring, &cqe);

if (cqe->user_data == cancel_user_data) {
    /* 这是取消操作的结果 */
    if (cqe->res == -ENOENT) {
        /* 请求已完成或未找到 */
    } else if (cqe->res == -EALREADY) {
        /* 请求已找到但正在完成 */
    } else if (cqe->res >= 0) {
        /* 成功取消了 res 个请求 */
    }
} else {
    /* 这是原请求的结果 */
    if (cqe->res == -ECANCELED) {
        /* 请求已被取消 */
    } else {
        /* 请求正常完成（或发生错误） */
    }
}
```

### 链接超时

若要为单个操作设置超时，链接超时通常比显式取消更简单。详情请参见
[io_uring_linked_requests(7)](io_uring_linked_requests.7.md)：

```c
sqe = io_uring_get_sqe(ring);
io_uring_prep_read(sqe, fd, buf, len, 0);
sqe->flags |= IOSQE_IO_LINK;

sqe = io_uring_get_sqe(ring);
io_uring_prep_link_timeout(sqe, &timeout, 0);
```

超时到期时，内核会自动处理取消。

### 取消多轮触发请求

多轮触发请求（参见 [io_uring_multishot(7)](io_uring_multishot.7.md)）会持续生成完成
事件，直到被取消或发生错误。

```c
/* 取消多轮触发 accept */
io_uring_prep_cancel64(sqe, accept_user_data, 0);
```

取消后，多轮触发操作会生成最终 CQE，其中包含 `-ECANCELED`，且最终 CQE 不设置
`IORING_CQE_F_MORE`；取消 CQE 表示取消成功。

### 按文件描述符取消

文件描述符关闭时（通过 [close(2)](https://man7.org/linux/man-pages/man2/close.2.html)
或 `IORING_OP_CLOSE`），该 fd 上的待处理请求**不会**自动取消。这与同步 I/O 行为不同，
也是常见的混淆来源。

同步 I/O 中，关闭 fd 通常是底层文件的最后一个引用，因此关闭会完成待处理操作。但
io_uring 会为每个待处理请求持有自己的文件引用。关闭应用的 fd 不会释放这些引用——待处理
的 read、recv 或其他操作仍持有引用，不会自动完成或失败。

如果应用期望关闭 fd 后待处理读取会发布完成事件，这种期望并不成立。必须显式取消请求：

```c
/* 关闭前取消 fd 上的所有操作 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_cancel_fd(sqe, fd,
    IORING_ASYNC_CANCEL_FD | IORING_ASYNC_CANCEL_ALL);
io_uring_submit(ring);

/* 等待取消完成，然后关闭 */
```

### 关闭时取消

关闭 io_uring 实例时（通过
[io_uring_queue_exit(3)](../man3/io_uring_queue_exit.3.md) 或关闭环文件描述符），所有
待处理请求都会自动取消。关闭前无需手动取消。但是，如果应用需要在继续之前确保所有请求
完成（例如处理结果或释放相关资源），可以使用显式取消：

```c
/* 取消所有请求 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_cancel(sqe, NULL,
    IORING_ASYNC_CANCEL_ANY | IORING_ASYNC_CANCEL_ALL);
io_uring_submit(ring);

/* 等待所有 CQE */
while (pending_count > 0) {
    io_uring_wait_cqe(ring, &cqe);
    pending_count--;
    io_uring_cqe_seen(ring, cqe);
}
```

### 同步取消

如果应用需要通过一次阻塞调用取消请求并等待取消完成，
[io_uring_register_sync_cancel(3)](../man3/io_uring_register_sync_cancel.3.md) 提供
同步接口：

```c
struct io_uring_sync_cancel_reg reg = {
    .addr = user_data,
    .timeout.tv_sec = 5,
};

ret = io_uring_register_sync_cancel(ring, &reg);
```

它会阻塞到匹配请求被取消或超时。当应用不容易把异步取消集成到事件循环时很有用。

## 注意事项

- 并非所有操作都可取消。已经提交到硬件的操作（例如正在进行的磁盘 I/O）通常无法取消。
- 取消是异步的，取消请求本身可能需要时间才能完成。
- 使用 `IORING_ASYNC_CANCEL_ALL` 时，取消 CQE 的 `res` 包含取消请求数量。
- 固定文件可以通过 `IORING_ASYNC_CANCEL_FD_FIXED` 使用文件索引（而非普通 fd）取消。
- poll 操作和多轮触发请求通常适合取消；已完成的磁盘 I/O 不适合。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_linked_requests(7)](io_uring_linked_requests.7.md)
- [io_uring_multishot(7)](io_uring_multishot.7.md)
- [io_uring_prep_cancel(3)](../man3/io_uring_prep_cancel.3.md)
- [io_uring_prep_cancel64(3)](../man3/io_uring_prep_cancel.3.md)
- [io_uring_prep_cancel_fd(3)](../man3/io_uring_prep_cancel.3.md)
- [io_uring_prep_link_timeout(3)](../man3/io_uring_prep_link_timeout.3.md)
- [io_uring_register_sync_cancel(3)](../man3/io_uring_register_sync_cancel.3.md)
