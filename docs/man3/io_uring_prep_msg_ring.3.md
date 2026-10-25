---
title: io_uring_prep_msg_ring
section: 3
source_path: man/io_uring_prep_msg_ring.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 6a3127c9984320cca161f7b789e0832ec444769ec10ac342d4d57482f0221a7a
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_msg_ring(3)

## 名称

io_uring_prep_msg_ring - 向另一个环发送消息

## 概要

```c
#include <liburing.h>

void io_uring_prep_msg_ring(struct io_uring_sqe *sqe,
                        int fd,
                        unsigned int len,
                        __u64 data,
                        unsigned int flags);

void io_uring_prep_msg_ring_cqe_flags(struct io_uring_sqe *sqe,
                        int fd,
                        unsigned int len,
                        __u64 data,
                        unsigned int flags,
                        unsigned int cqe_flags);
```

## 描述

[io_uring_prep_msg_ring(3)](io_uring_prep_msg_ring.3.md) 准备向 io_uring 文件
描述符发送一个 CQE。提交队列项 `sqe` 会被设置为使用文件描述符 `fd` 在该环上发布
CQE，而 `fd` 必须标识一个 io_uring 上下文。目标 CQE 的 `res` 字段将包含 `len` 的
内容，`user_data` 字段将包含 `data`，请求修饰标志由 `flags` 设置。目前没有有效的
标志修饰符，此字段必须为 `0`。

目标环可以是用户有权访问的任何环，甚至可以是该环本身。此请求可用于向另一个环进行
简单消息传递，从而通过 `len` 和 `data` 字段传输 32+64 位数据。其用例可以简单到唤醒
正在目标环上等待的人，也可以用于在两个环之间传递消息。

[io_uring_prep_msg_ring_cqe_flags(3)](io_uring_prep_msg_ring.3.md) 与
[io_uring_prep_msg_ring(3)](io_uring_prep_msg_ring.3.md) 类似，但额外提供
`cqe_flags` 参数，用于设置 CQE 侧的 `flags` 字段。这样，在发送消息时可以设置
CQE 的 `flags` 字段 `cqe->flags`。请注意，io_uring 可能会向该字段设置额外的位。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。

- `-ENOMEM`：内核无法为请求分配内存。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-EBADFD`：传入的 `fd` 不指向 io_uring 文件描述符，或该环处于禁用状态。
- `-EOVERFLOW`：内核无法在目标环上填入 CQE。如果目标 CQ 环处于溢出状态，并且内核
  无法为新 CQE 项分配内存，就可能发生此错误。
