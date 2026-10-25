---
title: io_uring_register_wait_reg
section: 3
source_path: man/io_uring_register_wait_reg.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b676722bb7b53fcd2f61ba43e9c6854701fbf11b648ae645814d456ed7b5ffcb
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_wait_reg(3)

## 名称

io_uring_register_wait_reg - 向 io_uring 注册等待区域

## 概要

```c
#include <liburing.h>

int io_uring_register_wait_reg(struct io_uring *ring,
                               struct io_uring_reg_wait *reg,
                               int nr);
```

## 描述

[io_uring_register_wait_reg(3)](io_uring_register_wait_reg.3.md) 函数向 `ring`
指定的 io_uring 实例注册等待区域。`reg` 参数指向包含 `nr` 个
`struct io_uring_reg_wait` 项的数组。

等待区域允许注册超时和信号掩码信息，从而可在多次等待操作中复用，无需在每次调用时
复制数据。它与
[io_uring_submit_and_wait_reg(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_reg.3)
配合使用，以降低等待操作的开销。

有关注册底层内存区域的信息，请参见
[io_uring_register_region(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_region.3)。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 参见

- [io_uring_submit_and_wait_reg(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_reg.3)
- [io_uring_register_region(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_region.3)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
