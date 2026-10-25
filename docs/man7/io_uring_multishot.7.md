---
title: io_uring_multishot
section: 7
source_path: man/io_uring_multishot.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: eee1231692b366b2947c110626905651b94991a512c7679000089f841fab6339
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_multishot(7)

## 名称

io_uring_multishot - io_uring 多轮触发请求概览

## 描述

多轮触发请求是一类 io_uring 操作，其中单个提交队列项（SQE）可以生成多个完成队列项
（CQE）。这与普通“单次触发”操作相反；普通操作中每个 SQE 恰好生成一个 CQE。

### 为什么使用多轮触发请求？

传统 I/O 操作需要为每次操作提交新请求。对于接受连接或接收数据等高频操作，这会产生
开销：准备和提交 SQE 的 CPU 周期、SQE/CQE 处理的内存带宽，以及完成事件与新提交之间
可能出现间隙。

多轮触发请求在每次完成后仍保持操作活动，从而消除此开销。内核会自动重新启用操作，
当下一个事件发生时生成新 CQE。此外，该请求的内部轮询机制会持续存在，无需每次操作都
操作轮询状态。

多轮触发操作最适合网络服务器接受大量连接、长连接接收数据、使用 poll 监控事件，以及
任何重复相同操作的场景。

### 多轮触发如何工作

多轮触发操作完成时，CQE 的 `cqe->flags` 中会设置 `IORING_CQE_F_MORE`。这表示操作
仍然活动，后续还会有完成事件。操作会持续到发生错误（最终 CQE 不再设置
`IORING_CQE_F_MORE`）、操作被显式取消，或满足操作特定的终止条件（例如接收操作耗尽
缓冲区）。

多轮触发操作的最终 CQE 不会设置 `IORING_CQE_F_MORE`，表示操作已终止。

### 多轮触发 accept

[io_uring_prep_multishot_accept(3)](../man3/io_uring_prep_accept.3.md) 和
[io_uring_prep_multishot_accept_direct(3)](../man3/io_uring_prep_accept.3.md) 设置
多轮触发 accept 操作。每个传入连接都会生成一个 CQE，新文件描述符位于 `cqe->res`。

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_multishot_accept(sqe, listen_fd, NULL, NULL, 0);
```

操作会持续接受连接，直到发生错误或被取消。使用带 `IORING_FILE_INDEX_ALLOC` 的直接
变体，可将接受的套接字直接放入固定文件表。

### 多轮触发接收

[io_uring_prep_recv_multishot(3)](../man3/io_uring_prep_recv.3.md) 设置多轮触发接收
操作。每当套接字收到数据时都会生成 CQE。通常与提供的缓冲区一起使用（参见
[io_uring_provided_buffers(7)](io_uring_provided_buffers.7.md)）：

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_recv_multishot(sqe, sockfd, NULL, 0, 0);
sqe->buf_group = bgid;
sqe->flags |= IOSQE_BUFFER_SELECT;
```

每个完成事件包含：如果后续还有完成事件则设置 `IORING_CQE_F_MORE`；选择缓冲区时设置
`IORING_CQE_F_BUFFER`；缓冲区 ID 位于 `cqe->flags` 高位；接收字节数位于 `cqe->res`。

多轮触发接收在发生错误、连接关闭或缓冲区环耗尽时终止。

### 多轮触发 recvmsg

[io_uring_prep_recvmsg_multishot(3)](../man3/io_uring_prep_recvmsg.3.md) 与多轮触发
接收类似，但使用 `msghdr` 结构进行散布/聚集 I/O 和辅助数据处理。每条消息使用一个提供
的缓冲区，内核会在缓冲区开头写入 `struct io_uring_recvmsg_out` 头，其中包含实际消息
参数。

### 多轮触发读取

