---
title: io_uring_prep_timeout_update
section: 3
source_path: man/io_uring_prep_timeout_update.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2f3a5d46123d4ebb38a4d5b77b3e37eef26eb71687ee25665405ed855d9f135a
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_timeout_update(3)

## 名称

io_uring_prep_timeout_update - 准备一个更新现有超时的请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_timeout_update(struct io_uring_sqe *sqe,
                                  const struct __kernel_timespec *ts,
                                  __u64 user_data,
                                  unsigned flags);

void io_uring_prep_timeout_remove(struct io_uring_sqe *sqe,
                                  __u64 user_data,
                                  unsigned flags);
```

## 描述

这些函数修改或取消一个现有的超时请求。提交队列项 `sqe` 会被设置为启动由 `user_data`
指定的超时更新或删除，并使用 `flags` 给出的修饰标志。此外，更新请求包含一个 `ts`
结构体，其中带有新的超时信息。

对于更新请求，`flags` 成员可以包含以下值的位掩码：

- `IORING_TIMEOUT_ABS`：`ts` 中指定的值是绝对值，而不是相对值。

超时删除命令目前不接受任何标志。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时返回 `0`。

- `-ENOENT`：无法找到由 `user_data` 标识的超时。它可能无效，或者已在更新或删除请求
  得到处理之前触发。
- `-EALREADY`：由 `user_data` 标识的超时已处于触发过程中，无法取消。
- `-EINVAL`：SQE 中设置的某个字段无效。例如，给出了两个时钟源，或者指定的超时秒数
  或纳秒数小于 0。
- `-EFAULT`：io_uring 无法访问 `ts` 指定的数据。

## 注意事项

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_timeout(3)](io_uring_prep_timeout.3.md)
