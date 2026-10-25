---
title: io_uring_unregister_napi
section: 3
source_path: man/io_uring_unregister_napi.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 971b767627f195c80ec1c13a82d6c7a2bcd2a131bee2a9342923e9ea7f38a038
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@devkernel.io>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_unregister_napi(3)

## 名称

io_uring_unregister_napi - 取消注册 NAPI 忙轮询设置

## 概要

```c
#include <liburing.h>

int io_uring_unregister_napi(struct io_uring *ring,
                             struct io_uring_napi *napi)
```

## 描述

[io_uring_unregister_napi(3)](io_uring_unregister_napi.3.md) 函数为后续操作取消注册
NAPI 忙轮询设置。

## 返回值

成功时，[io_uring_unregister_napi(3)](io_uring_unregister_napi.3.md) 返回 0。失败时
返回 `-errno`。该函数还会使用当前值更新 `napi` 结构体。
