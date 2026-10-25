---
title: io_uring_prep_remove_buffers
section: 3
source_path: man/io_uring_prep_remove_buffers.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 6a5586568e750b53e5fef55d0c1eb84e030ab1bb78fec6d9462aa6fcea71af4e
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_remove_buffers(3)

## 名称

io_uring_prep_remove_buffers - 准备一个移除缓冲区请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_remove_buffers(struct io_uring_sqe *sqe,
                                   int nr,
                                   int bgid);
```

## 描述

[io_uring_prep_remove_buffers(3)](io_uring_prep_remove_buffers.3.md) 函数准备一个移除
先前提供的缓冲区的请求。提交队列项 `sqe` 会被设置为从 `bgid` 指示的缓冲区组 ID 中
移除 `nr` 个缓冲区。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时，`res` 包含成功移除的缓冲区数量。发生
错误时，可能出现以下错误：

- `-ENOMEM`：内核无法为该请求分配内存。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-ENOENT`：指定的 `bgid` 缓冲区组 ID 中不存在缓冲区。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_prep_provide_buffers(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_prep_provide_buffers.3)
