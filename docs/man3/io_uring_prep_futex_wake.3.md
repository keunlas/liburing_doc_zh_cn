---
title: io_uring_prep_futex_wake
section: 3
source_path: man/io_uring_prep_futex_wake.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: fe94470f536513046a499ffa617869a53d916495e0c79add219fa4c705cec7e0
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_futex_wake(3)

## 名称

io_uring_prep_futex_wake - 准备一个 futex 唤醒请求

## 概要

```c
#include <linux/futex.h>
#include <unistd.h>
#include <liburing.h>

void io_uring_prep_futex_wake(struct io_uring_sqe *sqe,
                              const uint32_t *futex,
                              uint64_t val,
                              uint64_t mask,
                              uint32_t futex_flags,
                              unsigned int flags);
```

## 描述

[io_uring_prep_futex_wake(3)](io_uring_prep_futex_wake.3.md) 函数准备一个 futex
唤醒请求。提交队列项 `sqe` 会被设置为唤醒 `futex` 所指示 futex 上的任意等待者，最多
唤醒 `val` 个 futex。`futex_flags` 表示
[futex2(2)](https://man7.org/linux/man-pages/man2/futex.2.html) 修饰标志，`flags`
表示 io_uring futex 标志。

如果需要指定要唤醒对象的位集，则必须在 `mask` 中设置。使用
`FUTEX_BITSET_MATCH_ANY` 匹配给定 futex 上的任意等待者。

`flags` 目前未使用，因此必须传入 `0`。

此函数准备一个异步
[futex(2)](https://man7.org/linux/man-pages/man2/futex.2.html) 唤醒请求。详情请参见
该手册页。请注意，io_uring futex 唤醒请求类似于 `FUTEX_WAKE_BITSET` 操作，因为
`FUTEX_WAKE` 是该操作的严格子集。

自内核 6.7 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。成功时，该值是 `futexv` 中接收到唤醒的索引。有关
可能错误值的详情，请参见相关手册页。请注意，同步系统调用失败时会返回 `-1`，并将
`errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是直接在 CQE 的 `res` 字段中
返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_futex_wait(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_prep_futex_wait.3)
- [io_uring_prep_futex_waitv(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_prep_futex_waitv.3)
- [futex(2)](https://man7.org/linux/man-pages/man2/futex.2.html)
- [futex2(2)](https://man7.org/linux/man-pages/man2/futex.2.html)
