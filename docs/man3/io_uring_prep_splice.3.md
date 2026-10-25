---
title: io_uring_prep_splice
section: 3
source_path: man/io_uring_prep_splice.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2a45da21963f17699a45cb7b67b27e8150c95cb2bd12f46c79008a650f218645
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_splice(3)

## 名称

io_uring_prep_splice - 准备一个 splice 请求

## 概要

```c
#include <fcntl.h>
#include <liburing.h>

void io_uring_prep_splice(struct io_uring_sqe *sqe,
                          int fd_in,
                          int64_t off_in,
                          int fd_out,
                          int64_t off_out,
                          unsigned int nbytes,
                          unsigned int splice_flags);
```

## 描述

[io_uring_prep_splice(3)](io_uring_prep_splice.3.md) 函数准备一个 splice 请求。提交
队列项 `sqe` 会被设置为以位于偏移量 `off_in` 的文件描述符 `fd_in` 为输入，将数据
splice 到位于偏移量 `off_out` 的文件描述符 `fd_out`。应在两个描述符之间 splice
`nbytes` 字节数据。`splice_flags` 是操作的修饰标志。通用 splice 标志请参见
[splice(2)](https://man7.org/linux/man-pages/man2/splice.2.html)。

如果 `fd_out` 是直接描述符，可以在 SQE 中设置 `IOSQE_FIXED_FILE` 来表示这一点。对于
输入文件，可以在 `splice_flags` 中设置 io_uring 专用的
`SPLICE_F_FD_IN_FIXED`，并将 `fd_in` 作为已注册文件描述符偏移量传入。

如果 `fd_in` 引用管道，则忽略 `off_in`，并且必须将其设置为 -1。

如果 `fd_in` 不引用管道且 `off_in` 为 -1，则从文件偏移量开始读取 `nbytes`，文件偏移量
会增加读取的字节数。

如果 `fd_in` 不引用管道且 `off_in` 不为 -1，则 `fd_in` 的起始偏移量为 `off_in`。

相同规则适用于 `fd_out` 和 `off_out`。

此函数准备一个异步
[splice(2)](https://man7.org/linux/man-pages/man2/splice.2.html) 请求。详情请参见
该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

请注意，即使 `fd_in` 或 `fd_out` 引用管道，如果其中一个 fd 未显式支持 splice 操作，
splice 仍可能以 `EINVAL` 失败。例如，从内核 5.7 到 5.11，从终端读取不受支持。

尽管此函数接受无符号字节数，但每次调用最多只能传输 `INT_MAX` 字节（底层系统调用接口
的最大值）。实践中还观察到低至 65536 的限制（与
[splice(2)](https://man7.org/linux/man-pages/man2/splice.2.html) 本身相同）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [splice(2)](https://man7.org/linux/man-pages/man2/splice.2.html)
