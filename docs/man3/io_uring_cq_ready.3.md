---
title: io_uring_cq_ready
section: 3
source_path: man/io_uring_cq_ready.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b27ed722d103fa5d3b1735a79a54ea46517f672c1ca59f022d02c556c128e770
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cq_ready(3)

## 名称

io_uring_cq_ready - 返回 CQ 环中尚未消费的就绪项数量

## 概要

```c
#include <liburing.h>

unsigned io_uring_cq_ready(const struct io_uring *ring);
```

## 描述

[io_uring_cq_ready(3)](io_uring_cq_ready.3.md)
函数返回与 `ring` 参数所属且已就绪的未消费项数量。

## 返回值

返回 CQ 环中尚未消费的就绪项数量。

## 参见

- [io_uring_submit(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit.3)
- [io_uring_wait_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe.3)
