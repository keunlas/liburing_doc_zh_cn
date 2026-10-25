---
title: io_uring_prep_sync_file_range
section: 3
source_path: man/io_uring_prep_sync_file_range.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 3cb34d0e864ca1c812f04515189973bd4477092d155950eb2ec2ab28703c0586
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_sync_file_range(3)

## 名称

io_uring_prep_sync_file_range - 准备一个 sync_file_range 请求

## 概要

```c
#include <fcntl.h>
#include <liburing.h>

void io_uring_prep_sync_file_range(struct io_uring_sqe *sqe,
                                   int fd,
                                   unsigned len,
                                   __u64 offset,
                                   int flags);
```

## 描述

[io_uring_prep_sync_file_range(3)](io_uring_prep_sync_file_range.3.md) 函数准备一个
sync_file_range 请求。提交队列项 `sqe` 会被设置为使用应当同步的文件描述符 `fd`，
从偏移量 `offset` 开始同步 `len` 字节，并使用 `flags` 参数中的修饰标志。

此函数准备一个异步
[sync_file_range(2)](https://man7.org/linux/man-pages/man2/sync_file_range.2.html)
请求。参数的详情请参见该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [sync_file_range(2)](https://man7.org/linux/man-pages/man2/sync_file_range.2.html)
