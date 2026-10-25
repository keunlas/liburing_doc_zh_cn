---
title: io_uring_prep_fixed_fd_install
section: 3
source_path: man/io_uring_prep_fixed_fd_install.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 0907727dc11f641479d9ac5edaba80a56a0e766a3ae3eed7f3ccf658f5d9b9ed
source_copyright: "Copyright (C) 2023 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_fixed_fd_install(3)

## 名称

io_uring_prep_fixed_fd_install - 准备安装固定文件描述符的请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_fixed_fd_install(struct io_uring_sqe *sqe,
                                    int fd,
                                    unsigned int flags);
```

## 描述

[io_uring_prep_fixed_fd_install(3)](io_uring_prep_fixed_fd_install.3.md) 辅助函数
准备安装一个固定文件描述符。提交队列项 `sqe` 会被设置为使用指定的文件安装标志
`flags` 安装直接/固定文件描述符 `fd`。

直接/固定文件描述符的一种用途是将普通文件描述符转换为直接描述符，从而降低任何需要
访问该文件的请求的开销。此辅助函数提供了相反方向的转换方式：将直接描述符转换为普通
文件描述符，之后便可由接受普通文件描述符的常规系统调用使用。如果该直接描述符没有
对应的普通文件描述符，这会很方便；原因可能是它直接作为固定描述符创建，或者在转换为
直接描述符后普通文件又通过
[close(2)](https://man7.org/linux/man-pages/man2/close.2.html) 关闭了。

请求成功返回后，同一文件将同时存在普通和固定文件描述符。任意一个都可用于访问该文件，
关闭其中任意一个都不会影响另一个。

`flags` 可以为零，也可以设置为 `IORING_FIXED_FD_NO_CLOEXEC`，以表示新的普通文件
描述符不应在执行 exec 时关闭。否则，默认会在新描述符上设置 `O_CLOEXEC`。将此字段
设置为这两个值以外的任何值，都会使请求失败，并在 CQE 的 `res` 字段中返回 `-EINVAL`。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果；此处的操作结果是新的普通文件描述符值。失败时返回负
值。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register_files(3)](io_uring_register_files.3.md)
- [io_uring_unregister_files(3)](io_uring_unregister_files.3.md)
- [io_uring_prep_close_direct(3)](io_uring_prep_close.3.md)
- [io_uring_prep_openat_direct(3)](io_uring_prep_openat.3.md)
