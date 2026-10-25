---
title: io_uring_get_probe_ring
section: 3
source_path: man/io_uring_get_probe_ring.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 75ace02ad8e3b82317e11b3454a8b06bb6a21e2e8f2ac1e3204fe176c366c699
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_get_probe_ring(3)

## 名称

io_uring_get_probe_ring - 从现有环获取探测信息

## 概要

```c
#include <liburing.h>

struct io_uring_probe *io_uring_get_probe_ring(struct io_uring *ring);
```

## 描述

[io_uring_get_probe_ring(3)](io_uring_get_probe_ring.3.md) 函数返回由 `ring` 指定的
io_uring 实例的探测信息。这使应用能够确定内核支持哪些操作码。

返回的探测结构体必须在不再需要时由应用使用
[io_uring_free_probe(3)](io_uring_free_probe.3.md) 释放。

此函数与
[io_uring_get_probe(3)](io_uring_get_probe.3.md) 类似，区别在于它使用现有环，而不是
创建一个临时环。

## 返回值

成功时返回指向已分配 `struct io_uring_probe` 的指针，失败时返回 `NULL`。

## 参见

- [io_uring_get_probe(3)](io_uring_get_probe.3.md)
- [io_uring_free_probe(3)](io_uring_free_probe.3.md)
- [io_uring_opcode_supported(3)](io_uring_opcode_supported.3.md)
- [io_uring_register_probe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_probe.3)
