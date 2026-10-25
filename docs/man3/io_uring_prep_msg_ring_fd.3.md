---
title: io_uring_prep_msg_ring_fd
section: 3
source_path: man/io_uring_prep_msg_ring_fd.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: cc64d4c412a99bc842784bd4b7fc18b897fb2a89303978f34283a8abb13b7224
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_msg_ring_fd(3)

## 名称

io_uring_prep_msg_ring_fd - 向另一个环发送直接描述符

## 概要

```c
#include <liburing.h>

void io_uring_prep_msg_ring_fd(struct io_uring_sqe *sqe,
                        int fd,
                        int source_fd,
                        int target_fd,
                        __u64 data,
                        unsigned int flags);

void io_uring_prep_msg_ring_fd_alloc(struct io_uring_sqe *sqe,
                        int fd,
                        int source_fd,
                        __u64 data,
                        unsigned int flags);
```

## 描述

[io_uring_prep_msg_ring_fd(3)](io_uring_prep_msg_ring_fd.3.md) 准备一个 SQE，用于将
直接文件描述符发送到另一个环。提交队列项 `sqe` 会被设置为使用文件描述符 `fd`
（它必须标识目标 io_uring 上下文），将本地已注册、值为 `source_fd` 的文件描述符发送
到目标环的索引 `target_fd`，并将 `data` 作为目标 CQE 的用户数据传递；请求修饰标志由
`flags` 设置。目前没有有效的标志修饰符，该字段必须为 `0`。

[io_uring_prep_msg_ring_fd_alloc(3)](io_uring_prep_msg_ring_fd.3.md) 与
[io_uring_prep_msg_ring_fd(3)](io_uring_prep_msg_ring_fd.3.md) 类似，但不为直接
描述符指定目标索引。该索引会在目标环中分配，并在 CQE 的 `res` 字段中返回。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。

- `-ENOMEM`：内核无法为请求分配内存。
- `-EINVAL`：SQE 中设置的某个字段无效。
- `-EINVAL`：目标环与源环相同。
- `-EBADFD`：`fd` 不指向 io_uring 文件描述符，或目标环处于禁用状态。
- `-EOVERFLOW`：内核无法在目标环上填入 CQE。如果目标 CQ 环处于溢出状态，并且内核
  无法为新 CQE 项分配内存，就可能发生此错误。
- `-ENFILE`：目标环中的直接描述符表已满，无法成功分配新描述符。
