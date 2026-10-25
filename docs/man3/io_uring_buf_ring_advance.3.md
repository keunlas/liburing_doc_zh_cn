---
title: io_uring_buf_ring_advance
section: 3
source_path: man/io_uring_buf_ring_advance.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: e7cf0f6234f9cdf716ad64b799d27a173db4057a5f044b2d5f9be858f108bd96
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_buf_ring_advance(3)

## 名称

io_uring_buf_ring_advance - 推进缓冲区环中提供的缓冲区索引

## 概要

```c
#include <liburing.h>

void io_uring_buf_ring_advance(struct io_uring_buf_ring *br,
                               int count);
```

## 描述

[io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md) 将先前添加到共享
缓冲区环 `br` 的 `count` 个缓冲区提交，使它们对内核可见，因而可供消费。这会将缓冲区
的所有权移交给环。

## 返回值

无。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md)
