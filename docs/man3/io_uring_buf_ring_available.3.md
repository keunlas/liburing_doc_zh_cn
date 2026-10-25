---
title: io_uring_buf_ring_available
section: 3
source_path: man/io_uring_buf_ring_available.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 61ca813b34ce930e224590cd92df29e296e59c11f7400ae0d503c31cbb439196
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_buf_ring_available(3)

## 名称

io_uring_buf_ring_available - 返回提供的缓冲区环中尚未消费的项数量

## 概要

```c
#include <liburing.h>

int io_uring_buf_ring_available(struct io_uring *ring,
                                struct io_uring_buf_ring *br,
                                unsigned short bgid);
```

## 描述

[io_uring_buf_ring_available(3)](io_uring_buf_ring_available.3.md) 辅助函数返回
属于 io_uring `ring`、由缓冲区组 ID `bgid` 标识的 `br` 提供的缓冲区组中尚未被内核
消费的项数。

由于提供的缓冲区环的头部仅对内核可见，否则无法知道给定提供的缓冲区环中有多少未消费
项。此函数向内核查询并返回该数量。自内核 6.8 起可用。

## 注意事项

返回的项数反映查询时的未消费项数量。如果存在可能在途使用此缓冲区组中提供的缓冲区的
I/O，则返回值本身存在竞态。

## 返回值

成功时返回未消费项的数量，该值可能为 0。发生错误时，如果指定的缓冲区组不存在，可能
返回 `-ENOENT`；如果该缓冲区组不是正确的类型，或者内核不支持此特性，则可能返回
`-EINVAL`。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md)
