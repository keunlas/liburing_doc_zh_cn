---
title: io_uring_submit_and_wait_min_timeout
section: 3
source_path: man/io_uring_submit_and_wait_min_timeout.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 12cb47edb23fce3eb5ae54e530eb3e66b82b9a8492bdd1981e273bc59feb400d
source_copyright: "Copyright (C) 2024 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_submit_and_wait_min_timeout(3)

## 名称

io_uring_submit_and_wait_min_timeout - 提交请求，并使用批量超时和普通超时等待完成

## 概要

```c
#include <liburing.h>

int io_uring_submit_and_wait_min_timeout(struct io_uring *ring,
                                         struct io_uring_cqe **cqe_ptr,
                                         unsigned wait_nr,
                                         struct __kernel_timespec *ts,
                                         unsigned int min_wait_usec,
                                         sigset_t *sigmask);
```

## 描述

[io_uring_submit_and_wait_min_timeout(3)](io_uring_submit_and_wait_min_timeout.3.md)
函数提交与 `ring` 所属提交队列中的下一批请求，并等待 `wait_nr` 个完成事件，或者等待
到超时 `ts` 到期。完成事件存储在 `cqe_ptr` 数组中。如果 `min_wait_usec` 非零，它表示
`wait_nr` 批次的超时。

`sigmask` 指定要阻塞的信号集。如果设置了该参数，则等效于原子地执行以下调用：

```c
sigset_t origmask;

pthread_sigmask(SIG_SETMASK, &sigmask, &origmask);
ret = io_uring_submit_and_wait_min_timeout(ring, cqe, wait_nr, ts, min_wait, NULL);
pthread_sigmask(SIG_SETMASK, &origmask, NULL);
```

其工作方式与
[io_uring_submit_and_wait_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_timeout.3)
类似，区别在于它为要等待的请求批次大小设置了最小超时。虽然
[io_uring_submit_and_wait_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_timeout.3)
会等待 `ts` 指定的时间，或者直到收到 `wait_nr` 个请求完成；如果设置了
`min_wait_usec`，则它是 `wait_nr` 个请求的超时。如果在 `min_wait_usec` 微秒内收到
所需数量的完成事件，函数会成功返回。否则，在 `min_wait_usec` 时间过去后，如果已发布
任何完成事件，则立即返回控制权。如果未发布任何完成事件，内核会切换为普通等待，最长
等待 `ts` 指定的时间，并减去已经等待的时间。如果在此之后发布了任何完成事件，控制权
会立即返回应用。

这与普通超时等待的区别在于：仅当未发布任何完成事件时，初始超时之后仍继续等待。它用于
优化请求的批量等待：应用分配 `min_wait_usec` 时间来接收 `wait_nr` 个完成事件，但如果
一个都未收到，则可以继续等待，而不会产生额外的上下文切换或内核/用户态切换。

只要内核支持，此函数可用于任意环。支持情况可通过在环设置后检查
`IORING_FEAT_MIN_TIMEOUT` 特性标志来确定。理想情况下，应与使用
`IORING_SETUP_SINGLE_ISSUER | IORING_SETUP_DEFER_TASKRUN` 设置的环配合使用，因为
这会大幅减少应用等待多个请求时出现的上下文切换次数。

自 6.12 起可用。

## 返回值

成功时，[io_uring_submit_and_wait_min_timeout(3)](io_uring_submit_and_wait_min_timeout.3.md)
返回已提交的提交队列项数量。失败时返回 `-errno`。如果内核不支持此功能，则返回
`-EINVAL`。请参见有关特性标志的说明。其他可能错误码的详情请参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。
除此之外，如果在指定时间范围内未收到完成事件，此函数还可能返回 `-ETIME`。

## 参见

- [io_uring_queue_init_params(3)](io_uring_queue_init.3.md)
- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_submit_and_wait(3)](io_uring_submit_and_wait.3.md)
- [io_uring_submit_and_wait_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_timeout.3)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
