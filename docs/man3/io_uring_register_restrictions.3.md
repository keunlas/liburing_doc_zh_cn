---
title: io_uring_register_restrictions
section: 3
source_path: man/io_uring_register_restrictions.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 7da97338ba441ea78169c1b5f7892f1298eb49b49b776090b2f16c18645d934f
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_restrictions(3)

## 名称

io_uring_register_restrictions - 向 io_uring 注册限制

## 概要

```c
#include <liburing.h>

int io_uring_register_restrictions(struct io_uring *ring,
                                   struct io_uring_restriction *res,
                                   unsigned int nr_res);
```

## 描述

[io_uring_register_restrictions(3)](io_uring_register_restrictions.3.md) 函数向
`ring` 指定的 io_uring 实例注册限制。`res` 参数指向包含 `nr_res` 个
`struct io_uring_restriction` 项的数组。

限制可以限定环上允许使用哪些操作码、注册操作或 SQE 标志。这可用于对 io_uring 的
使用进行沙箱化。

只有在以禁用状态启动 io_uring 环时（在
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
调用中指定 `IORING_SETUP_R_DISABLED`），才能注册限制。所有限制都必须在使用
[io_uring_enable_rings(3)](io_uring_enable_rings.3.md) 启用环之前，通过一次调用全部
注册。

有关 `IORING_REGISTER_RESTRICTIONS` 操作和限制结构体的说明，请参见
[io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 参见

- [io_uring_enable_rings(3)](io_uring_enable_rings.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
