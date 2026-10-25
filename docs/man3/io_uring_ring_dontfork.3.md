---
title: io_uring_ring_dontfork
section: 3
source_path: man/io_uring_ring_dontfork.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a553babb1d209679204272b4eccf6df00f916b7f9ac1fd8b28076586451dda95
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_ring_dontfork(3)

## 名称

io_uring_ring_dontfork - 防止 fork 后共享环内存

## 概要

```c
#include <liburing.h>

int io_uring_ring_dontfork(struct io_uring *ring);
```

## 描述

[io_uring_ring_dontfork(3)](io_uring_ring_dontfork.3.md) 函数确保在
[fork(2)](https://man7.org/linux/man-pages/man2/fork.2.html) 之后，io_uring 实例
`ring` 的 mmap 环对子进程不可用。

此函数会对 mmap 范围使用带有 `MADV_DONTFORK` 的
[madvise(2)](https://man7.org/linux/man-pages/man2/madvise.2.html)，以防止这些范围
与子进程共享。当父进程希望独占访问该环，并且不希望子进程访问或干扰该环时，这很有用。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 参见

- [io_uring_queue_init(3)](io_uring_queue_init.3.md)
- [madvise(2)](https://man7.org/linux/man-pages/man2/madvise.2.html)
- [fork(2)](https://man7.org/linux/man-pages/man2/fork.2.html)
