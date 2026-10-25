---
title: io_uring_submit_and_wait_timeout
section: 3
source_path: man/io_uring_submit_and_wait_timeout.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 19e16c81c4b9212e0b86f4ad94ef4b3ddd16627e8a0e1c61685af9886be90086
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_submit_and_wait_timeout(3)

## 名称

io_uring_submit_and_wait_timeout - 提交请求并在带超时的情况下等待完成

## 概要

```c
#include <liburing.h>

int io_uring_submit_and_wait_timeout(struct io_uring *ring,
                                     struct io_uring_cqe **cqe_ptr,
                                     unsigned wait_nr,
                                     struct __kernel_timespec *ts,
                                     sigset_t *sigmask);
```

## 描述

[io_uring_submit_and_wait_timeout(3)](io_uring_submit_and_wait_timeout.3.md) 函数提交
与 `ring` 所属提交队列中的下一批请求，并等待 `wait_nr` 个完成事件，或者等待到超时 `ts`
到期。完成事件存储在 `cqe_ptr` 数组中。

`sigmask` 指定要阻塞的信号集。如果设置了该参数，则等效于原子地执行以下调用：

```c
sigset_t origmask;

pthread_sigmask(SIG_SETMASK, &sigmask, &origmask);
ret = io_uring_submit_and_wait_timeout(ring, cqe, wait_nr, ts, NULL);
pthread_sigmask(SIG_SETMASK, &origmask, NULL);
```

调用方通过
[io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
取得提交队列项（SQE）并准备好该 SQE 后，可以使用
[io_uring_submit_and_wait_timeout(3)](io_uring_submit_and_wait_timeout.3.md) 提交它。

理想情况下，应与使用
`IORING_SETUP_SINGLE_ISSUER | IORING_SETUP_DEFER_TASKRUN` 设置的环配合使用，因为
这会大幅减少应用等待多个请求时出现的上下文切换次数。

## 返回值

成功时，[io_uring_submit_and_wait_timeout(3)](io_uring_submit_and_wait_timeout.3.md)
返回已提交的提交队列项数量。失败时返回 `-errno`。可能错误码的详情请参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。
除此之外，如果在指定时间范围内未收到完成事件，此函数还可能返回 `-ETIME`；如果队列
已满并且无法将超时请求入队，则可能返回 `-EAGAIN`。请注意，在较早版本的 liburing
库中，成功时返回值为 0。

## 参见

- [io_uring_queue_init_params(3)](io_uring_queue_init.3.md)
- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_submit_and_wait(3)](io_uring_submit_and_wait.3.md)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
