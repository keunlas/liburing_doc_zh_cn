---
title: io_uring_prep_futex_wait
section: 3
source_path: man/io_uring_prep_futex_wait.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: fc37ed61a8dd97f09ce80e7b175d5e801ee8c464bfe40e7f282f3f196a54bb2c
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_futex_wait(3)

## 名称

io_uring_prep_futex_wait - 准备一个 futex 等待请求

## 概要

```c
#include <linux/futex.h>
#include <unistd.h>
#include <liburing.h>

void io_uring_prep_futex_wait(struct io_uring_sqe *sqe,
                              const uint32_t *futex,
                              uint64_t val,
                              uint64_t mask,
                              uint32_t futex_flags,
                              unsigned int flags);
```

## 描述

[io_uring_prep_futex_wait(3)](io_uring_prep_futex_wait.3.md) 函数准备一个 futex 等待
请求。提交队列项 `sqe` 会被设置为等待地址 `futex` 处仍具有值 `val` 的 futex，并使用
由 `futex_flags` 指定的
[futex2(2)](https://man7.org/linux/man-pages/man2/futex.2.html) 标志以及由 `flags`
指定的 io_uring futex 标志。

`mask` 可以设置为特定位集掩码，唤醒端会按其匹配来决定唤醒谁。若要始终被唤醒，应用
可以使用 `FUTEX_BITSET_MATCH_ANY`。

`futex_flags` 遵循
[futex2(2)](https://man7.org/linux/man-pages/man2/futex.2.html) 标志，而不是
[futex(2)](https://man7.org/linux/man-pages/man2/futex.2.html) v1 接口标志。

`flags` 目前未使用，因此必须传入 `0`。

此函数准备一个异步
[futex(2)](https://man7.org/linux/man-pages/man2/futex.2.html) 等待请求。详情请参见
该手册页。请注意，io_uring futex 等待请求类似于 `FUTEX_WAIT_BITSET` 操作，因为
`FUTEX_WAIT` 是该操作的严格子集。

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
- [io_uring_prep_futex_waitv(3)](io_uring_prep_futex_waitv.3.md)
- [io_uring_prep_futex_wake(3)](io_uring_prep_futex_wake.3.md)
- [io_uring_prep_link_timeout(3)](io_uring_prep_link_timeout.3.md)
- [futex(2)](https://man7.org/linux/man-pages/man2/futex.2.html)
- [futex2(2)](https://man7.org/linux/man-pages/man2/futex.2.html)
