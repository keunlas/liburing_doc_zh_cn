---
title: io_uring_sqe_set_buf_group
section: 3
source_path: man/io_uring_sqe_set_buf_group.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 65f133d94dd05227914ffb2fba4a26a6d9ac9a6c87fa746b7fff085a869e9352
source_copyright: "Copyright (C) 2024 Christian Mazakas <christian.mazakas@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_sqe_set_buf_group(3)

## 名称

io_uring_sqe_set_buf_group - 设置提交队列事件的缓冲区组

## 概要

```c
#include <liburing.h>

void io_uring_sqe_set_buf_group(struct io_uring_sqe *sqe,
                                int bgid);
```

## 描述

[io_uring_sqe_set_buf_group(3)](io_uring_sqe_set_buf_group.3.md) 函数将与 `sqe` 关联
的 `buf_group` 设置为 `bgid`。

调用方通过
[io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
请求提交队列项（SQE）后，可以将用于多轮触发操作的缓冲区组与该 SQE 关联。

## 返回值

无。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_sqe_set_data(3)](io_uring_sqe_set_data.3.md)
