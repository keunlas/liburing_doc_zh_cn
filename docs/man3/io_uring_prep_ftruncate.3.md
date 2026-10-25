---
title: io_uring_prep_ftruncate
section: 3
source_path: man/io_uring_prep_ftruncate.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 8d640a51bd7b6d86affb17f09b7d9594fec9bc1f3719aaf9de6caea8a2a6d19f
source_copyright: "Copyright (C) 2024 Tony Solomonik <tony.solomonik@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_ftruncate(3)

## 名称

io_uring_prep_ftruncate - 准备一个 ftruncate 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_ftruncate(struct io_uring_sqe *sqe,
                             int fd,
                             loff_t len);
```

## 描述

[io_uring_prep_ftruncate(3)](io_uring_prep_ftruncate.3.md) 函数准备一个 ftruncate
请求。提交队列项 `sqe` 会被设置为使用应当截断到 `len` 参数所指示长度的文件描述符
`fd`。

应用必须定义 `_GNU_SOURCE` 才能获得此辅助函数的定义，因为如果不定义它，就不会定义
`loff_t`。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [ftruncate(2)](https://man7.org/linux/man-pages/man2/ftruncate.2.html)
