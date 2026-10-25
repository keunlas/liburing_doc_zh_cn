---
title: io_uring_prep_close
section: 3
source_path: man/io_uring_prep_close.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: d6e56d99b7a971f7dba8849d325a2c44d57d7b800cfb359abda1ec061392c196
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_close(3)

## 名称

io_uring_prep_close - 准备一个文件描述符关闭请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_close(struct io_uring_sqe *sqe,
                          int fd);

void io_uring_prep_close_direct(struct io_uring_sqe *sqe,
                                unsigned file_index);
```

## 描述

[io_uring_prep_close(3)](io_uring_prep_close.3.md) 函数准备一个 close 请求。提交
队列项 `sqe` 会被设置为关闭 `fd` 所指示的文件描述符。

对于直接描述符关闭请求，偏移量由 `file_index` 参数而不是 `fd` 指定。这与取消注册
直接描述符完全相同，是为了方便而提供的。请注意，即使关闭的是直接描述符，应用也不得
在 SQE 上设置 `IOSQE_FIXED_FILE`。否则，请求将以 `-EBADF` 作为结果完成。

这些函数准备一个异步
[close(2)](https://man7.org/linux/man-pages/man2/close.2.html) 请求。详情请参见该
手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。对于关闭直接描述符，
唯一的失败情况是内核完全耗尽内存，或者应用指定了无效的直接描述符。请注意，同步系统
调用失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，
而是直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [close(2)](https://man7.org/linux/man-pages/man2/close.2.html)
