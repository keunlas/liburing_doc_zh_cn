---
title: io_uring_prep_sendmsg_zc_fixed
section: 3
source_path: man/io_uring_prep_sendmsg_zc_fixed.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: efc9f74aa6b3114179a41b2f0c6a600f006fbfbffc7a4b98ef0853a01a737d79
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_sendmsg_zc_fixed(3)

## 名称

io_uring_prep_sendmsg_zc_fixed - 使用固定缓冲区准备一个零拷贝 sendmsg 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_sendmsg_zc_fixed(struct io_uring_sqe *sqe,
                                    int fd,
                                    const struct msghdr *msg,
                                    unsigned flags,
                                    unsigned buf_index);
```

## 描述

[io_uring_prep_sendmsg_zc_fixed(3)](io_uring_prep_sendmsg_zc_fixed.3.md) 函数使用
固定（已注册）缓冲区准备一个零拷贝 sendmsg 请求。提交队列项 `sqe` 会被设置为使用
文件描述符 `fd` 所指示的套接字和消息结构体 `msg` 来发送数据。

`flags` 参数包含 sendmsg 操作的标志，详情如
[sendmsg(2)](https://man7.org/linux/man-pages/man2/sendmsg.2.html) 所述。

`buf_index` 指定要使用的已注册缓冲区集合的索引。`msg` 中的缓冲区必须属于先前通过
[io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
注册的已注册缓冲区集合。

零拷贝发送避免将数据从用户空间复制到内核空间，从而提高大块传输的性能。使用固定
缓冲区还可以避免在每次 I/O 操作时映射缓冲区的开销。

请注意，零拷贝发送要求应用在复用缓冲区之前等待通知。有关零拷贝语义的更多详情，请
参见
[io_uring_prep_send_zc(3)](io_uring_prep_send_zc.3.md)。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果；成功时为已发送的字节数。发生错误时，返回负的
`errno` 值。

尽管此函数接受一个 iovec 数组，其中每个 iovec 的字节数为 `size_t`，但每次调用最多
只能传输 `INT_MAX` 字节（底层系统调用接口的最大值）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_sendmsg_zc(3)](io_uring_prep_sendmsg.3.md)
- [io_uring_prep_sendmsg(3)](io_uring_prep_sendmsg.3.md)
- [io_uring_prep_send_zc_fixed(3)](io_uring_prep_send_zc.3.md)
- [io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
- [sendmsg(2)](https://man7.org/linux/man-pages/man2/sendmsg.2.html)
