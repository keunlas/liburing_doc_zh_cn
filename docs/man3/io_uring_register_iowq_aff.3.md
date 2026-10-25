---
title: io_uring_register_iowq_aff
section: 3
source_path: man/io_uring_register_iowq_aff.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2c3038838bc289ffad51c5b1550688361ce6c067c725a930e261e9bef4a2a70e
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_iowq_aff(3)

## 名称

io_uring_register_iowq_aff - 注册异步工作线程的 CPU 亲和性

## 概要

```c
#include <sched.h>
#include <liburing.h>

int io_uring_register_iowq_aff(struct io_uring *ring,
                               size_t cpusz,
                               const cpu_set_t *mask);

void io_uring_unregister_iowq_aff(struct io_uring *ring);
```

## 描述

[io_uring_register_iowq_aff(3)](io_uring_register_iowq_aff.3.md) 函数注册一组供
io_uring 异步工作线程使用的 CPU 亲和性。默认情况下，允许 io_uring 异步工作线程在系统
中的任意 CPU 上运行。如果将 `ring` 设置为相关环，将 `mask` 设置为指向 `cpu_set_t`
值的指针，并将 `cpusz` 设置为 CPU 集合的大小，然后调用此函数，则异步工作线程将只能
在掩码指定的 CPU 上运行。现有工作线程可能需要到达调度点后才会迁移。

取消注册时，可以调用
[io_uring_unregister_iowq_aff(3)](io_uring_register_iowq_aff.3.md) 将 CPU 亲和性
恢复为默认值。

应用必须定义 `_GNU_SOURCE` 才能获得此辅助函数的定义，因为如果不定义它，就不会定义
`cpu_set_t`。

## 返回值

成功时返回 `0`，发生错误时返回以下任意值：

- `-EFAULT`：由于 `mask` 所指向的内存无效，内核无法复制该内存。
- `-ENOMEM`：内核无法为新 CPU 掩码分配内存。
- `-EINVAL`：`cpusz` 或 `mask` 为 `NULL`/0，或者指定的任何其他值无效。

## 参见

- [io_uring_queue_init(3)](io_uring_queue_init.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
