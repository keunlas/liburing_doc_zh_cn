---
title: io_uring_queue_exit
section: 3
source_path: man/io_uring_queue_exit.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 5deec3ee8eec3f03b8d084ff946a343ae9c9904236c65637f15d30be11aa8303
source_copyright: "Copyright (C) 2020 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2020 Red Hat, Inc."
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_queue_exit(3)

## 名称

io_uring_queue_exit - 拆除 io_uring 提交队列和完成队列

## 概要

```c
#include <liburing.h>

void io_uring_queue_exit(struct io_uring *ring);
```

## 描述

[io_uring_queue_exit(3)](io_uring_queue_exit.3.md) 将释放
[io_uring_queue_init(3)](io_uring_queue_init.3.md) 获取并初始化的所有资源。它首先
取消映射应用与内核之间共享的内存，然后关闭 io_uring 文件描述符。

部分统计工作会异步完成，因此在函数返回后，由
[io_uring_queue_init(3)](io_uring_queue_init.3.md) 锁定的内存可能仍会被锁定数毫秒。

## 返回值

无。

## 参见

- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
- [mmap(2)](https://man7.org/linux/man-pages/man2/mmap.2.html)
- [io_uring_queue_init(3)](io_uring_queue_init.3.md)
