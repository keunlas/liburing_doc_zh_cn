---
title: io_uring_resize_rings
section: 3
source_path: man/io_uring_resize_rings.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 4e2cfe0e346d0af6be9999e4a990c7d3fcd3f8c25eab9897e77c98bf2ea3e1aa
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_resize_rings(3)

## 名称

io_uring_resize_rings - 调整 SQ 环和 CQ 环的大小

## 概要

```c
#include <liburing.h>

int io_uring_resize_rings(struct io_uring *ring,
                          struct io_uring_params *p);
```

## 描述

[io_uring_resize_rings(3)](io_uring_resize_rings.3.md) 函数根据 `p` 中指定的参数，
调整与 `ring` 关联的 SQ 环和/或 CQ 环大小。

`p` 参数必须填入调整操作的适当信息，尤其是必须填写 `sq_entries` 和 `cq_entries`
字段。也可以设置 `flags` 字段；下面列出可用于调整操作的潜在值。

需要调整 SQ 环并不常见，但需要调整 CQ 环并不那么罕见。对于网络工作负载，事先为 CQ
环设置合适大小可能很困难，因为并不总能预知给定环将会承受的负载。如果 CQ 环出现溢出
情况，则将其调大可能是好办法。

调整环大小时，任何待处理的 SQ 或 CQ 项都会相应复制。禁止调整处于溢出状态的 CQ 环；
尝试这样做会失败。

目前不支持调整使用 `IORING_SETUP_NO_MMAP` 设置的环。这纯粹是 liburing 的限制，
内核本身支持该操作。

另请注意，环大小调整目前仅在通过 `IORING_SETUP_DEFER_TASKRUN` 设置的环上受支持。
尝试调整其他配置的环将以 `-EINVAL` 错误失败。

`flags` 中的有效标志：

- `IORING_SETUP_CQSIZE`：如果未设置，CQ 环大小将根据指定的 SQ 环大小设置。默认情况
  下，CQ 环项数是 SQ 环项数的两倍。如果设置，则使用 `cq_entries` 设置 CQ 环大小。
- `IORING_SETUP_CLAMP`：如果设置，当 SQ 和 CQ 环项数超过允许的最大大小时，会将其
  限制到最大值。如果未设置，设置过大的大小将导致操作失败。

其他标志会从环的设置方式继承，包括 `IORING_SETUP_NO_SQARRAY`、
`IORING_SETUP_SQE128`、`IORING_SETUP_CQE32` 和 `IORING_SETUP_NO_MMAP` 等标志。

`p` 中的其他字段应清零。

自内核 6.13 起可用。

设置标志的详细说明另请参见
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)。

## 返回值

成功时返回 0，失败时返回小于 0 的值。可能的常见失败情况如下：

- `-EEXIST`：尝试调整使用 `IORING_SETUP_SINGLE_ISSUER` 设置的环，但执行调整的任务
  与创建/启用该环的任务不同。
- `-EFAULT`：复制 `p` 失败。
- `-EINVAL`：为操作指定了无效标志。
- `-EINVAL`：尝试调整未使用 `IORING_SETUP_DEFER_TASKRUN` 设置的环。
- `-EOVERFLOW`：SQ 或 CQ 项数的指定值会导致溢出。

## 参见

- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
