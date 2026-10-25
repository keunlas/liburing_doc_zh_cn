---
title: io_uring_unregister_buffers
section: 3
source_path: man/io_uring_unregister_buffers.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 79cd70d58ee6c522bfd38d3d0613b38efb520102a516e0a43253fe77ba72ead5
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_unregister_buffers(3)

## 名称

io_uring_unregister_buffers - 取消注册固定缓冲区操作所用的缓冲区

## 概要

```c
#include <liburing.h>

int io_uring_unregister_buffers(struct io_uring *ring);
```

## 描述

[io_uring_unregister_buffers(3)](io_uring_unregister_buffers.3.md) 函数取消注册先前
向 `ring` 注册的固定缓冲区。

## 返回值

成功时，[io_uring_unregister_buffers(3)](io_uring_unregister_buffers.3.md) 返回 0。
失败时返回 `-errno`。

## 参见

- [io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
