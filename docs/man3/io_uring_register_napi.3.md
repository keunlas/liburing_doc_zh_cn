---
title: io_uring_register_napi
section: 3
source_path: man/io_uring_register_napi.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 91554d0269128a85c37dfc5acc89fd3b02b7399fee60bee422efea5bbb88cd12
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@devkernel.io>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_napi(3)

## 名称

io_uring_register_napi - 注册 NAPI 忙轮询设置

## 概要

```c
#include <liburing.h>

int io_uring_register_napi(struct io_uring *ring,
                           struct io_uring_napi *napi)
```

## 描述

[io_uring_register_napi(3)](io_uring_register_napi.3.md) 函数为后续操作注册 NAPI
设置。NAPI 设置由传入 `napi` 参数的结构体指定。该结构体由 NAPI 超时
`busy_poll_to`（NAPI 忙轮询超时，单位为 us）和 `prefer_busy_poll` 组成。

注册 NAPI 设置会设置调用 `napi_busy_loop` 函数时的模式，并对应于
`SO_PREFER_BUSY_POLL` 套接字选项。

NAPI 忙轮询可以缩短网络往返时间。

## 返回值

成功时，[io_uring_register_napi(3)](io_uring_register_napi.3.md) 返回 0。失败时
返回 `-errno`。该函数还会使用当前值更新 `napi` 结构体。
