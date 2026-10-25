---
title: io_uring_get_sqe128
section: 3
source_path: man/io_uring_get_sqe128.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 804af1c7b8c8ec4ead757c3720090839ffb890610fa72cd864471858d5a484af
source_copyright: "Copyright (C) 2020 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2020 Red Hat, Inc."
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_get_sqe128(3)

## 名称

io_uring_get_sqe128 - 从提交队列取得下一个可用的 128 字节提交队列项

## 概要

```c
#include <liburing.h>

struct io_uring_sqe *io_uring_get_sqe128(struct io_uring *ring);
```

## 描述

[io_uring_get_sqe128(3)](io_uring_get_sqe128.3.md) 函数从与 `ring` 参数所属的提交
队列中取得下一个可用的 128 字节提交队列项。

成功时，[io_uring_get_sqe128(3)](io_uring_get_sqe128.3.md) 返回指向该提交队列项的
指针。失败时返回 `NULL`。

如果返回了提交队列项，则应使用诸如
[io_uring_prep_uring_cmd128(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_prep_uring_cmd128.3)
之类的 prep 函数填写该项，并通过
[io_uring_submit(3)](io_uring_submit.3.md) 提交。

请注意，`io_uring_get_sqe128(3)` 和 prep 函数都不会设置（或清除）SQE 的
`user_data` 字段。如果调用方期望在获取并处理 I/O 完成事件时，
[io_uring_cqe_get_data(3)](io_uring_cqe_get_data.3.md)
或
[io_uring_cqe_get_data64(3)](io_uring_cqe_get_data.3.md)
返回有效数据，则必须在提交请求前调用
[io_uring_sqe_set_data(3)](io_uring_sqe_set_data.3.md)
或
[io_uring_sqe_set_data64(3)](io_uring_sqe_set_data.3.md)。**必须**在提交请求前完成。

## 返回值

成功时，[io_uring_get_sqe128(3)](io_uring_get_sqe128.3.md) 返回指向下一个提交队列项
的指针；失败时返回 `NULL`。如果返回 `NULL`，则要么创建 SQ 环时未启用对 128 字节
SQE 项的支持（`IORING_SETUP_SQE128` 或 `IORING_SETUP_SQE_MIXED`），要么 SQ 环当前
已满，必须先提交已有项进行处理，才能分配新项。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_sqe_set_data(3)](io_uring_sqe_set_data.3.md)