[io_uring_prep_read_multishot(3)](../man3/io_uring_prep_read_multishot.3.md) 设置
多轮触发读取操作，通常用于管道或其他面向流的文件描述符。与多轮触发接收一样，它使用
提供的缓冲区：

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_read_multishot(sqe, fd, 0, 0, bgid);
```

每次有可读数据时，该操作都会生成 CQE。

### 多轮触发 poll

[io_uring_prep_poll_multishot(3)](../man3/io_uring_prep_poll_add.3.md) 设置多轮触发
poll 操作，也可以手动设置 `IORING_POLL_ADD_MULTI` 标志：

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_poll_multishot(sqe, fd, POLLIN);
/* 或者等价地： */
io_uring_prep_poll_add(sqe, fd, POLLIN);
sqe->len |= IORING_POLL_ADD_MULTI;
```

每当被轮询条件成立时都会生成 CQE，触发的事件位于 `cqe->res`。与触发后会自动移除的
单次触发 poll 不同，多轮触发 poll 会保持活动。

对于水平触发事件，应用应确保在下一次 poll 完成前处理该事件（例如读取所有可用数据），
否则可能出现伪唤醒。

### 多轮触发 waitid

[io_uring_prep_waitid(3)](../man3/io_uring_prep_waitid.3.md) 可以通过在 flags 中设置
`IORING_ACCEPT_MULTISHOT` 以多轮触发模式运行，从而使用单个 SQE 等待多个子进程状态
变化。

### 处理多轮触发完成事件

应用必须检查 `IORING_CQE_F_MORE` 以确定操作是否仍然活动：

```c
struct io_uring_cqe *cqe;

while (io_uring_peek_cqe(ring, &cqe) == 0) {
    if (cqe->res < 0) {
        /* 发生错误，操作已终止 */
        handle_error(cqe->res);
    } else {
        process_completion(cqe);
    }

    if (!(cqe->flags & IORING_CQE_F_MORE)) {
        /* 操作已终止，可能需要重新提交 */
        rearm_if_needed();
    }

    io_uring_cqe_seen(ring, cqe);
}
```

### 取消多轮触发操作

可以使用 [io_uring_prep_cancel(3)](../man3/io_uring_prep_cancel.3.md) 或相关函数取消
多轮触发操作。取消请求会生成自己的 CQE，多轮触发操作会生成最终 CQE（通常为
`-ECANCELED`），且不设置 `IORING_CQE_F_MORE`。

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_cancel64(sqe, user_data, 0);
```

### 与提供的缓冲区集成

多轮触发接收和读取操作设计为与提供的缓冲区环一起使用（参见
[io_uring_provided_buffers(7)](io_uring_provided_buffers.7.md)）。每个完成事件从环中
消费一个缓冲区，应用必须将缓冲区归还到环中，以维持操作运行。

如果缓冲区环耗尽，多轮触发操作会以 `-ENOBUFS` 终止。应用应确保有足够缓冲区，并及时
将已用缓冲区归还到环中。

## 注意事项

- 始终检查 `IORING_CQE_F_MORE`，以了解多轮触发操作是否仍在活动。
- 多轮触发操作可能快速生成大量 CQE。确保 CQ 环足够大，以避免溢出。
- 对多轮触发接收使用提供的缓冲区时，应监控缓冲区可用量，防止过早终止。
- 从概念上说，多轮触发操作是边沿触发的：它们会在事件发生时生成完成事件，而不是在条件
  持续成立时不断生成。
- 多轮触发操作的错误完成事件不会设置 `IORING_CQE_F_MORE`，表示已经终止。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_provided_buffers(7)](io_uring_provided_buffers.7.md)
- [io_uring_prep_multishot_accept(3)](../man3/io_uring_prep_accept.3.md)
- [io_uring_prep_recv_multishot(3)](../man3/io_uring_prep_recv.3.md)
- [io_uring_prep_recvmsg_multishot(3)](../man3/io_uring_prep_recvmsg.3.md)
- [io_uring_prep_read_multishot(3)](../man3/io_uring_prep_read_multishot.3.md)
- [io_uring_prep_poll_add(3)](../man3/io_uring_prep_poll_add.3.md)
- [io_uring_prep_poll_multishot(3)](../man3/io_uring_prep_poll_add.3.md)
- [io_uring_prep_cancel(3)](../man3/io_uring_prep_cancel.3.md)
