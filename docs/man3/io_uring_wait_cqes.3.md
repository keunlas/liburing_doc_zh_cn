---
title: io_uring_wait_cqes
section: 3
source_path: man/io_uring_wait_cqes.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 5429350abe45732920e3ba7a1689af6b4dad83d0674e5ee95ed7912f58fd6613
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_wait_cqes(3)

## 名称

io_uring_wait_cqes - 等待一个或多个 io_uring 完成事件

## 概要

```c
#include <liburing.h>

int io_uring_wait_cqes(struct io_uring *ring,
                       struct io_uring_cqe **cqe_ptr,
                       unsigned wait_nr,
                       struct __kernel_timespec *ts,
                       sigset_t *sigmask);
```

## 描述

[io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md) 函数从与 `ring` 参数所属的队列中
返回 `wait_nr` 个 I/O 完成事件，必要时会等待这些事件，或者等待到超时 `ts` 到期。

`sigmask` 指定要阻塞的信号集。如果设置了该参数，则等效于原子地执行以下调用：

```c
sigset_t origmask;

pthread_sigmask(SIG_SETMASK, &sigmask, &origmask);
ret = io_uring_wait_cqes(ring, cqe, wait_nr, ts, NULL);
pthread_sigmask(SIG_SETMASK, &origmask, NULL);
```

成功时，`cqe_ptr` 参数会被填入第一个 CQE。此函数的调用方应使用
[io_uring_for_each_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_for_each_cqe.3)
遍历所有可用 CQE。

如果指定了 `ts`，并且使用的是不支持 `IORING_FEAT_EXT_ARG` 的较旧内核，则应用在
调用 [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md) 前不需要调用
[io_uring_submit(3)](io_uring_submit.3.md)。对于设置了该特性标志的较新内核，在等待
请求时不会隐含提交。

如果 `ts` 为 `NULL`，则此函数的行为与
[io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md) 类似，会一直等待事件。

## 返回值

成功时，[io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md) 返回 0，并填入 `cqe_ptr`
参数。失败时返回 `-errno`。如果发生超时，将返回 `-ETIME`。

## 参见

- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_for_each_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_for_each_cqe.3)
- [io_uring_wait_cqe_timeout(3)](io_uring_wait_cqe_timeout.3.md)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
