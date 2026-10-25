---
title: io_uring_buf_ring_cq_advance
section: 3
source_path: man/io_uring_buf_ring_cq_advance.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: f671697809a412ea156f96f195fa6828c7caaa98b897d8717599e8e77edcbeb8
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_buf_ring_cq_advance(3)

## 名称

io_uring_buf_ring_cq_advance - 推进提供的缓冲区环和 CQ 环的索引

## 概要

```c
#include <liburing.h>

void io_uring_buf_ring_cq_advance(struct io_uring *ring,
                                  struct io_uring_buf_ring *br,
                                  int count);

void __io_uring_buf_ring_cq_advance(struct io_uring *ring,
                                    struct io_uring_buf_ring *br,
                                    int cq_count,
                                    int buf_count);
```

## 描述

[io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md) 将先前添加到
共享缓冲区环 `br` 的 `count` 个缓冲区提交，使它们对内核可见，因而可供消费。这会将
缓冲区的所有权移交给环。同时，它会把 `ring` 的 CQ 环推进 `count` 个项。这实际上将
[io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md) 调用和
[io_uring_cq_advance(3)](io_uring_cq_advance.3.md) 合并为一个操作。由于更新任一环
索引都会涉及存储内存屏障，同时完成两者的效率更高。

[__io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md) 函数执行相同
操作，区别在于它将计数拆分为两个独立的值。它会把 CQ 环推进 `cq_count` 个项，并将
缓冲区环推进 `buf_count` 个项，而不是将两者递增相同的值。

## 返回值

无。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md)
