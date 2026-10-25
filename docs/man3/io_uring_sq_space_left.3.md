---
title: io_uring_sq_space_left
section: 3
source_path: man/io_uring_sq_space_left.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: c1e8403c57f7fedd12159925d5ab637174da59ca14b1b9b120226c6e6ad58cff
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_sq_space_left(3)

## 名称

io_uring_sq_space_left - SQ 环中的可用空间

## 概要

```c
#include <liburing.h>

unsigned io_uring_sq_space_left(const struct io_uring *ring);
```

## 描述

[io_uring_sq_space_left(3)](io_uring_sq_space_left.3.md) 函数返回与 `ring` 参数所属的
SQ 环中还剩余多少空间。

## 返回值

返回 SQ 环中可用项的数量。

## 参见

- [io_uring_sq_ready(3)](io_uring_sq_ready.3.md)
