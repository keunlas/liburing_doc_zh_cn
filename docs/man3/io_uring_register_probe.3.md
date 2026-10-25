---
title: io_uring_register_probe
section: 3
source_path: man/io_uring_register_probe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: be12ec19166e4e6f9e66a7cc8afda8b7476b2a0e6185245db1b442db6d84414a
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_probe(3)

## 名称

io_uring_register_probe - 向 io_uring 注册探测信息

## 概要

```c
#include <liburing.h>

int io_uring_register_probe(struct io_uring *ring,
                            struct io_uring_probe *p,
                            unsigned nr);
```

## 描述

[io_uring_register_probe(3)](io_uring_register_probe.3.md) 函数向内核查询所支持的
io_uring 操作码，并填入探测结构体 `p`。`ring` 参数指定要查询的 io_uring 实例，
`nr` 指定要查询的最大操作码数量。

探测结构体包含有关内核支持哪些操作码的信息。调用此函数后，应用可以使用
[io_uring_opcode_supported(3)](io_uring_opcode_supported.3.md) 检查某个特定操作码
是否受支持。

大多数应用应改用
[io_uring_get_probe(3)](io_uring_get_probe.3.md) 或
[io_uring_get_probe_ring(3)](io_uring_get_probe_ring.3.md)，它们会自动分配并填入探测
结构体。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 参见

- [io_uring_get_probe(3)](io_uring_get_probe.3.md)
- [io_uring_get_probe_ring(3)](io_uring_get_probe_ring.3.md)
- [io_uring_opcode_supported(3)](io_uring_opcode_supported.3.md)
- [io_uring_free_probe(3)](io_uring_free_probe.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
