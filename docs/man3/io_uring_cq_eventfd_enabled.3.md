---
title: io_uring_cq_eventfd_enabled
section: 3
source_path: man/io_uring_cq_eventfd_enabled.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 1df895d5c59c1f25d0b4e41c5f06cd857a755159b568171ab1a22cf85456086d
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cq_eventfd_enabled(3)

## 名称

io_uring_cq_eventfd_enabled - 检查 eventfd 通知是否已启用

## 概要

```c
#include <liburing.h>

bool io_uring_cq_eventfd_enabled(const struct io_uring *ring);
```

## 描述

[io_uring_cq_eventfd_enabled(3)](io_uring_cq_eventfd_enabled.3.md)
函数返回由 `ring` 指定的 io_uring 实例当前是否已启用 eventfd 通知。

可以使用
[io_uring_register_eventfd(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
或
[io_uring_register_eventfd_async(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
向环注册 eventfd。注册后，可以使用
[io_uring_cq_eventfd_toggle(3)](io_uring_cq_eventfd_toggle.3.md) 暂时禁用通知。

## 返回值

如果 eventfd 通知已启用，返回 `true`；如果已禁用，返回 `false`。

## 参见

- [io_uring_register_eventfd(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
- [io_uring_register_eventfd_async(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
- [io_uring_cq_eventfd_toggle(3)](io_uring_cq_eventfd_toggle.3.md)
