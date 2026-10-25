---
title: io_uring_prep_fsync
section: 3
source_path: man/io_uring_prep_fsync.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 5db1060a6aaa8eb2df6b7acc1bdee82ebe69d688ac0d61471a3048b10abe389b
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_fsync(3)

## 名称

io_uring_prep_fsync - 准备一个 fsync 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_fsync(struct io_uring_sqe *sqe,
                         int fd,
                         unsigned flags);
```

## 描述

[io_uring_prep_fsync(3)](io_uring_prep_fsync.3.md) 函数准备一个 fsync 请求。提交
队列项 `sqe` 会被设置为使用应当同步的文件描述符 `fd`，并使用 `flags` 参数指示的
修饰标志。

此函数准备一个 fsync 请求。它可以表现得像
[fsync(2)](https://man7.org/linux/man-pages/man2/fsync.2.html) 操作，这也是默认
行为。如果在 `flags` 参数中设置 `IORING_FSYNC_DATASYNC`，则其行为类似于
[fdatasync(2)](https://man7.org/linux/man-pages/man2/fdatasync.2.html)。如果未
指定范围，则将从 0 到文件末尾同步 `fd`。

如果需要，也可以指定要同步的范围。如果 SQE 的 `off` 字段设置为非零值，则该值表示
开始同步的偏移量。如果在 SQE 中设置了 `len`，则该值表示从该偏移量开始要同步的字节
数。请注意，此辅助函数不接受这些字段，因此必须在调用此 prep 辅助函数后在 SQE 中
手动设置它们。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [fsync(2)](https://man7.org/linux/man-pages/man2/fsync.2.html)
- [fdatasync(2)](https://man7.org/linux/man-pages/man2/fdatasync.2.html)
