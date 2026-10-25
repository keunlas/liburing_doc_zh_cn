---
title: io_uring_cq_eventfd_toggle
section: 3
source_path: man/io_uring_cq_eventfd_toggle.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 265d7a47821be834acaca6e494c34b5ef11548946bee1067c7a98bbbeb2c60f2
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cq_eventfd_toggle(3)

## 名称

io_uring_cq_eventfd_toggle - 开启或关闭 eventfd 通知

## 概要

```c
#include <liburing.h>

int io_uring_cq_eventfd_toggle(struct io_uring *ring, bool enabled);
```

## 描述

[io_uring_cq_eventfd_toggle(3)](io_uring_cq_eventfd_toggle.3.md)
函数切换由 `ring` 指定的 io_uring 实例的 eventfd 通知。如果 `enabled` 为 `true`，
则启用 eventfd 通知；如果 `enabled` 为 `false`，则禁用通知。

在使用此函数前，必须先通过
[io_uring_register_eventfd(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
或
[io_uring_register_eventfd_async(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
向环注册 eventfd。

例如，当应用希望在批处理阶段暂时停止接收 eventfd 通知时，此函数会很有用。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值：

- `-EOPNOTSUPP`：内核不支持切换 eventfd 通知，或未注册 eventfd。

## 参见

- [io_uring_register_eventfd(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
- [io_uring_register_eventfd_async(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_eventfd.3)
- [io_uring_cq_eventfd_enabled(3)](io_uring_cq_eventfd_enabled.3.md)
