---
title: io_uring_buf_ring_mask
section: 3
source_path: man/io_uring_buf_ring_mask.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: e80097b4d93b7488d8b65a0b7f0ad3b0d8d57d46b769c66aa9335596d4914794
source_copyright: "Copyright (C) 2022 Dylan Yudaken <dylany@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_buf_ring_mask(3)

## 名称

io_uring_buf_ring_mask - 计算缓冲区环的掩码大小

## 概要

```c
#include <liburing.h>

int io_uring_buf_ring_mask(__u32 ring_entries);
```

## 描述

[io_uring_buf_ring_mask(3)](io_uring_buf_ring_mask.3.md) 为缓冲区环计算适当的大小
掩码。`ring_entries` 是
[io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md) 中指定的环项数。

## 返回值

返回缓冲区环的大小掩码。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
