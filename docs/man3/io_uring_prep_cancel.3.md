---
title: io_uring_prep_cancel
section: 3
source_path: man/io_uring_prep_cancel.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2d68eabbc809daa08d8ccd1394ca1de72079b926abb1d04c921ef1fae0483b7a
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_cancel(3)

## 名称

io_uring_prep_cancel - 准备一个取消请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_cancel64(struct io_uring_sqe *sqe,
                            __u64 user_data,
                            int flags);

void io_uring_prep_cancel(struct io_uring_sqe *sqe,
                          const void *user_data,
                          int flags);

void io_uring_prep_cancel_fd(struct io_uring_sqe *sqe,
                          int fd,
                          unsigned int flags);
```

## 描述

[io_uring_prep_cancel(3)](io_uring_prep_cancel.3.md) 函数准备一个取消请求。提交队列
项 `sqe` 会被设置为取消由 `user_data` 标识的现有请求。有关 `flags` 参数，请参见
下文。

[io_uring_prep_cancel64(3)](io_uring_prep_cancel.3.md) 与
[io_uring_prep_cancel(3)](io_uring_prep_cancel.3.md) 相同，区别在于它接受 64 位整数，
而不是指针类型。

取消请求会尝试找到先前发出、由 `user_data` 标识的请求，并取消它。该标识符就是先前
发出的请求在其 SQE 的 `user_data` 字段中设置的值。

[io_uring_prep_cancel_fd(3)](io_uring_prep_cancel.3.md) 函数准备一个取消请求。提交
队列项 `sqe` 会被设置为取消使用文件描述符 `fd` 的现有请求。有关 `flags` 参数，请
参见下文。

取消请求会尝试找到先前发出、使用 `fd` 作为文件描述符的请求，并取消它。

默认情况下，会取消第一个符合给定条件的请求。可以通过传入以下任意标志来修改此行为：

- `IORING_ASYNC_CANCEL_ALL`：取消所有符合给定条件的请求，而不只是取消找到的第一个
  请求。自 5.19 起可用。
- `IORING_ASYNC_CANCEL_FD`：根据原请求中使用的文件描述符匹配，而不是根据
  `user_data` 匹配。这正是 [io_uring_prep_cancel_fd(3)](io_uring_prep_cancel.3.md)
  所设置的匹配方式。自 5.19 起可用。
- `IORING_ASYNC_CANCEL_FD_FIXED`：与 `IORING_ASYNC_CANCEL_FD` 一起设置，表示给定的
  文件描述符是直接描述符，而不是普通文件描述符。自 6.0 起可用。
- `IORING_ASYNC_CANCEL_ANY`：匹配环中的任意请求，而不考虑 `user_data` 或文件描述符。
  可用于取消环中的任意待处理请求。自 5.19 起可用。
- `IORING_ASYNC_CANCEL_USERDATA`：根据原请求中设置的 `user_data` 字段匹配请求。如果
  未指定其他匹配键，这是默认查找键。自 6.6 起可用。
- `IORING_ASYNC_CANCEL_OP`：使用原请求的操作码作为匹配键。请求的操作码必须在使用
  某个通用取消准备辅助函数后，设置到 SQE 的 `len` 字段中。自 6.6 起可用。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。如果未使用标志来取消多个请求，成功时返回
`0`。如果使用标志匹配多个请求，则返回一个正值，表示找到并取消了请求的数量。

- `-ENOENT`：无法找到由 `user_data` 标识的请求。这可能是因为该请求在取消请求发出
  之前已经完成，或者使用了无效标识符。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-EALREADY`：请求的执行状态已经推进得太远，无法再取消。这通常意味着该请求将很快
  完成，可能是成功完成，也可能是因本次取消而中断。

## 注意事项

尽管取消请求使用异步请求语法，但内核侧的取消操作始终同步运行。可以保证在取消请求
提交完成时，CQE 一定已经生成。如果取消成功，那么在提交返回时，被取消目标的完成事件
已经发布。对于 `-EALREADY`，发布完成事件可能需要一点时间。在这种情况下，调用方
必须等待被取消的请求发布其完成事件。

## 参见

- [io_uring_prep_poll_remove(3)](io_uring_prep_poll_remove.3.md)
- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
