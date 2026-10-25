---
title: io_uring_prep_poll_remove
section: 3
source_path: man/io_uring_prep_poll_remove.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2dca04f2f6054c7b7c814690328aa142ef094732523a370cef314874c899ae12
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_poll_remove(3)

## 名称

io_uring_prep_poll_remove - 准备一个 poll 删除请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_poll_remove(struct io_uring_sqe *sqe,
                               __u64 user_data);
```

## 描述

[io_uring_prep_poll_remove(3)](io_uring_prep_poll_remove.3.md) 函数准备一个 poll
删除请求。提交队列项 `sqe` 会被设置为删除由 `user_data` 标识的 poll 请求。

其工作方式与
[io_uring_prep_cancel(3)](io_uring_prep_cancel.3.md) 类似，区别在于它只查找 poll
请求。除此之外，行为完全相同。具体详情请参见该手册页。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时返回 `0`。

- `-ENOENT`：无法找到由 `user_data` 标识的请求。这可能是因为该请求在取消请求发出
  之前已经完成，或者使用了无效标识符。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-EALREADY`：请求的执行状态已经推进得太远，无法再取消。这通常意味着该请求将很快
  完成，可能是成功完成，也可能是因本次取消而中断。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_cancel(3)](io_uring_prep_cancel.3.md)
