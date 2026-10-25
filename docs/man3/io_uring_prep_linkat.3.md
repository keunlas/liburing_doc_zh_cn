---
title: io_uring_prep_linkat
section: 3
source_path: man/io_uring_prep_linkat.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: c09d4066a625210ac9d4828b83da58f53d6a3a26ee97eb8cded90086f9cf08ce
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_linkat(3)

## 名称

io_uring_prep_linkat - 准备一个 linkat 请求

## 概要

```c
#include <fcntl.h>
#include <unistd.h>
#include <liburing.h>

void io_uring_prep_linkat(struct io_uring_sqe *sqe,
                          int olddirfd,
                          const char *oldpath,
                          int newdirfd,
                          const char *newpath,
                          int flags);

void io_uring_prep_link(struct io_uring_sqe *sqe,
                        const char *oldpath,
                        const char *newpath,
                        int flags);
```

## 描述

[io_uring_prep_linkat(3)](io_uring_prep_linkat.3.md) 函数准备一个 linkat 请求。提交
队列项 `sqe` 会被设置为使用 `olddirfd` 所指向的旧目录文件描述符和 `oldpath` 所指向
的旧路径，以及 `newdirfd` 所指向的新目录文件描述符和 `newpath` 所指向的新路径，并
使用 `flags` 中指定的标志。

[io_uring_prep_link(3)](io_uring_prep_linkat.3.md) 函数准备一个 link 请求。提交队列
项 `sqe` 会被设置为使用 `oldpath` 所指向的旧路径，以及 `newpath` 所指向的新路径；
两者都相对于当前工作目录，并使用 `flags` 中指定的标志。

这些函数准备一个异步
[linkat(2)](https://man7.org/linux/man-pages/man2/linkat.2.html)
或 [link(2)](https://man7.org/linux/man-pages/man2/link.2.html) 请求。详情请参见
这些手册页。

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
- [linkat(2)](https://man7.org/linux/man-pages/man2/linkat.2.html)
- [link(2)](https://man7.org/linux/man-pages/man2/link.2.html)
