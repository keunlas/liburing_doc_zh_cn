---
title: io_uring_prep_epoll_wait
section: 3
source_path: man/io_uring_prep_epoll_wait.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: fa3fd859148038958bcf39978faa2ce352d29db8242db397c4ea841904738e48
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_epoll_wait(3)

## 名称

io_uring_prep_epoll_wait - 准备一个 epoll 等待请求

## 概要

```c
#include <sys/epoll.h>
#include <liburing.h>

void io_uring_prep_epoll_wait(struct io_uring_sqe *sqe,
                              int fd,
                              struct epoll_event *events,
                              int maxevents,
                              unsigned flags);
```

## 描述

[io_uring_prep_epoll_wait(3)](io_uring_prep_epoll_wait.3.md) 函数准备一个 epoll_wait
请求。提交队列项 `sqe` 会被设置为在 `fd` 指示的 epoll 文件描述符上最多等待
`maxevents` 个事件，并将收到的事件填入 `events` 所指向的内存。

此函数准备一个异步
[epoll_wait(2)](https://man7.org/linux/man-pages/man2/epoll_wait.2.html) 请求。详情
请参见该手册页。用例主要面向旧式事件循环，其中某些文件描述符可能仍在使用 epoll 获取
就绪通知。通常，这需要同时将 io_uring fd 添加到 epoll 集合并使用 `epoll_wait`；
这种方式的次优之处在于，epoll 不能提供 io_uring 那种细粒度批量控制和唤醒次数削减。
通过使用 io_uring 读取 epoll 事件，事件循环可以完全切换到 io_uring，并获得批量等待
和减少上下文切换的优势。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [epoll_wait(2)](https://man7.org/linux/man-pages/man2/epoll_wait.2.html)
