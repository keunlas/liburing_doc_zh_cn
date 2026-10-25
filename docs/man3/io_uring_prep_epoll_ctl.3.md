---
title: io_uring_prep_epoll_ctl
section: 3
source_path: man/io_uring_prep_epoll_ctl.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 204472aded86f143fd022bb4bddfe15e5c38038ae3287374f003920b890154bd
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_epoll_ctl(3)

## 名称

io_uring_prep_epoll_ctl - 准备一个 epoll_ctl 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_epoll_ctl(struct io_uring_sqe *sqe,
                             int epfd,
                             int fd,
                             int op,
                             const struct epoll_event *ev);
```

## 描述

[io_uring_prep_epoll_ctl(3)](io_uring_prep_epoll_ctl.3.md) 函数准备一个 epoll 控制
请求。提交队列项 `sqe` 会被设置为使用 `epfd` 所引用的 epoll 实例，对文件描述符
`fd` 执行操作 `op`。`ev` 参数指向一个按
[epoll_ctl(2)](https://man7.org/linux/man-pages/man2/epoll_ctl.2.html) 定义的
`epoll_event` 结构体。

`op` 参数可以是以下值之一：

- `EPOLL_CTL_ADD`：将 `fd` 添加到 epoll 实例。
- `EPOLL_CTL_MOD`：修改 `fd` 的设置。
- `EPOLL_CTL_DEL`：从 epoll 实例移除 `fd`。此操作会忽略 `ev`。

此函数准备一个异步
[epoll_ctl(2)](https://man7.org/linux/man-pages/man2/epoll_ctl.2.html) 请求。详情
请参见该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果，成功时为 0。发生错误时，返回负的 `errno` 值。可能
的错误值请参见
[epoll_ctl(2)](https://man7.org/linux/man-pages/man2/epoll_ctl.2.html)。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_epoll_wait(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_prep_epoll_wait.3)
- [epoll_ctl(2)](https://man7.org/linux/man-pages/man2/epoll_ctl.2.html)
