---
title: io_uring_register_region
section: 3
source_path: man/io_uring_register_region.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b91ba4c9b464dd41080d318095adc7363cc8c4bbcafbeb255d34c93a4623f317
source_copyright: "Copyright (C) 2026 Pavel Begunkov <asml.silence@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_region(3)

## 名称

io_uring_register_region - 注册内存区域

## 概要

```c
#include <liburing.h>

int io_uring_register_region(struct io_uring *ring,
                             struct io_uring_mem_region_reg *reg);
```

## 描述

[io_uring_register_region(3)](io_uring_register_region.3.md) 函数向 io_uring 注册
内存区域。成功完成后，该内存区域便可用于多种用途；例如，可更高效地向
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
系统调用传递等待参数，因为这样避免了为每个等待事件复制等待相关数据。`ring` 参数应
指向相关环，`reg` 参数应指向 `struct io_uring_mem_region_reg`。

`reg` 参数必须填入适当信息，其结构如下：

```c
struct io_uring_mem_region_reg {
    __u64 region_uptr;
    __u64 flags;
    __u64 __resv[2];
};
```

`region_uptr` 字段必须包含指向适当填充的 `struct io_uring_region_desc` 的指针。

`flags` 字段必须包含以下值的位掩码：

- `IORING_MEM_REGION_REG_WAIT_ARG`：允许使用该区域向
  [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
  系统调用传递等待参数。如果设置此标志，则只允许在环处于禁用模式时注册。请参见
  `IORING_SETUP_R_DISABLED`。

`__resv` 字段必须填入 0。

`struct io_uring_region_desc` 定义如下：

```c
struct io_uring_region_desc {
    __u64 user_addr;
    __u64 size;
    __u32 flags;
    __u32 id;
    __u64 mmap_offset;
    __u64 __resv[4];
};
```

`user_addr` 字段必须包含用户希望注册的内存指针。该字段仅在设置了
`IORING_MEM_REGION_TYPE_USER` 时有效，否则应为 0。

`size` 字段应包含区域大小。

`flags` 字段必须包含以下值的位掩码：

- `IORING_MEM_REGION_TYPE_USER`：告知内核使用 `user_addr` 字段指定的内存。如果未
  设置，内核将为该区域分配内存，随后可将其映射到用户空间。

使用内核提供的内存成功注册区域后，`mmap_offset` 字段会包含一个可传给
[mmap(2)](https://man7.org/linux/man-pages/man2/mmap.2.html) 系统调用的偏移量，以便
将区域映射到用户空间。

`id` 字段为保留字段，必须设置为 0。

`__resv` 字段必须填入 0。

自内核 6.13 起可用。

## 返回值

成功时，[io_uring_register_region(3)](io_uring_register_region.3.md) 返回 0。失败
时返回 `-errno`。
