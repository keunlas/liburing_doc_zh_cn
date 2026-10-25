---
title: io_uring_prep_recv
section: 3
source_path: man/io_uring_prep_recv.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 5d8aa03c86c124ee6ce040994705dcea41d7d663dec2c44ad0204b9dbc4c3de6
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_recv(3)

## 名称

io_uring_prep_recv - 准备一个 recv 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_recv(struct io_uring_sqe *sqe,
                        int sockfd,
                        void *buf,
                        size_t len,
                        int flags);

void io_uring_prep_recv_multishot(struct io_uring_sqe *sqe,
                                  int sockfd,
                                  void *buf,
                                  size_t len,
                                  int flags);
```

## 描述

[io_uring_prep_recv(3)](io_uring_prep_recv.3.md) 函数准备一个 recv 请求。提交队列项
`sqe` 会被设置为使用文件描述符 `sockfd`，开始将数据接收到大小为 `len` 的目标缓冲区
`buf` 中，并使用修饰标志 `flags`。

此函数准备一个异步
[recv(2)](https://man7.org/linux/man-pages/man2/recv.2.html) 请求。有关传给此 prep
辅助函数各参数的详情，请参见该手册页。

多轮触发版本允许应用发出一个接收请求，并在数据可用时反复发布 CQE。长度可以设置为
0，此时单次接收调用可以传输的数据量没有限制；也可以设置为正值。如果采用后一种设置，
那么多轮触发接收的每次触发调用最多传输 `len` 字节。当环在不同套接字上处理许多多轮
触发接收操作时，特别是与捆绑配合使用时，这有助于确保它们之间的公平性。必须设置
`IOSQE_BUFFER_SELECT` 标志，并且不得设置 `MSG_WAITALL` 标志。因此，每个 CQE 都会
从提供的缓冲区池中取出一个缓冲区用于接收。应用应检查每个 CQE 的标志，而不论其结果
如何。如果已发布的 CQE 未设置 `IORING_CQE_F_MORE` 标志，则多轮触发接收已经结束；
如果应用仍希望从该套接字接收数据，就必须发出新请求。多轮触发变体自内核 6.0 起可用。

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

- `IORING_RECVSEND_BUNDLE`：如果设置，并且通过 `IOSQE_BUFFER_SELECT` 使用提供的
  缓冲区，则接收操作会尝试填充多个缓冲区，而不只是选择单个缓冲区进行填充。要在一次
  接收中接收多个缓冲区，SQE 中设置的缓冲区组 ID 必须属于环提供的类型。如果设置，
  CQE 的 `res` 字段表示接收的总字节数，CQE 的 `flags` 字段中返回的缓冲区 ID 表示
  此次接收操作中的第一个缓冲区。应用必须处理所指示的起始缓冲区 ID，并一直处理到
  已覆盖全部 `res` 字节，才能知道此次接收操作中的最后一个缓冲区。被消费的缓冲区从
  起始缓冲区开始，按照它们在缓冲区环中出现的顺序连续排列。CQE 结构体不包含缓冲区
  在缓冲区环中的位置，因此为了识别捆绑中包含的缓冲区，建议为每个缓冲区环维护一个
  缓存头索引。这个 `uint16_t` 索引表示环内下一个待消费缓冲区的位置。接收操作完成
  后，应相应地递增缓存头索引。当有多个数据块可接收时，捆绑接收可以避免通过网络栈的
  冗余往返，从而提高性能。单次触发和多轮触发接收操作都可以使用捆绑接收。请注意，
  捆绑在内部依赖网络栈返回初始接收后套接字中还剩余多少数据。这意味着初始接收所包含
  的缓冲区可能少于可用数量，其后的接收操作会包含更多缓冲区。自 6.10 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

尽管这些函数接受以字节数表示的 `size_t` 参数，但每次调用最多只能传输 `INT_MAX`
字节（底层系统调用接口的最大值）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_buf_ring_init(3)](io_uring_buf_ring_init.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [recv(2)](https://man7.org/linux/man-pages/man2/recv.2.html)
