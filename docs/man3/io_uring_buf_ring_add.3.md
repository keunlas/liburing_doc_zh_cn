---
title: io_uring_buf_ring_add
section: 3
source_path: man/io_uring_buf_ring_add.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: fac3e48831a253f9c402388be42fc00cd727362e49798bdff21230aea810f545
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_buf_ring_add(3)

## 名称

io_uring_buf_ring_add - 向共享缓冲区环添加缓冲区

## 概要

```c
#include <liburing.h>

void io_uring_buf_ring_add(struct io_uring_buf_ring *br,
                           void *addr,
                           unsigned int len,
                           unsigned short bid,
                           int mask,
                           int buf_offset);
```

## 描述

[io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md) 向共享缓冲区环 `br` 添加一个
新缓冲区。缓冲区地址由 `addr` 指示，长度为 `len` 字节。`bid` 是缓冲区 ID，它会在 CQE
中返回。`mask` 是环的大小掩码，可从
[io_uring_buf_ring_mask(3)](io_uring_buf_ring_mask.3.md) 获取。`buf_offset` 是从当前
尾部插入时的偏移量。如果只提供一个缓冲区，随后就通过
[io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md) 或
[io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md) 提交环尾，则
`buf_offset` 应为 0。如果在提交前循环提供多个缓冲区，则每添加一个缓冲区，
`buf_offset` 都必须递增 1。

## 返回值

无。

## 注意事项

liburing（或就此而言，内核）并不关心哪个缓冲区 ID 映射到哪个缓冲区；事实上，在复用
使用过的缓冲区时，应用可以自由地将不同的缓冲区添加到同一个缓冲区 ID 位置。重要的是
应用知道某个缓冲区 ID 在当时对应哪段虚拟内存。liburing 或内核都不假定这些映射会长期
保持不变；每次将某个缓冲区 ID 添加到提供的缓冲区环时，这种映射都可以不同。

请注意，任何 uring 函数单次调用最多只能向缓冲区写入 `INT_MAX` 字节。详情请参见各个
函数的手册页。

## 参见

- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_buf_ring_mask(3)](io_uring_buf_ring_mask.3.md)
- [io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md)
- [io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md)
