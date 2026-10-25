---
title: io_uring_mlock_size_params
section: 3
source_path: man/io_uring_mlock_size_params.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 7e361246e1390a0da6f54cf057588c855d2e14fb6d42bce9d654a8d1237e6552
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_mlock_size_params(3)

## 名称

io_uring_mlock_size_params - 获取带参数的环所需 memlock 大小

## 概要

```c
#include <liburing.h>

ssize_t io_uring_mlock_size_params(unsigned entries, struct io_uring_params *p);
```

## 描述

[io_uring_mlock_size_params(3)](io_uring_mlock_size_params.3.md) 函数返回一个具有
`entries` 个项并使用 `p` 所指定参数的 io_uring 环所需的 `RLIMIT_MEMLOCK` 内存大小。

在较新的内核（5.12 及更高版本）中，io_uring 不再需要任何 memlock 内存，此函数将
返回 0。在较旧的内核（5.11 及更早版本）中，此函数返回所需内存，以便调用方在设置环
之前确保有足够的 `RLIMIT_MEMLOCK` 空间。

当 `p->flags` 中设置了 `IORING_SETUP_CQSIZE` 时，此函数允许调用方通过
`p->cq_entries` 指定完整环参数（包括 CQ 大小），因此比
[io_uring_mlock_size(3)](io_uring_mlock_size.3.md) 提供更多控制。

## 返回值

成功时返回所需的 memlock 大小（以字节为单位）；如果不需要 memlock，则返回 0；发生
错误时返回负的 `errno` 值。

## 参见

- [io_uring_mlock_size(3)](io_uring_mlock_size.3.md)
- [io_uring_memory_size_params(3)](io_uring_memory_size_params.3.md)
- [io_uring_queue_init_params(3)](io_uring_queue_init.3.md)
- [getrlimit(2)](https://man7.org/linux/man-pages/man2/getrlimit.2.html)
