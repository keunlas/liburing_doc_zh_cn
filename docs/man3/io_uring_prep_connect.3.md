---
title: io_uring_prep_connect
section: 3
source_path: man/io_uring_prep_connect.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 14d7c29509f572fecdf1560068e6a590639d59fb106a93abebceccb333f8231a
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_connect(3)

## 名称

io_uring_prep_connect - 准备一个 connect 请求

## 概要

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_connect(struct io_uring_sqe *sqe,
                           int sockfd,
                           const struct sockaddr *addr,
                           socklen_t addrlen);
```

## 描述

[io_uring_prep_connect(3)](io_uring_prep_connect.3.md) 函数准备一个 connect 请求。
提交队列项 `sqe` 会被设置为使用文件描述符 `sockfd`，开始连接到由 `addr` 处的套接字
地址描述、结构体长度为 `addrlen` 的目标。

此函数准备一个异步
[connect(2)](https://man7.org/linux/man-pages/man2/connect.2.html) 请求。详情请
参见该手册页。

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

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [connect(2)](https://man7.org/linux/man-pages/man2/connect.2.html)
