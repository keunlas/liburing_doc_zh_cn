---
title: io_uring_unregister_buf_ring
section: 3
source_path: man/io_uring_unregister_buf_ring.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a59bab03e69e4b1fbbdacc8539fbb6a85d82561e1cb665baf6dff3043dc68264
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_unregister_buf_ring(3)

## 名称

io_uring_unregister_buf_ring - 取消注册先前注册的缓冲区环

## 概要

```c
#include <liburing.h>

int io_uring_unregister_buf_ring(struct io_uring *ring,
                                 int bgid);
```

## 描述

[io_uring_unregister_buf_ring(3)](io_uring_unregister_buf_ring.3.md) 函数取消注册由
`bgid` 标识的先前注册的共享缓冲区环。

## 返回值

成功时，[io_uring_unregister_buf_ring(3)](io_uring_unregister_buf_ring.3.md) 返回 0。
失败时返回 `-errno`。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_free_buf_ring(3)](io_uring_free_buf_ring.3.md)
