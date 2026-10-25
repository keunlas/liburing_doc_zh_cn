---
title: io_uring_prep_listen
section: 3
source_path: man/io_uring_prep_listen.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: e80256389a4f5210213dbb8af4440180e864400514fdd815d7b391a3e1d05be5
source_copyright: "Copyright (C) 2024 SUSE LLC."
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_listen(3)

## 名称

io_uring_prep_listen - 准备一个 listen 请求

## 概要

```c
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_listen(struct io_uring_sqe *sqe,
                          int sockfd,
                          int backlog);
```

## 描述

[io_uring_prep_listen(3)](io_uring_prep_listen.3.md) 函数准备一个 listen 请求。提交
队列项 `sqe` 会被设置为使 `sockfd` 所指向的套接字文件描述符进入可接受传入连接的
状态。`backlog` 参数定义待处理连接队列的最大长度。

此函数准备一个异步
[listen(2)](https://man7.org/linux/man-pages/man2/listen.2.html) 请求。详情请参见该
手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [listen(2)](https://man7.org/linux/man-pages/man2/listen.2.html)
