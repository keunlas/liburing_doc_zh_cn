---
title: io_uring_prep_provide_buffers
section: 3
source_path: man/io_uring_prep_provide_buffers.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 5b9b9078582fbcabb8efd99a964a2bd9be04e7722167db58ad66678761e07024
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_provide_buffers(3)

## 名称

io_uring_prep_provide_buffers - 准备一个提供缓冲区请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_provide_buffers(struct io_uring_sqe *sqe,
                                   void *addr,
                                   int len,
                                   int nr,
                                   int bgid,
                                   int bid);
```

## 描述

[io_uring_prep_provide_buffers(3)](io_uring_prep_provide_buffers.3.md) 函数准备一个
向内核提供缓冲区的请求。提交队列项 `sqe` 会被设置为从 `addr` 开始，使用 `nr` 个大小
为 `len` 的缓冲区，这些缓冲区属于缓冲区组 ID `bgid`，并从 `bid` 开始按顺序编号。

此函数设置一个向 io_uring 上下文提供缓冲区的请求，这些缓冲区可供读取或接收操作使用。
使用方法是填写 SQE 的 `buf_group` 字段，并在 SQE 的 `flags` 成员中设置
`IOSQE_BUFFER_SELECT`。如果请求使用缓冲区选择，则地址字段中不应提供缓冲区。相反，
应将组 ID 设置为与先前提供给内核的某个组匹配。随后内核会从该组中为 I/O 操作选择
缓冲区。I/O 请求成功完成后，CQE 的 `flags` 字段中会设置 `IORING_CQE_F_BUFFER`，
所选缓冲区 ID 由 `flags` 字段的高 16 位表示。

应用可以使用不同缓冲区组 ID 来提供不同大小或类型的缓冲区。缓冲区一旦被某次操作消费，
io_uring 便不再知道它。如果需要，必须重新提供该缓冲区；如果不再需要，则由应用释放。

缓冲区 ID 在内部从 `bid` 开始跟踪，并从该值连续递增。如果提供 16 个缓冲区且起始
`bid` 为 0，则缓冲区 ID 范围为 `0..15`。应用必须了解这一点，才能理解 CQE 中返回的
缓冲区 ID。

缓冲区 ID 始终位于 `0` 到 65535，因为 CQE 中只有 16 位可用于返回它们。该范围与
缓冲区组最初如何创建无关。尝试添加大于该范围的缓冲区 ID，或者添加转换到 16 位值时会
回绕的缓冲区 ID，将导致请求以 `-E2BIG` 或 `-EINVAL` 失败。

并非所有请求都支持缓冲区选择，因为它只对从内核接收数据而不是写入或提供数据的请求
真正有意义。目前，任何文件读取或套接字接收请求都支持此操作模式。尝试对不支持的命令
使用 `IOSQE_BUFFER_SELECT`，会导致 CQE 的 `res` 返回 `-EINVAL` 错误。缓冲区选择
可用于以 `struct iovec` 作为数据目标的操作，但仅限提供一个 iovec 的情况。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时，`res` 将包含 `0` 或成功提供的缓冲区
数量。

- `-ENOMEM`：内核无法为该请求分配内存。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-E2BIG`：提供的缓冲区数量过大，或者 `bid` 过大。最多可指定 `USHRT_MAX` 个
  缓冲区。
- `-EFAULT`：提供给应用的某些用户内存无效。
- `-EOVERFLOW`：`len` 与 `nr` 的乘积超出有效数量或发生溢出，或者 `addr` 与缓冲区
  长度之和发生溢出。
- `-EBUSY`：尝试更新已在使用中的槽位。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_prep_remove_buffers(3)](io_uring_prep_remove_buffers.3.md)
