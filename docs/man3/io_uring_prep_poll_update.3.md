---
title: io_uring_prep_poll_update
section: 3
source_path: man/io_uring_prep_poll_update.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 9fc3d4339b533380f4afba7f71b5efe9e7e9eaa6ffe240b9d77299072e2413af
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_poll_update(3)

## 名称

io_uring_prep_poll_update - 更新一个现有的 poll 请求

## 概要

```c
#include <poll.h>
#include <liburing.h>

void io_uring_prep_poll_update(struct io_uring_sqe *sqe,
                               __u64 old_user_data,
                               __u64 new_user_data,
                               unsigned poll_mask,
                               unsigned flags);
```

## 描述

[io_uring_prep_poll_update(3)](io_uring_prep_poll_update.3.md) 函数准备一个 poll 更新
请求。提交队列项 `sqe` 会被设置为更新由 `old_user_data` 标识的 poll 请求，并用
`new_user_data` 信息替换它。`poll_mask` 参数包含要用于该 poll 请求的新掩码，
`flags` 参数包含修饰标志，用于告知 io_uring 要更新哪些字段。

`flags` 修饰标志是一个位掩码，可以包含以下值的按位或：

- `IORING_POLL_UPDATE_EVENTS`：如果设置，poll 更新请求会将正在等待的现有事件替换为
  函数 `poll_mask` 参数中指定的事件。请注意，只能更新事件的低 16 位。这包括
  `EPOLLIN` 和 `EPOLLOUT` 等内容。更高位序的掩码和设置属于内部状态，不能修改。
  这包括 `EPOLLONESHOT`、`EPOLLEXCLUSIVE` 和 `EPOLLET` 等设置。如果应用希望修改
  这些设置，必须取消或删除现有 poll 请求，并设置一个新的 poll 请求。
- `IORING_POLL_UPDATE_USER_DATA`：如果设置，poll 更新请求会用 `new_user_data` 参数
  传入的值更新该请求现有的 `user_data`。
- `IORING_POLL_ADD_MULTI`：如果设置，会将 poll 请求从单次触发改为多轮触发请求。
  此标志必须与 `IORING_POLL_UPDATE_EVENTS` 一起使用，因为必须更新事件字段才能启用
  多轮触发。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时返回 `0`。

- `-ENOENT`：无法找到由 `user_data` 标识的请求。这可能是因为该请求在取消请求发出
  之前已经完成，或者使用了无效标识符。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-EALREADY`：请求的执行状态已经推进得太远，无法再取消。这通常意味着该请求将很快
  完成，可能是成功完成，也可能是因本次取消而中断。
- `-ECANCELED`：设置了 `IORING_POLL_UPDATE_EVENTS`，并且使用新掩码重新设置 poll
  请求时发生错误。如果发生这种情况，原 poll 请求会被终止，并且该终止 CQE 会包含
  重新设置时发生错误的原因。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_poll_add(3)](io_uring_prep_poll_add.3.md)
- [io_uring_prep_poll_multishot(3)](io_uring_prep_poll_add.3.md)
