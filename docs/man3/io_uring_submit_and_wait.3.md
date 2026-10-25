---
title: io_uring_submit_and_wait
section: 3
source_path: man/io_uring_submit_and_wait.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b837de7f2719356c0d4f4419c3ad59206632a20ea8fde62fa8a3d0dbc464a90a
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_submit_and_wait(3)

## 名称

io_uring_submit_and_wait - 向提交队列提交请求并等待完成

## 概要

```c
#include <liburing.h>

int io_uring_submit_and_wait(struct io_uring *ring,
                             unsigned wait_nr);
```

## 描述

[io_uring_submit_and_wait(3)](io_uring_submit_and_wait.3.md) 函数提交与 `ring` 所属
提交队列中的下一批请求，并等待 `wait_nr` 个完成事件。

调用方通过
[io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
取得提交队列项（SQE）并准备好该 SQE 后，可以使用
[io_uring_submit_and_wait(3)](io_uring_submit_and_wait.3.md) 提交它。

理想情况下，应与使用
`IORING_SETUP_SINGLE_ISSUER | IORING_SETUP_DEFER_TASKRUN` 设置的环配合使用，因为
这会大幅减少应用等待多个请求时出现的上下文切换次数。

## 返回值

成功时，[io_uring_submit_and_wait(3)](io_uring_submit_and_wait.3.md) 返回已提交的
提交队列项数量。失败时返回 `-errno`。有关
[io_uring_submit_and_wait(3)](io_uring_submit_and_wait.3.md) 可能返回的错误码详情，请
参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。

## 参见

- [io_uring_queue_init_params(3)](io_uring_queue_init.3.md)
- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_submit_and_wait_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_timeout.3)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
