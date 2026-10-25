---
title: io_uring_register_query
section: 3
source_path: man/io_uring_register_query.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: bb63d865d5d7dbbb73a57e0181125b8e9186319f883e16fe7147ece3dfc65c4a
source_copyright: "Copyright (C) 2026 Yitang Yang <yi1tang.yang@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_query(3)

## 名称

io_uring_register_query - 查询 io_uring 能力与特性支持情况

## 概要

```c
#include <liburing.h>

int io_uring_register_query(struct io_uring_query_hdr *query);
```

## 描述

[io_uring_register_query(3)](io_uring_register_query.3.md) 函数查询 io_uring 能力与
特性支持情况，提供受支持操作码、标志以及子系统特定能力的信息。

`query` 参数必须指向描述待执行查询的 `struct io_uring_query_hdr`：

```c
struct io_uring_query_hdr {
    __u64 next_entry;
    __u64 query_data;
    __u32 query_op;
    __u32 size;
    __s32 result;
    __u32 __resv[3];
};
```

`next_entry` 字段可用于将多个查询串联起来。它应指向下一个
`struct io_uring_query_hdr` 结构；如果是链中最后一项，则设置为 0。

`query_data` 字段必须指向适用于 `query_op` 中指定查询类型的数据结构。

`query_op` 字段指定要执行的查询类型，可以是以下值之一：

- `IO_URING_QUERY_OPCODES`：返回受支持操作码和标志的信息。`query_data` 必须指向
  `struct io_uring_query_opcode`，该结构将填入受支持请求操作码、注册操作码、特性
  标志、设置标志、进入标志和 SQE 标志的信息。
- `IO_URING_QUERY_ZCRX`：返回零拷贝接收支持信息。`query_data` 必须指向
  `struct io_uring_query_zcrx`，该结构将填入受支持零拷贝接收标志、特性和配置详情。
- `IO_URING_QUERY_SCQ`：返回 SQ/CQ 环布局信息。`query_data` 必须指向
  `struct io_uring_query_scq`，该结构将填入环头大小和对齐要求。

`size` 字段应设置为 `query_data` 所指向数据结构的大小。

返回时，成功情况下 `result` 字段为 0，失败情况下为负错误码。

保留字段 `__resv` 必须清零。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 注意事项

此函数自 Linux 内核 6.15 起可用。

通过 `next_entry` 字段将多个查询串联，可以在一次系统调用中高效执行多个查询。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
