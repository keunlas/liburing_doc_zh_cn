---
title: io_uring_setup_buf_ring
section: 3
source_path: man/io_uring_setup_buf_ring.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 7b51fb19ba444affd9687c58e492f1237fa87647d956d8529eec9e0e7d4b83ac
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_setup_buf_ring(3)

## 名称

io_uring_setup_buf_ring - 设置并注册用于提供的缓冲区的缓冲区环

## 概要

```c
#include <liburing.h>

struct io_uring_buf_ring *io_uring_setup_buf_ring(struct io_uring *ring,
                                                  unsigned int nentries,
                                                  int bgid,
                                                  unsigned int flags,
                                                  int *err);
```

## 描述

[io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md) 函数注册一个共享缓冲区环，
供提供的缓冲区使用。对于支持该功能的请求类型，提供的缓冲区会被放入环中；当请求准备
好接收数据时，如果在 SQE 的 `flags` 中设置了 `IOSQE_BUFFER_SELECT`，该请求就会选择
其中一个缓冲区。这既能明确缓冲区的生命周期所有权，也能让在途的读取/接收类型操作
数量多于可用缓冲区数量。

`ring` 参数必须是指向正在为其注册提供的缓冲区环的环的指针；`nentries` 是缓冲区环中
请求的项数。该参数必须是 2 的幂，最大可为 32768。`bgid` 是选定的缓冲区组 ID，
`flags` 是操作的修饰标志，`*err` 是指向整数的指针，用于在环分配和注册的任何部分
失败时返回错误值。

`flags` 参数可以设置为以下值之一：

- `IOU_PBUF_RING_INC`：此环中的缓冲区可以增量消费。对于部分消费，给定缓冲区 ID 的
  每次完成都会从先前完成停止的位置继续；如果尚未出现任何完成，则从头开始。当应预期
  给定缓冲区 ID 还会出现更多完成时，CQE 的 `flags` 成员中会设置
  `IORING_CQE_F_BUF_MORE`。自 6.12 起可用。

在内部，此函数使用
[io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md) 注册该环，并处理环的
分配，而不是让应用通过内联代码自行完成。

要取消注册并释放使用此函数设置的缓冲区组 ID，应用必须调用
[io_uring_free_buf_ring(3)](io_uring_free_buf_ring.3.md)。

自 5.19 起可用。

## 返回值

成功时，[io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md) 返回指向缓冲区环的
指针。失败时返回 `NULL`，并将 `*err` 设置为 `-errno`。

## 注意事项

请注意，即使内核支持此特性，如果主机是 32 位架构，并且传入的内存位于高地址内存
（high memory）中，注册提供的缓冲区环仍可能以 `-EINVAL` 失败。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_buf_ring_init(3)](io_uring_buf_ring_init.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md)
- [io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md)
