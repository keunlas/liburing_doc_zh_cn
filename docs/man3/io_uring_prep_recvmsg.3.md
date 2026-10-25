---
title: io_uring_prep_recvmsg
section: 3
source_path: man/io_uring_prep_recvmsg.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 473ffde5efbcd668075f9482ab9f9633194a501e615395769d704dc1e0cf7ff1
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_recvmsg(3)

## 名称

io_uring_prep_recvmsg - 准备一个 recvmsg 请求

## 概要

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_recvmsg(struct io_uring_sqe *sqe,
                           int fd,
                           struct msghdr *msg,
                           unsigned flags);

void io_uring_prep_recvmsg_multishot(struct io_uring_sqe *sqe,
                                     int fd,
                                     struct msghdr *msg,
                                     unsigned flags);
```

## 描述

[io_uring_prep_recvmsg(3)](io_uring_prep_recvmsg.3.md) 函数准备一个 recvmsg 请求。
提交队列项 `sqe` 会被设置为使用文件描述符 `fd`，开始接收由 `msg` 指示的数据，并在
`flags` 参数中使用
[recvmsg(2)](https://man7.org/linux/man-pages/man2/recvmsg.2.html) 定义的标志。

此函数准备一个异步
[recvmsg(2)](https://man7.org/linux/man-pages/man2/recvmsg.2.html) 请求。有关传给
此 prep 辅助函数各参数的详情，请参见该手册页。

多轮触发版本允许应用发出一个接收请求，并在数据可用时反复发布 CQE。它要求设置
`IOSQE_BUFFER_SELECT` 标志，并且不得设置 `MSG_WAITALL` 标志。因此，每个 CQE 都会
从提供的缓冲区池中取出一个缓冲区用于接收。应用应检查每个 CQE 的标志，而不论其结果
如何。如果已发布的 CQE 未设置 `IORING_CQE_F_MORE` 标志，则多轮触发接收已经结束；
如果应用仍希望从该套接字接收数据，就必须发出新请求。

与
[recvmsg(2)](https://man7.org/linux/man-pages/man2/recvmsg.2.html) 不同，多轮触发
recvmsg 会前置一个 `struct io_uring_recvmsg_out`，该结构体会结合请求中提交的初始
`struct msghdr` 描述缓冲区其余部分的布局。有关访问数据的更多信息，请参见
[io_uring_recvmsg_out(3)](io_uring_recvmsg_out.3.md)。

多轮触发变体自内核 6.0 起可用。

调用此函数后，还可以在 SQE 的 `ioprio` 字段中设置额外的 io_uring 内部修饰标志。
支持以下标志：

- `IORING_RECVSEND_POLL_FIRST`：如果设置，io_uring 将假定套接字当前为空，尝试接收
  数据将不会成功。在这种情况下，io_uring 会设置内部轮询，并在套接字有数据可读时触发
  数据接收。对于预期套接字为空的情况，最初的接收尝试可能造成浪费；设置此标志会绕过
  最初的接收尝试，直接设置轮询。如果轮询确实表明数据已准备好接收，则操作会继续。

  此标志可以与 CQE 的 `IORING_CQE_F_SOCK_NONEMPTY` 标志配合使用；io_uring 会在
  [recv(2)](https://man7.org/linux/man-pages/man2/recv.2.html) 或
  [recvmsg(2)](https://man7.org/linux/man-pages/man2/recvmsg.2.html) 操作完成后的 CQE
  上设置该标志。如果设置了该标志，则表示操作完成后套接字中仍有数据可读。这两个标志
  均自 5.19 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

尽管这些函数接受一个 iovec 数组，其中每个 iovec 的字节数为 `size_t`，但每次调用
最多只能传输 `INT_MAX` 字节（底层系统调用接口的最大值）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_buf_ring_init(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_buf_ring_init.3)
- [io_uring_buf_ring_add(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_buf_ring_add.3)
- [recvmsg(2)](https://man7.org/linux/man-pages/man2/recvmsg.2.html)
