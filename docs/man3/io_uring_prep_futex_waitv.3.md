---
title: io_uring_prep_futex_waitv
section: 3
source_path: man/io_uring_prep_futex_waitv.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 8ff2a822e5c5277db7326bbd9d90b0238e5478b301255d3ed41662df114573b8
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_futex_waitv(3)

## 名称

io_uring_prep_futex_waitv - 准备一个多 futex 等待请求

## 概要

```c
#include <linux/futex.h>
#include <unistd.h>
#include <liburing.h>

void io_uring_prep_futex_waitv(struct io_uring_sqe *sqe,
                               const struct futex_waitv *futexv,
                               uint32_t nr_futex,
                               unsigned int flags);
```

## 描述

[io_uring_prep_futex_waitv(3)](io_uring_prep_futex_waitv.3.md) 函数准备一个同时等待
多个 futex 的请求。提交队列项 `sqe` 会被设置为等待 `futexv` 给出的所有 futex，而
`nr_futex` 是该数组中的 futex 数量。

与 [io_uring_prep_futex_wait(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_prep_futex_wait.3)
不同，所需的位集掩码和值通过 `futexv` 传入。

`flags` 目前未使用，因此必须传入 `0`。

此函数准备一个异步
[futex(2)](https://man7.org/linux/man-pages/man2/futex.2.html) waitv 请求。详情请
参见该手册页。

自内核 6.7 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

与等待 futex 的同步 futex 系统调用不同，io_uring 不支持为请求传入超时。如果需要，
建议应用使用链接超时，在指定时间中止 futex 请求。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_futex_wait(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_prep_futex_wait.3)
- [io_uring_prep_futex_wake(3)](io_uring_prep_futex_wake.3.md)
- [io_uring_prep_link_timeout(3)](io_uring_prep_link_timeout.3.md)
- [futex(2)](https://man7.org/linux/man-pages/man2/futex.2.html)
- [futex2(2)](https://man7.org/linux/man-pages/man2/futex.2.html)
