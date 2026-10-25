---
title: io_uring_buf_ring_init
section: 3
source_path: man/io_uring_buf_ring_init.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 7b2cce29db6d49e47206029709d7b2fe68996b9dd4e761c05b007a1dd7546342
source_copyright: "Copyright (C) 2022 Dylan Yudaken <dylany@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_buf_ring_init(3)

## 名称

io_uring_buf_ring_init - 初始化一个缓冲区环

## 概要

```c
#include <liburing.h>

void io_uring_buf_ring_init(struct io_uring_buf_ring *br);
```

## 描述

[io_uring_buf_ring_init(3)](io_uring_buf_ring_init.3.md) 初始化 `br`，使其可供使用。
此函数可以在
[io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md) 之后调用，但必须在
以任何其他方式使用该缓冲区环之前调用。

## 返回值

无。

## 注意事项

除非需要手动设置，否则建议使用
[io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md)，因为它提供了设置提供的
缓冲区环的更简单方式。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md)
- [io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md)
