---
title: io_uring_unregister_personality
section: 3
source_path: man/io_uring_unregister_personality.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a8b66644c34fcd4f6e5d932da685d6dc2cb87c3229faf4204459dd0f91f9dd6d
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_unregister_personality(3)

## 名称

io_uring_unregister_personality - 从 io_uring 取消注册身份凭据

## 概要

```c
#include <liburing.h>

int io_uring_unregister_personality(struct io_uring *ring, int id);
```

## 描述

[io_uring_unregister_personality(3)](io_uring_unregister_personality.3.md) 函数从由
`ring` 指定的 io_uring 实例取消注册先前注册的身份凭据。`id` 参数是先前调用
[io_uring_register_personality(3)](io_uring_register_personality.3.md) 返回的身份
凭据 ID。

取消注册后，该身份凭据 ID 不再有效，并且不得在后续提交中使用。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 参见

- [io_uring_register_personality(3)](io_uring_register_personality.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
