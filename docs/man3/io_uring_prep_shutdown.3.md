---
title: io_uring_prep_shutdown
section: 3
source_path: man/io_uring_prep_shutdown.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: d0baf99381d29931d7fcff3c66f33eece48907a3aff9ebe90cf5c0a355f60887
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_shutdown(3)

## 名称

io_uring_prep_shutdown - 准备一个 shutdown 请求

## 概要

```c
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_shutdown(struct io_uring_sqe *sqe,
                            int sockfd,
                            int how);
```

## 描述

[io_uring_prep_shutdown(3)](io_uring_prep_shutdown.3.md) 函数准备一个 shutdown 请求。
提交队列项 `sqe` 会被设置为使用 `sockfd`，并按照 `how` 参数对其进行 shutdown。

此函数准备一个异步
[shutdown(2)](https://man7.org/linux/man-pages/man2/shutdown.2.html) 请求。详情请
参见该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [shutdown(2)](https://man7.org/linux/man-pages/man2/shutdown.2.html)
