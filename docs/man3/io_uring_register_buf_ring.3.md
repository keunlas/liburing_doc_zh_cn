---
title: io_uring_register_buf_ring
section: 3
source_path: man/io_uring_register_buf_ring.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 21b1cadef3dda6af0dd881dc13ca2c76c633645919456cfc1fe5b3b0ae9b5649
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_buf_ring(3)

## 名称

io_uring_register_buf_ring - 为提供的缓冲区注册缓冲区环

## 概要

```c
#include <liburing.h>

int io_uring_register_buf_ring(struct io_uring *ring,
                               struct io_uring_buf_reg *reg,
                               unsigned int flags);
```

## 描述

[io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md) 函数注册一个共享
缓冲区环，供提供的缓冲区使用。对于支持该功能的请求类型，提供的缓冲区会被放入环中；
当请求准备好接收数据时，如果在 SQE 的 `flags` 中设置了 `IOSQE_BUFFER_SELECT`，该
请求就会选择其中一个缓冲区。这既能明确缓冲区的生命周期所有权，也能让在途的读取/
接收类型操作数量多于可用缓冲区数量。

`reg` 参数必须填入适当信息。其结构如下：

```c
struct io_uring_buf_reg {
    __u64 ring_addr;
    __u32 ring_entries;
    __u16 bgid;
    __u16 flags;
    __u32 min_left;
    __u32 resv[5];
};
```

`ring_addr` 字段必须包含为容纳此环所分配内存的地址。该内存必须按页对齐，因此应使用
[posix_memalign(3)](https://man7.org/linux/man-pages/man3/posix_memalign.3.html)
或类似方法进行适当分配。环的大小是 `ring_entries` 与 `struct io_uring_buf` 大小的
乘积。`ring_entries` 是环的所需大小，必须是 2 的幂。允许的最大大小为 `2^15`
（32768）。`bgid` 是与该环关联的缓冲区组 ID。选择缓冲区的 SQE 会在其 `buf_group`
字段中关联一个缓冲区组，而相关 CQE 的 `flags` 成员中会设置
`IORING_CQE_F_BUFFER`，其中还会包含所选缓冲区的具体 ID。`min_left` 是增量消费的
缓冲区环中为使缓冲区被视为有效而应保留的最小值。如果未设置，则默认值为单个字节。
该字段仅在 `flags` 中设置了 `IOU_PBUF_RING_INC` 时有效。其余字段均为保留字段，必须
清零。

`flags` 参数可以设置为以下值之一：

- `IOU_PBUF_RING_INC`：此环中的缓冲区可以增量消费。对于部分消费，给定缓冲区 ID 的
  每次完成都会从先前完成停止的位置继续；如果尚未出现任何完成，则从头开始。当应预期
  给定缓冲区 ID 还会出现更多完成时，CQE 的 `flags` 成员中会设置
  `IORING_CQE_F_BUF_MORE`。自 6.12 起可用。

共享缓冲区环的结构如下：

```c
struct io_uring_buf_ring {
    union {
        struct {
            __u64 resv1;
            __u32 resv2;
            __u16 resv3;
            __u16 tail;
        };
        struct io_uring_buf bufs[0];
    };
};
```

其中，`tail` 是应用可插入新缓冲区以供请求消费的索引，`struct io_uring_buf` 是缓冲区
定义：

```c
struct io_uring_buf {
    __u64 addr;
    __u32 len;
    __u16 bid;
    __u16 resv;
};
```

其中，`addr` 是缓冲区地址，`len` 是缓冲区长度（以字节为单位），`bid` 是缓冲区被
消费后会返回到 CQE 中的缓冲区 ID。

不得修改保留字段。应用在使用缓冲区环之前必须使用
[io_uring_buf_ring_init(3)](io_uring_buf_ring_init.3.md) 初始化它。应用可以使用
[io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md) 以及
[io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md) 或
[io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md) 提供缓冲区；
这些函数会设置相关字段并更新尾部。

自 5.19 起可用。

## 返回值

成功时，[io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md) 返回 0。
失败时返回 `-errno`。

## 注意事项

除非需要手动设置，否则建议使用
[io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md)，因为它提供了设置提供的
缓冲区环的更简单方式。

## 参见

- [io_uring_buf_ring_init(3)](io_uring_buf_ring_init.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md)
- [io_uring_buf_ring_advance(3)](io_uring_buf_ring_advance.3.md)
- [io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md)
