---
title: io_uring_mlock_size
section: 3
source_path: man/io_uring_mlock_size.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: c4a75f96706c3798554f51bf6d3c13c4d1b41850b49b91a34fc1db2f9abf1f4e
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_mlock_size(3)

## 名称

io_uring_mlock_size - 获取环所需的 memlock 大小

## 概要

```c
#include <liburing.h>

ssize_t io_uring_mlock_size(unsigned entries, unsigned flags);
```

## 描述

[io_uring_mlock_size(3)](io_uring_mlock_size.3.md) 函数返回一个具有 `entries` 个项并
使用指定设置标志 `flags` 的 io_uring 环所需的 `RLIMIT_MEMLOCK` 内存大小。

在较新的内核（5.12 及更高版本）中，io_uring 不再需要任何 memlock 内存，此函数将
返回 0。在较旧的内核（5.11 及更早版本）中，此函数返回所需内存，以便调用方在设置环
之前确保有足够的 `RLIMIT_MEMLOCK` 空间。

如需更精细地控制环参数，请改用
[io_uring_mlock_size_params(3)](io_uring_mlock_size_params.3.md)。

## 返回值

成功时返回所需的 memlock 大小（以字节为单位）；如果不需要 memlock，则返回 0；发生
错误时返回负的 `errno` 值。

## 参见

- [io_uring_mlock_size_params(3)](io_uring_mlock_size_params.3.md)
- `io_uring_memory_size(3)`
- [io_uring_queue_init(3)](io_uring_queue_init.3.md)
- [getrlimit(2)](https://man7.org/linux/man-pages/man2/getrlimit.2.html)
