---
title: io_uring_prep_timeout
section: 3
source_path: man/io_uring_prep_timeout.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 741c026fc628b90aa090f7a06a40a93541511c6c3a701393363a89f94cc2c133
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_timeout(3)

## 名称

io_uring_prep_timeout - 准备一个超时请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_timeout(struct io_uring_sqe *sqe,
                           const struct __kernel_timespec *ts,
                           unsigned count,
                           unsigned flags);
```

## 描述

[io_uring_prep_timeout(3)](io_uring_prep_timeout.3.md) 函数准备一个超时请求。提交
队列项 `sqe` 会被设置为启动由 `ts` 指定的超时，超时计数为 `count` 个完成队列项。
`flags` 参数包含该请求的修饰标志。

此请求类型可以作为一个超时，用来唤醒任何正在 CQ 环上等待事件而休眠的调用方。
`flags` 参数可以包含：

- `IORING_TIMEOUT_ABS`：`ts` 中指定的值是绝对值，而不是相对值。
- `IORING_TIMEOUT_BOOTTIME`：应使用 boottime 时钟源。
- `IORING_TIMEOUT_REALTIME`：应使用 realtime 时钟源。
- `IORING_TIMEOUT_ETIME_SUCCESS`：在已发布完成事件的意义上将超时到期视为成功。这
  意味着它不会像失败请求通常那样切断依赖链接。已发布 CQE 的结果代码仍会在 `res`
  值中包含 `-ETIME`。
- `IORING_TIMEOUT_MULTISHOT`：该请求会返回多个超时完成事件。如果预期还会有更多
  超时，则会设置完成标志 `IORING_CQE_F_MORE`。`count` 中指定的值是重复次数。值为 0
  表示超时无限期有效，只能通过删除请求停止。自 6.4 内核起可用。
- `IORING_TIMEOUT_IMMEDIATE_ARG`：超时值以纳秒值的形式直接存储在 SQE 中，而不是
  作为指向 `struct __kernel_timespec` 的指针。设置此标志时，
  [io_uring_prep_timeout(3)](io_uring_prep_timeout.3.md) 的 `ts` 参数会被重新解释为
  纳秒值（转换为 `__u64`），而不是指针。这避免了必须让 timespec 结构体在用户内存中
  保持有效直到请求提交。自 7.1 内核起可用。

如果上述标志未给出其他时钟源，则使用 `CLOCK_MONOTONIC`。

如果指定的超时已经发生，或者在 CQ 环中已发布指定数量的待等待事件，则超时完成事件
会触发。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时返回 `0`。

- `-ETIME`：指定的超时已发生，并触发了完成事件。
- `-EINVAL`：SQE 中设置的某个字段无效。例如，给出了两个时钟源，或者指定的超时秒数
  或纳秒数小于 0。
- `-EFAULT`：io_uring 无法访问 `ts` 指定的数据。
- `-ECANCELED`：该超时被删除请求取消。

## 注意事项

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_timeout_remove(3)](io_uring_prep_timeout_update.3.md)
- [io_uring_prep_timeout_update(3)](io_uring_prep_timeout_update.3.md)
