---
title: io_uring_register_iowq_max_workers
section: 3
source_path: man/io_uring_register_iowq_max_workers.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 49260efaf01d13009987d27cee74fbb72909638d0e738633eb7ecaa23f210b63
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_iowq_max_workers(3)

## 名称

io_uring_register_iowq_max_workers - 修改允许的异步工作线程最大数量

## 概要

```c
#include <liburing.h>

int io_uring_register_iowq_max_workers(struct io_uring *ring,
                                       unsigned int *values);
```

## 描述

io_uring 异步工作线程分为两种类型：

- `Bounded`：这些工作线程具有有界执行时间。例如文件系统读取通常会在较短时间完成。
  即使磁盘发生故障，也会受到超时操作限制；超过该时间后会中止。
- `Unbounded`：这些工作项可能需要不确定的时间才能完成，例如对套接字、管道或任何其他
  非普通文件执行 I/O。

默认情况下，bounded I/O 工作线程数量限制为环设置时的 SQ 项数，或系统中在线 CPU
数量的 4 倍，取二者中较小值。unbounded 工作线程仅受进程任务限制，即 `RLIMIT_NPROC`
限制。

将 `ring` 设置为相关环，并将 `values` 指向包含两个值的数组，即可调用
`io_uring_register_iowq_max_workers` 修改这些限制。第一个元素应包含所需的 bounded
工作线程数量，第二个元素应包含所需的 unbounded 工作线程数量。二者都是最大值；
io_uring 不会维持大量空闲工作线程，它们不再需要时会被回收。

如果两个值都设置为 0 进行调用，则返回现有值。

## 返回值

成功时返回 `0`，`values` 包含设置先前的值。发生错误时，可能返回以下值：

- `-EFAULT`：`values` 指向的内存无效，内核无法复制。
- `-EINVAL`：`values` 为 `NULL`，或者新值超过允许的最大值。

## 参见

- [io_uring_queue_init(3)](io_uring_queue_init.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
