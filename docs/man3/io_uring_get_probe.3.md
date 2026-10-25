---
title: io_uring_get_probe
section: 3
source_path: man/io_uring_get_probe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 804b0e3033be2d18a5cff3ed1f039a57a9a49f2d86260b13e3d8e18ca6bb07d0
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_get_probe(3)

## 名称

io_uring_get_probe - 获取探测实例

## 概要

```c
#include <liburing.h>

io_uring_probe *io_uring_get_probe(void);
```

## 描述

[io_uring_get_probe(3)](io_uring_get_probe.3.md) 函数向调用方返回一个已分配的
`io_uring_probe` 结构体。调用方负责使用
[io_uring_free_probe(3)](io_uring_free_probe.3.md) 函数释放该结构体。

## 注意事项

较旧版本的 Linux 内核不支持探测。如果内核不支持探测，此函数将返回 `NULL`。

## 返回值

成功时返回一个已分配的 `io_uring_probe` 结构体，否则返回 `NULL`。

## 参见

- [io_uring_free_probe(3)](io_uring_free_probe.3.md)
