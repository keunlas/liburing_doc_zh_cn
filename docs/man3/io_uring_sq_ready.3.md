---
title: io_uring_sq_ready
section: 3
source_path: man/io_uring_sq_ready.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 1ef4a600b0c59cd5b4140444093b6bf5b4554aea771d07dd92d006797a0aa59e
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_sq_ready(3)

## 名称

io_uring_sq_ready - SQ 环中尚未消费或尚未提交的项数量

## 概要

```c
#include <liburing.h>

unsigned io_uring_sq_ready(const struct io_uring *ring);
```

## 描述

[io_uring_sq_ready(3)](io_uring_sq_ready.3.md) 函数返回与 `ring` 参数所属的 SQ 环中
存在的尚未消费（如果使用 SQPOLL）或尚未提交的项数量。

仅当环使用 `IORING_SETUP_SQPOLL` 设置时，才使用此函数；此时请求提交以及从 SQ 环
中进行消费都通过轮询线程完成。

## 返回值

返回 SQ 环中尚未消费或尚未提交的项数量。

## 参见

- [io_uring_cq_ready(3)](io_uring_cq_ready.3.md)
