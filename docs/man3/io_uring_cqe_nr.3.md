---
title: io_uring_cqe_nr
section: 3
source_path: man/io_uring_cqe_nr.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: e4636b60f50f11165ed45d13b8e8ea1af6416bb4b1201501e0166bbe00102090
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cqe_nr(3)

## 名称

io_uring_cqe_nr - 返回一个 CQE 消耗的 CQ 环槽位数量

## 概要

```c
#include <liburing.h>

unsigned io_uring_cqe_nr(const struct io_uring_cqe *cqe);
```

## 描述

[io_uring_cqe_nr(3)](io_uring_cqe_nr.3.md)
函数返回 `cqe` 消耗的 CQ 环槽位数量。对于普通的 16 字节 CQE，返回 1。对于 32 字节
CQE（即 CQE 标志中设置了 `IORING_CQE_F_32` 时），返回 2。

当环使用 `IORING_SETUP_CQE_MIXED`，并且可能同时存在 16 字节和 32 字节 CQE 时，此
函数对使用 [io_uring_cq_advance(3)](io_uring_cq_advance.3.md) 推进 CQ 环很有用。

## 返回值

对于普通 CQE 返回 1，对于 32 字节 CQE 返回 2。

## 参见

- [io_uring_cq_advance(3)](io_uring_cq_advance.3.md)
- [io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
