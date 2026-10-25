---
title: io_uring_unregister_files
section: 3
source_path: man/io_uring_unregister_files.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 91191fd7d4f57c246e3ea76672f8b0908722a9d949ba25844d543d5e1959da0f
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_unregister_files(3)

## 名称

io_uring_unregister_files - 取消注册文件描述符

## 概要

```c
#include <liburing.h>

int io_uring_unregister_files(struct io_uring *ring);
```

## 描述

[io_uring_unregister_files(3)](io_uring_unregister_files.3.md) 函数取消注册先前向
`ring` 注册的文件描述符。

## 返回值

成功时，[io_uring_unregister_files(3)](io_uring_unregister_files.3.md) 返回 0。失败
时返回 `-errno`。

## 参见

- [io_uring_register_files(3)](io_uring_register_files.3.md)
