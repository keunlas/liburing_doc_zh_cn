---
title: io_uring_prep_send
section: 3
source_path: man/io_uring_prep_send.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: ff72b86c9b9381c10b85473685a97e23232b28f7a04f06cd5c5bf7318ca82ddf
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_send(3)

## 名称

io_uring_prep_send - 准备一个 send 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_send(struct io_uring_sqe *sqe,
                        int sockfd,
                        const void *buf,
                        size_t len,
                        int flags);

void io_uring_prep_sendto(struct io_uring_sqe *sqe,
                          int sockfd,
                          const void *buf,
                          size_t len,
                          int flags,
                          const struct sockaddr *addr,
                          socklen_t addrlen);

void io_uring_prep_send_bundle(struct io_uring_sqe *sqe,
                               int sockfd,
                               size_t len,
                               int flags);
```

## 描述

[io_uring_prep_send(3)](io_uring_prep_send.3.md) 函数准备一个 send 请求。提交队列项
`sqe` 会被设置为使用文件描述符 `sockfd`，开始发送缓冲区 `buf` 中大小为 `len` 字节
的数据，并使用修饰标志 `flags`。

调用此函数后，还可以在 SQE 的 `ioprio` 字段中设置额外的 io_uring 内部修饰标志。
支持以下标志：

- `IORING_RECVSEND_POLL_FIRST`：如果设置，io_uring 将假定套接字当前已满，尝试发送
  数据将不会成功。在这种情况下，io_uring 会设置内部轮询，并在套接字有可用空间时触发
  数据发送。如果轮询确实表明套接字中有可用空间，则操作会立即继续。

- `IORING_RECVSEND_BUNDLE`：如果设置，发送操作会尝试使用多个缓冲区，而不只是选择
  单个缓冲区进行发送。要在一次 send 中发送多个缓冲区，SQE 中设置的缓冲区组 ID 必须
  属于环提供的类型。如果设置，CQE 的 `res` 字段表示发送的总字节数，CQE 的 `flags`
  字段中返回的缓冲区 ID 表示此次发送操作中的第一个缓冲区。应用必须处理所指示的起始
  缓冲区 ID，并一直处理到已覆盖全部 `res` 字节，才能知道此次发送操作中的最后一个
  缓冲区。被消费的缓冲区从起始缓冲区开始，按照它们在缓冲区环中出现的顺序连续排列。
  CQE 结构体不包含缓冲区在缓冲区环中的位置，因此为了识别捆绑中包含的缓冲区，建议为
  每个缓冲区环维护一个缓存头索引。这个 `uint16_t` 索引表示环内下一个待消费缓冲区的
  位置。捆绑发送操作完成后，应相应地递增缓存头索引。当有多个数据块可用时，捆绑发送
  可以避免通过网络栈的冗余往返，从而提高性能。

- `IORING_SEND_VECTORIZED`：如果设置，`addr` 必须指向 `struct iovec` 数组，并且
  `len` 必须是该数组中的向量数量。这使得普通 send 操作也可以使用向量 I/O，而无需
  借助 sendmsg 变体完成该操作。

请注意，对此请求类型使用 `IOSQE_IO_LINK` 时，需要在 `flags` 参数中设置
`MSG_WAITALL`，因为在未设置该项的情况下，短发送不会被视为错误情况。

此函数准备一个异步
[send(2)](https://man7.org/linux/man-pages/man2/send.2.html) 请求。详情请参见该
手册页。

[io_uring_prep_sendto(3)](io_uring_prep_send.3.md) 函数准备一个 sendto 请求。提交
队列项 `sqe` 会被设置为使用文件描述符 `sockfd`，开始发送缓冲区 `buf` 中大小为
`len` 字节的数据，并使用修饰标志 `flags`。目标地址由 `addr` 和 `addrlen` 指定，并且
必须是适用于该套接字类型的有效地址。

此函数准备一个异步
[sendto(2)](https://man7.org/linux/man-pages/man2/sendto.2.html) 请求。详情请参见
该手册页。

上述两个发送变体都可以使用提供的缓冲区。此时不直接随请求传入缓冲区，而是在 SQE 的
`flags` 字段中设置 `IOSQE_BUFFER_SELECT`，并另外在 SQE 的 `buf_group` 字段中设置
缓冲区组 ID。对发送请求使用提供的缓冲区，可以防止同一套接字上有多个在途发送请求时
可能发生的数据发送顺序重排。这样能够更好地流水化数据，而以前应用必须手动串行化
发送。

捆绑版本允许应用发出一个 send 请求，并在 SQE 的 `buf_group` 字段中给出缓冲区组 ID，
该请求会持续从该缓冲区组发送，直到缓冲区耗尽。与任何其他使用提供的缓冲区的请求一样，
提交前还必须在 SQE 的 `flags` 中设置 `IOSQE_BUFFER_SELECT`。目前 `len` 必须设置为
`0`，否则请求将以 `-EINVAL` 作为结果代码而失败。未来版本可能允许设置 `len` 以限制
传输大小。成功时，会为该发送发布一个 CQE，其结果是已发送的字节数。使用提供的缓冲区
时，send 或 send 捆绑会在 CQE 的 `flags` 字段中包含起始缓冲区组 ID。发送的字节数从
该处开始，并在此后使用连续的缓冲区 ID。捆绑发送以及一般情况下使用提供的缓冲区进行
发送自内核 6.10 起可用，还可以通过检查使用
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 设置环时返回的
`IORING_FEAT_SEND_BUF_SELECT` 标志来进一步识别。

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
- [send(2)](https://man7.org/linux/man-pages/man2/send.2.html)
- [sendto(2)](https://man7.org/linux/man-pages/man2/sendto.2.html)
