---
title: io_uring_register_ifq
section: 3
source_path: man/io_uring_register_ifq.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 103a37a44141bdddb882eb71b9f34a3261afd53032bea4dcd8cbe4f776cc8c38
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_ifq(3)

## 名称

io_uring_register_ifq - 注册零拷贝接收接口队列

## 概要

```c
#include <liburing.h>

int io_uring_register_ifq(struct io_uring *ring,
                          struct io_uring_zcrx_ifq_reg *reg);
```

## 描述

[io_uring_register_ifq(3)](io_uring_register_ifq.3.md) 函数向 `ring` 指定的 io_uring
实例注册零拷贝接收接口队列。零拷贝接收允许内核将传入的网络数据直接放入应用提供的
内存，而无需复制。

`reg` 参数指向描述要注册接口队列的 `struct io_uring_zcrx_ifq_reg`。有关
`IORING_REGISTER_ZCRX_IFQ` 操作及结构体字段的说明，请参见
[io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)。

创建 io_uring 环时必须设置 `IORING_SETUP_DEFER_TASKRUN`，并设置
`IORING_SETUP_CQE32` 或 `IORING_SETUP_CQE_MIXED` 标志。调用方必须具备
`CAP_NET_ADMIN` 能力。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
