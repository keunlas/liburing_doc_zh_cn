---
title: io_uring_linked_requests
section: 7
source_path: man/io_uring_linked_requests.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 109dc4fa876e7863b3041ef0915bc53100972cc0c133581f175bcb848160358a
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_linked_requests(7)

## 名称

io_uring_linked_requests - io_uring 链接请求概览

## 描述

链接请求允许应用将多个 io_uring 操作串联起来，在它们之间建立依赖关系。请求链接后
会顺序执行，而不是并发执行；链中每个请求只会在前一个请求完成后开始。

### 为什么使用链接请求？

普通 io_uring 提交相互独立，可能以任意顺序或并发执行。但有些操作存在自然依赖：

- 从一个文件读取，然后写入另一个文件。
- 连接服务器，然后发送请求。
- 接受连接，然后接收数据。
- 带超时执行操作。

如果不使用链接，应用必须等待完成事件，再手动提交后续请求。链接请求允许一次提交整条链，
从而减少用户空间与内核之间的往返。

链接请求最适合操作必须按特定顺序执行、后续操作依赖先前操作成功、需要为操作附加超时，
或者降低提交延迟很重要的情况。

### 创建链接请求

通过在请求上设置 `IOSQE_IO_LINK` 标志来建立链接。它将请求链接到提交顺序中的下一个
请求。链会一直延续到遇到不带链接标志的请求为止。

```c
struct io_uring_sqe *sqe;

/* 链中的第一个请求 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_read(sqe, fd_in, buf, len, 0);
sqe->flags |= IOSQE_IO_LINK;

/* 第二个请求，链接到第一个请求 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_write(sqe, fd_out, buf, len, 0);
sqe->flags |= IOSQE_IO_LINK;

/* 第三个请求，链尾（不带链接标志） */
sqe = io_uring_get_sqe(ring);
io_uring_prep_fsync(sqe, fd_out, 0);

io_uring_submit(ring);
```

在此示例中，读取先完成，然后写入，最后执行 fsync。每个操作都会等待前一个操作完成后
再开始。

### 软链接与硬链接

链接有两种类型，区别在于错误处理方式：

- 软链接（`IOSQE_IO_LINK`）：如果链中某个请求失败（返回负错误码），链中所有后续请求
  都会以 `-ECANCELED` 取消。当后续操作依赖先前操作成功时，这很有用。
- 硬链接（`IOSQE_IO_HARDLINK`）：即使某个请求失败，链仍继续执行。每个请求无论先前
  请求结果如何都会运行。当希望即使某些操作失败也尝试全部操作时，这很有用。

```c
/* 软链接：读取失败时取消写入 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_read(sqe, fd, buf, len, 0);
sqe->flags |= IOSQE_IO_LINK;

sqe = io_uring_get_sqe(ring);
io_uring_prep_write(sqe, fd2, buf, len, 0);

/* 硬链接：即使读取失败也执行写入 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_read(sqe, fd, buf, len, 0);
sqe->flags |= IOSQE_IO_HARDLINK;

sqe = io_uring_get_sqe(ring);
io_uring_prep_write(sqe, fd2, buf, len, 0);
```

### 链接超时

链接请求的一个常见用途是为操作添加超时。`IORING_OP_LINK_TIMEOUT` 操作（由
[io_uring_prep_link_timeout(3)](../man3/io_uring_prep_link_timeout.3.md) 设置）专为
此设计：

```c
struct __kernel_timespec ts = { .tv_sec = 5, .tv_nsec = 0 };

/* 需要计时的操作 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_read(sqe, fd, buf, len, 0);
sqe->flags |= IOSQE_IO_LINK;

/* 链接到读取操作的超时 */
sqe = io_uring_get_sqe(ring);
io_uring_prep_link_timeout(sqe, &ts, 0);

io_uring_submit(ring);
```

如果读取在超时前完成：读取 CQE 包含实际结果，超时 CQE 包含 `-ECANCELED`。

如果超时先到期：读取 CQE 包含 `-ECANCELED`（如果当时仍在进行中，则为 `-EINTR`），
超时 CQE 包含 `-ETIME`。

链接超时仅适用于链中紧邻其前的请求。要为整条链设置超时，必须将超时链接到最后一个操作
之后。

### 完成顺序

链中每个请求都会生成自己的 CQE。链接请求的完成事件按顺序排列——链中较早请求的 CQE
会在较晚请求的 CQE 之前发布。应用处理完成事件时可以依赖此顺序。不过，如果还有其他
未链接请求在途，它们的完成事件可能与链的完成事件交错。

### 错误处理

对于软链接链，错误处理很直接：检查每个 CQE 的结果；如果某请求失败，所有后续请求都将
为 `-ECANCELED`；第一个未取消的错误表示链在哪里断开。

```c
/* 处理一条链接链的完成事件 */
for (int i = 0; i < chain_length; i++) {
    io_uring_wait_cqe(ring, &cqe);

    if (cqe->res == -ECANCELED) {
        /* 链中先前的请求失败 */
    } else if (cqe->res < 0) {
        /* 此请求失败，导致链断开 */
        handle_error(cqe->res);
    } else {
        /* 成功 */
        handle_success(cqe->res);
    }

    io_uring_cqe_seen(ring, cqe);
}
```

### 常见模式

带同步的复制：读取数据、写入别处，然后同步：

```c
io_uring_prep_read(sqe1, src_fd, buf, len, 0);
sqe1->flags |= IOSQE_IO_LINK;

io_uring_prep_write(sqe2, dst_fd, buf, len, 0);
sqe2->flags |= IOSQE_IO_LINK;

io_uring_prep_fsync(sqe3, dst_fd, 0);
```

带超时连接：

```c
io_uring_prep_connect(sqe1, sockfd, addr, addrlen);
sqe1->flags |= IOSQE_IO_LINK;

io_uring_prep_link_timeout(sqe2, &timeout, 0);
```

连接后发送：

```c
io_uring_prep_connect(sqe1, sockfd, addr, addrlen);
sqe1->flags |= IOSQE_IO_LINK;

io_uring_prep_send(sqe2, sockfd, data, len, 0);
```

## 注意事项

- 链接请求必须在同一次 [io_uring_submit(3)](../man3/io_uring_submit.3.md) 调用中一起
  提交。链由提交顺序中 SQE 的顺序定义。
- 链中最后一个请求上的链接标志会被忽略（它没有可链接的对象）。
- 链可以任意长，仅受 SQ 环大小限制。
- 同一条链中允许混用 `IOSQE_IO_LINK` 和 `IOSQE_IO_HARDLINK`。每条链接的类型决定该
  特定请求失败时会发生什么。
- 如果设置了 `personality`，链接请求共享同一个身份凭据，因此凭据会沿链继承。
- 如果链中某个请求被取消（例如通过
  [io_uring_prep_cancel(3)](../man3/io_uring_prep_cancel.3.md)），链会像该请求失败
  一样断开。
- 链接请求有性能影响：它们强制顺序执行，阻止内核优化或并行化操作。仅在需要顺序时
  使用链接。对于独立操作，不链接提交可让内核并发执行或重新排序以获得更好性能。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_prep_link_timeout(3)](../man3/io_uring_prep_link_timeout.3.md)
- [io_uring_prep_cancel(3)](../man3/io_uring_prep_cancel.3.md)
- [io_uring_sqe_set_flags(3)](../man3/io_uring_sqe_set_flags.3.md)
