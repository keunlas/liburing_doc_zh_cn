---
title: io_uring_submit
section: 3
source_path: man/io_uring_submit.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: cd89f47ade1061a71e8a3c56c2822b9117017980ec118a3fd64e90ec31653d43
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_submit(3)

## 名称

io_uring_submit - 向提交队列提交请求

## 概要

```c
#include <liburing.h>

int io_uring_submit(struct io_uring *ring);
```

## 描述

[io_uring_submit(3)](io_uring_submit.3.md) 函数将与 `ring` 所属的提交队列中的下一
批事件提交。

调用方通过
[io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
取得提交队列项（SQE），并使用某个提供的辅助函数准备好该 SQE 后，可以通过
[io_uring_submit(3)](io_uring_submit.3.md) 提交它。

## 返回值

成功时，如果不使用 SQPOLL，[io_uring_submit(3)](io_uring_submit.3.md) 返回已提交的
提交队列项数量。如果使用 SQPOLL，返回值报告的已提交项数量可能高于实际提交的数量。
如果使用 SQPOLL 时用户需要已成功提交的提交队列项数量的准确信息，则必须回退为反复
提交单个提交队列项。失败时返回 `-errno`。有关
[io_uring_submit(3)](io_uring_submit.3.md) 可能返回的错误码详情，请参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。

## 注意事项

对于任何在结构体中传入数据的请求，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_queue_init.3)
返回的 `IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。通常，如果给定命令有此
要求，各个 prep 辅助函数的手册页也会包含一条说明此事实的注意事项。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit_and_wait(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait.3)
- [io_uring_submit_and_wait_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_timeout.3)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
