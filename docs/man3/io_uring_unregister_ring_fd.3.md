---
title: io_uring_unregister_ring_fd
section: 3
source_path: man/io_uring_unregister_ring_fd.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 395f3b32ee22881ee5461916f0b0f078ccb2ad6246615196004fa58d679d1c5a
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_unregister_ring_fd(3)

## 名称

io_uring_unregister_ring_fd - 取消注册一个环文件描述符

## 概要

```c
#include <liburing.h>

int io_uring_unregister_ring_fd(struct io_uring *ring);
```

## 描述

[io_uring_unregister_ring_fd(3)](io_uring_unregister_ring_fd.3.md) 取消注册该环的
文件描述符。

取消注册先前在当前任务中注册的环描述符。调用
[io_uring_queue_exit(3)](io_uring_queue_exit.3.md) 时会自动执行此操作，也可以主动
执行此操作，以便为新的环注册释放空间。有关环描述符注册的更多信息，请参见
[io_uring_register_ring_fd(3)](io_uring_register_ring_fd.3.md)。

## 返回值

成功时返回 1，表示取消注册了一个文件描述符；发生错误时返回 `-errno`。

## 参见

- [io_uring_register_ring_fd(3)](io_uring_register_ring_fd.3.md)
- [io_uring_register_files(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_files.3)
