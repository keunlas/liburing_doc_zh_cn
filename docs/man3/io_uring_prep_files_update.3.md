---
title: io_uring_prep_files_update
section: 3
source_path: man/io_uring_prep_files_update.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 26859d6242b8e1e48d03470e6814c1f3475d94fcce8814caf090a5b5c311d410
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_files_update(3)

## 名称

io_uring_prep_files_update - 准备一个已注册文件更新请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_files_update(struct io_uring_sqe *sqe,
                                int *fds,
                                unsigned nr_fds,
                                int offset);
```

## 描述

[io_uring_prep_files_update(3)](io_uring_prep_files_update.3.md) 函数准备一个更新若干
先前注册文件描述符的请求。提交队列项 `sqe` 会被设置为使用 `fds` 所指向、长度为
`nr_fds` 的文件描述符数组，从偏移量 `offset` 开始更新相应数量的先前注册文件。

已注册文件被新文件更新后，现有条目会被更新，随后旧条目从表中移除。此操作等效于先
取消注册该条目，再插入一个新条目，只是将二者捆绑为一个组合操作。

如果将 `offset` 指定为 `IORING_FILE_INDEX_ALLOC`，io_uring 将分配空闲的直接描述符，
而不是要求应用传入这些描述符，并将所分配的直接描述符存储到 `fds` 数组中。
`cqe->res` 会返回分配的直接描述符数量。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时，`res` 包含成功更新的文件描述符数量。
发生错误时，可能出现以下错误：

- `-ENOMEM`：内核无法为请求分配内存。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-EFAULT`：内核无法复制 `fds` 所指向的内存。
- `-EBADF`：`fds` 中的某个描述符未指向有效文件描述符，或者数组中的某个文件描述符
  指向一个 io_uring 实例。
- `-EOVERFLOW`：`offset` 与 `nr_fds` 的乘积超出有效数量，或者发生了溢出。

## 注意事项

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
