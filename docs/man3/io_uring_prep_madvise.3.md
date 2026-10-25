---
title: io_uring_prep_madvise
section: 3
source_path: man/io_uring_prep_madvise.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: abaa701150be0bf5643b7ebc77c08a012967e56f655f6a4454d6cdf5b441d3a9
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_madvise(3)

## 名称

io_uring_prep_madvise - 准备一个 madvise 请求

## 概要

```c
#include <sys/mman.h>
#include <liburing.h>

void io_uring_prep_madvise(struct io_uring_sqe *sqe,
                           void *addr,
                           __u32 len,
                           int advice);

void io_uring_prep_madvise64(struct io_uring_sqe *sqe,
                             void *addr,
                             off_t len,
                             int advice);
```

## 描述

[io_uring_prep_madvise(3)](io_uring_prep_madvise.3.md) 函数准备一个 madvise 请求。
提交队列项 `sqe` 会被设置为在虚拟地址 `addr` 处启动一个长度为 `len` 字节的 madvise
操作，并采用位于 `advice` 中的建议值。

[io_uring_prep_madvise64(3)](io_uring_prep_madvise.3.md) 函数的工作方式与
[io_uring_prep_madvise(3)](io_uring_prep_madvise.3.md) 相同，区别在于它接受 64 位
长度，而不只是 32 位长度。较旧的内核可能不支持 64 位长度变体。如果在不支持 64 位
长度的内核上尝试使用此变体，则请求会在 CQE 的结果字段中以 `-EINVAL` 失败。

此函数准备一个异步
[madvise(2)](https://man7.org/linux/man-pages/man2/madvise.2.html) 请求。详情请
参见该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [madvise(2)](https://man7.org/linux/man-pages/man2/madvise.2.html)
