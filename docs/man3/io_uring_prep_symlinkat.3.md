---
title: io_uring_prep_symlinkat
section: 3
source_path: man/io_uring_prep_symlinkat.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 7318bf47388c5358e180eedff13395b581cf68864a1cd0cd81db383f4967a5e9
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_symlinkat(3)

## 名称

io_uring_prep_symlinkat - 准备一个 symlinkat 请求

## 概要

```c
#include <fcntl.h>
#include <unistd.h>
#include <liburing.h>

void io_uring_prep_symlinkat(struct io_uring_sqe *sqe,
                             const char *target,
                             int newdirfd,
                             const char *linkpath);

void io_uring_prep_symlink(struct io_uring_sqe *sqe,
                           const char *target,
                           const char *linkpath);
```

## 描述

[io_uring_prep_symlinkat(3)](io_uring_prep_symlinkat.3.md) 函数准备一个 symlinkat
请求。提交队列项 `sqe` 会被设置为将 `target` 所指向的目标路径符号链接到
`newdirfd` 和 `linkpath` 所指示的新目标位置。

[io_uring_prep_symlink(3)](io_uring_prep_symlinkat.3.md) 函数准备一个 symlink 请求。
提交队列项 `sqe` 会被设置为将 `target` 所指向的目标路径符号链接到相对于当前工作
目录的 `linkpath` 所指示的新目标位置。此函数准备一个异步
[symlink(2)](https://man7.org/linux/man-pages/man2/symlink.2.html) 请求。详情请
参见该手册页。

这些函数准备一个异步
[symlinkat(2)](https://man7.org/linux/man-pages/man2/symlinkat.2.html)
或 [symlink(2)](https://man7.org/linux/man-pages/man2/symlink.2.html) 请求。详情
请参见这些手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [symlinkat(2)](https://man7.org/linux/man-pages/man2/symlinkat.2.html)
- [symlink(2)](https://man7.org/linux/man-pages/man2/symlink.2.html)
