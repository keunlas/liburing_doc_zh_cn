---
title: io_uring_prep_nop
section: 3
source_path: man/io_uring_prep_nop.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 39b8550958da2d6197b3bc6cd6986f9ccc577ecf643073e60ae02dc17ad2f8a5
source_copyright: "Copyright (C) 2022 Samuel Williams"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_nop(3)

## 名称

io_uring_prep_nop - 准备一个 nop 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_nop(struct io_uring_sqe *sqe);
```

## 描述

[io_uring_prep_nop(3)](io_uring_prep_nop.3.md) 函数准备一个 nop（no operation，
无操作）请求。提交队列项 `sqe` 不需要任何额外设置。

## 返回值

无。

## 错误

无。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
