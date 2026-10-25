---
title: io_uring_register_sync_msg
section: 3
source_path: man/io_uring_register_sync_msg.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: c1db113cdd07bb97e950aaf0dfda0866ab0dbe71e332756c87bef5f8996e16da
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_sync_msg(3)

## 名称

io_uring_register_sync_msg - 向另一个环发送同步消息

## 概要

```c
#include <liburing.h>

int io_uring_register_sync_msg(struct io_uring_sqe *sqe);
```

## 描述

[io_uring_register_sync_msg(3)](io_uring_register_sync_msg.3.md) 发出一个同步
MSG_RING 请求。`sqe` 参数必须已清零，并使用
[io_uring_prep_msg_ring(3)](io_uring_prep_msg_ring.3.md) 初始化。

通常消息请求从一个环发送到另一个环。但有些情况下源环不可用，却仍希望方便地向目标环
发送消息。[io_uring_register_sync_msg(3)](io_uring_register_sync_msg.3.md) 正是为此
而存在。向另一个环发送消息不需要源环；可以将 `sqe` 参数放在栈上，使用常规消息辅助
函数填入，然后调用
[io_uring_register_sync_msg(3)](io_uring_register_sync_msg.3.md)。由于不存在源环，
操作结果会直接返回，而不是通过 CQE 返回。在目标/接收端，仍会像非同步请求那样发布
CQE。

仅支持数据请求；不支持发送由
[io_uring_prep_msg_ring_fd(3)](io_uring_prep_msg_ring_fd.3.md) 设置的文件。给定的
SQE 应由 [io_uring_prep_msg_ring(3)](io_uring_prep_msg_ring.3.md) 或
[io_uring_prep_msg_ring_cqe_flags(3)](io_uring_prep_msg_ring.3.md)，或任何其他用于
设置非 fd 消息请求的辅助函数初始化。

目标环可以是用户有权访问的任何环，甚至可以是该环本身。此请求可用于向另一个环进行
简单消息传递，从而通过 `len` 和 `data` 字段传输 32+64 位数据。

如果调用任务为注册操作码注册了按任务生效的限制，请参见
[io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
中的 `IORING_REGISTER_RESTRICTIONS`；`IORING_REGISTER_SEND_MSG_RING` 必须位于允许
的操作码中，否则调用将以 `-EACCES` 失败。由于不存在源环，对
`IORING_OP_MSG_RING` 的限制或 BPF 过滤器不适用于此同步变体。

自内核 6.13 起可用。

## 返回值

成功时返回 0，发生错误时返回 `-errno`。

## 参见

- [io_uring_prep_msg_ring_cqe_flags(3)](io_uring_prep_msg_ring.3.md)
- [io_uring_prep_msg_ring(3)](io_uring_prep_msg_ring.3.md)
