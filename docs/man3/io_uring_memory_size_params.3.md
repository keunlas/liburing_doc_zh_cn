---
title: io_uring_memory_size_params
section: 3
source_path: man/io_uring_memory_size_params.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 7a3f112503ae3e10ebfc07582b2df04a8590826f5f6898f1b5d2bb72b8aa01d4
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_memory_size_params(3)

## 名称

io_uring_memory_size_params - 获取带参数的环所需内存大小

## 概要

```c
#include <liburing.h>

ssize_t io_uring_memory_size_params(unsigned entries, struct io_uring_params *p);
```

## 描述

[io_uring_memory_size_params(3)](io_uring_memory_size_params.3.md) 函数返回一个具有
`entries` 个项并使用 `p` 所指定参数的 io_uring 环所需的总内存大小。

对于希望为环预分配内存，或希望在创建环之前了解内存占用的应用，此函数很有用。

当 `p->flags` 中设置了 `IORING_SETUP_CQSIZE` 时，此函数允许调用方通过
`p->cq_entries` 指定完整环参数（包括 CQ 大小），因此比
`io_uring_memory_size(3)` 提供更多控制。

## 返回值

成功时返回所需内存大小（以字节为单位），发生错误时返回负的 `errno` 值。

- `-EINVAL`：`entries` 值无效（为 0，或在未使用 `IORING_SETUP_CLAMP` 时过大）。

## 参见

- `io_uring_memory_size(3)`
- [io_uring_mlock_size_params(3)](io_uring_mlock_size_params.3.md)
- [io_uring_queue_init_params(3)](io_uring_queue_init.3.md)
