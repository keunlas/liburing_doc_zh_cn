---
title: io_uring_free_probe
section: 3
source_path: man/io_uring_free_probe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 78b6e66b9c58aa84f57e63bf63db551b3eebc347a77b2f2bd896d52f01d1dc32
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_free_probe(3)

## 名称

io_uring_free_probe - 释放探测实例

## 概要

```c
#include <liburing.h>

void io_uring_free_probe(struct io_uring_probe *probe);
```

## 描述

[io_uring_free_probe(3)](io_uring_free_probe.3.md) 函数释放使用
[io_uring_get_probe(3)](io_uring_get_probe.3.md) 函数分配的 `probe` 实例。

## 返回值

无。

## 参见

- [io_uring_get_probe(3)](io_uring_get_probe.3.md)
