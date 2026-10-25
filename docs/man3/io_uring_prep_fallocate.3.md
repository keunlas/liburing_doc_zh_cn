---
title: io_uring_prep_fallocate
section: 3
source_path: man/io_uring_prep_fallocate.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 8344c97fdbd93f708c941f8960616130787e1902ca8b691a2965a251b1157ed7
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_fallocate(3)

## 名称

io_uring_prep_fallocate - 准备一个 fallocate 请求

## 概要

```c
#include <fcntl.h>
#include <liburing.h>

void io_uring_prep_fallocate(struct io_uring_sqe *sqe,
                             int fd,
                             int mode,
                             __u64 offset,
                             __u64 len);
```

## 描述

[io_uring_prep_fallocate(3)](io_uring_prep_fallocate.3.md) 函数准备一个 fallocate
请求。提交队列项 `sqe` 会被设置为使用 `fd` 所指向的文件描述符，以启动由 `mode`
描述、位于偏移量 `offset` 且长度为 `len` 字节的 fallocate 操作。

此函数准备一个异步
[fallocate(2)](https://man7.org/linux/man-pages/man2/fallocate.2.html) 请求。详情
请参见该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [fallocate(2)](https://man7.org/linux/man-pages/man2/fallocate.2.html)
