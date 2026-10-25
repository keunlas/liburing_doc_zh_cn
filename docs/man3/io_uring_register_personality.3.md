---
title: io_uring_register_personality
section: 3
source_path: man/io_uring_register_personality.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 67831baf67fbbe370635373d9948441517f36a63c867e58a01ce9c6caf1e276f
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_personality(3)

## 名称

io_uring_register_personality - 向 io_uring 注册凭据

## 概要

```c
#include <liburing.h>

int io_uring_register_personality(struct io_uring *ring);
```

## 描述

[io_uring_register_personality(3)](io_uring_register_personality.3.md) 函数将调用
应用的凭据注册到由 `ring` 指定的 io_uring 实例。这允许在不同用户或进程之间共享一个
环，同时保持凭据隔离。

返回的身份凭据 ID 可用于提交队列项的 `personality` 字段，以使用已注册凭据执行该
请求。

## 返回值

成功时返回一个正的身份凭据 ID，可用于后续操作。发生错误时，返回负的 `errno` 值。

## 参见

- [io_uring_unregister_personality(3)](io_uring_unregister_personality.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
