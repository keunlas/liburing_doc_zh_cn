---
title: io_uring_wait_cqes_min_timeout
section: 3
source_path: man/io_uring_wait_cqes_min_timeout.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 43b5ca9d48b727c60e83a14ec580b73ed69557321e574123ff5cad32064d0505
source_copyright: "Copyright (C) 2024 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_wait_cqes_min_timeout(3)

## 名称

io_uring_wait_cqes_min_timeout - 使用批量超时和普通超时等待完成事件

## 概要

```c
#include <liburing.h>

int io_uring_wait_cqes_min_timeout(struct io_uring *ring,
                                   struct io_uring_cqe **cqe_ptr,
                                   unsigned wait_nr,
                                   struct __kernel_timespec *ts,
                                   unsigned int min_wait_usec,
                                   sigset_t *sigmask);
```

## 描述

[io_uring_wait_cqes_min_timeout(3)](io_uring_wait_cqes_min_timeout.3.md) 等待与
`ring` 所属提交队列的完成事件，等待 `wait_nr` 个完成事件，或者等待到超时 `ts` 到期。
完成事件存储在 `cqe_ptr` 数组中。如果 `min_wait_usec` 非零，它表示 `wait_nr` 批次的
超时。

`sigmask` 指定要阻塞的信号集。如果设置了该参数，则等效于原子地执行以下调用：

```c
sigset_t origmask;

pthread_sigmask(SIG_SETMASK, &sigmask, &origmask);
ret = io_uring_wait_cqes_min_timeout(ring, cqe, wait_nr, ts, min_wait, NULL);
pthread_sigmask(SIG_SETMASK, &origmask, NULL);
```

其工作方式与
[io_uring_submit_and_wait_min_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_min_timeout.3)
类似，区别在于不提交请求。有关最小超时等待工作方式的说明，请参见该手册页。

自 6.12 起可用。

## 返回值

成功时，[io_uring_wait_cqes_min_timeout(3)](io_uring_wait_cqes_min_timeout.3.md) 返回
0。失败时返回 `-errno`。如果内核不支持此功能，则返回 `-EINVAL`。请参见有关特性标志的
说明。最常见的失败情况是在指定超时内未收到完成事件，此时会返回 `-ETIME`。

## 参见

- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
- [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md)
- [io_uring_wait_cqe_timeout(3)](io_uring_wait_cqe_timeout.3.md)
- [io_uring_submit_and_wait_min_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_min_timeout.3)
