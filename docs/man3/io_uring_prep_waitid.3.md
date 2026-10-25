---
title: io_uring_prep_waitid
section: 3
source_path: man/io_uring_prep_waitid.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b01e42180486cccab546ef30db3d87859ae1cf5833846207b87443aa60a1bb43
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_waitid(3)

## 名称

io_uring_prep_waitid - 准备一个 waitid 请求

## 概要

```c
#include <sys/wait.h>
#include <liburing.h>

void io_uring_prep_waitid(struct io_uring_sqe *sqe,
                          idtype_t idtype,
                          id_t id,
                          siginfo_t *infop,
                          int options,
                          unsigned int flags);
```

## 描述

[io_uring_prep_waitid(3)](io_uring_prep_waitid.3.md) 函数准备一个 waitid 请求。提交
队列项 `sqe` 会被设置为使用 `idtype` 和 `id` 参数选择子进程，并使用 `options` 指定
要等待的子进程状态变化。成功返回时，如果存在子进程信息，则会将子进程信息填入
`infop`。`flags` 是 io_uring 专用的修饰标志。它们目前未使用，因此应传入 `0`。

此函数准备一个异步
[waitid(2)](https://man7.org/linux/man-pages/man2/waitid.2.html) 请求。详情请参见
该手册页。

自内核 6.7 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [waitid(2)](https://man7.org/linux/man-pages/man2/waitid.2.html)
