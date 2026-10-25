---
title: io_uring_enable_rings
section: 3
source_path: man/io_uring_enable_rings.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: ad194618d6f2e06d0709f9a4a12acb78bdad208824ff1eb7c3b6a765bd282acd
source_copyright: "Copyright (C) 2023 nick black <dankamongmen@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_enable_rings(3)

## 名称

io_uring_enable_rings - 启用一个已禁用的环

## 概要

```c
#include <liburing.h>

int io_uring_enable_rings(struct io_uring *ring);
```

## 描述

[io_uring_enable_rings(3)](io_uring_enable_rings.3.md) 函数用于在通过
[io_uring_queue_init(3)](io_uring_queue_init.3.md) 的 `IORING_SETUP_R_DISABLED`
标志创建环之后启用该环。

在成功调用此函数之前，无法向这样的环提交工作。

## 返回值

[io_uring_enable_rings(3)](io_uring_enable_rings.3.md) 成功时返回 0，否则返回负的
错误码。此函数不会写入 `errno`。

## 错误

- `EBADFD`：该环未被禁用。

## 参见

- [io_uring_queue_init(3)](io_uring_queue_init.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
