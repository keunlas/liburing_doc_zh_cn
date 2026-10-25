---
title: io_uring_register_sync_cancel
section: 3
source_path: man/io_uring_register_sync_cancel.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: eb09dc9d3bb5d74d9cc758f6f1aa434dbfcbe5b7f81b225ff47933d4c055c369
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_sync_cancel(3)

## 名称

io_uring_register_sync_cancel - 发出同步取消请求

## 概要

```c
#include <liburing.h>

int io_uring_register_sync_cancel(struct io_uring *ring,
                                  struct io_uring_sync_cancel_reg *reg);
```

## 描述

[io_uring_register_sync_cancel(3)](io_uring_register_sync_cancel.3.md) 函数根据
`reg` 指定的参数执行同步取消请求。

`reg` 参数必须填入取消请求的适当信息。其结构如下：

```c
struct io_uring_sync_cancel_reg {
    __u64 addr;
    __s32 fd;
    __u32 flags;
    struct __kernel_timespec timeout;
    __u8 opcode;
    __u8 pad[7];
    __u64 pad2[3];
};
```

这些参数大体上与异步 prep 函数支持的内容相同，详情请参见
[io_uring_prep_cancel(3)](io_uring_prep_cancel.3.md)。返回值也相同。例外是
`timeout` 参数，它可用于限制内核等待取消成功的时间。如果 `tv_sec` 和 `tv_nsec`
设置为除 `-1UL` 以外的任何值，则它们表示取消应完成的相对超时时间。

`pad` 值必须填充为 0。

## 返回值

返回值的详情请参见 [io_uring_prep_cancel(3)](io_uring_prep_cancel.3.md)。如果
`timeout` 设置为指示超时，则超时后会返回 `-ETIME`。如果请求中设置了未知值，或者
pad 值未清零，则返回 `-EINVAL`。

## 参见

- [io_uring_prep_cancel(3)](io_uring_prep_cancel.3.md)
