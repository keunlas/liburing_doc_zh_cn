---
title: io_uring_register_zcrx_ctrl
section: 3
source_path: man/io_uring_register_zcrx_ctrl.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a537520f5727eb4ae1a8fd4701a1f6ea8d1d169fb8cdb92e44613923d6933429
source_copyright: "Copyright (C) 2026 Yitang Yang <yi1tang.yang@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_zcrx_ctrl(3)

## 名称

io_uring_register_zcrx_ctrl - 在零拷贝接收上下文上执行控制操作

## 概要

```c
#include <liburing.h>

int io_uring_register_zcrx_ctrl(struct io_uring *ring,
                                struct zcrx_ctrl *ctrl);
```

## 描述

[io_uring_register_zcrx_ctrl(3)](io_uring_register_zcrx_ctrl.3.md) 函数在先前注册的
零拷贝接收上下文上执行控制操作。注册零拷贝接收上下文的详情请参见
[io_uring_register_ifq(3)](io_uring_register_ifq.3.md)。

`ctrl` 参数必须指向描述待执行控制操作的 `struct zcrx_ctrl`：

```c
struct zcrx_ctrl {
    __u32 zcrx_id;
    __u32 op;
    __u64 __resv[2];
    union {
        struct zcrx_ctrl_export     zc_export;
        struct zcrx_ctrl_flush_rq   zc_flush;
    };
};
```

`zcrx_id` 字段必须设置为
[io_uring_register_ifq(3)](io_uring_register_ifq.3.md) 返回的零拷贝接收上下文 ID。
`op` 字段指定要执行的控制操作，可以是以下值之一：

- `ZCRX_CTRL_FLUSH_RQ`：刷新补充队列中的待处理缓冲区，使用联合体的 `zc_flush` 成员。
- `ZCRX_CTRL_EXPORT`：导出零拷贝接收上下文，以供其他环使用，使用联合体的
  `zc_export` 成员。成功导出后，`zc_export` 的 `zcrx_fd` 字段将包含可用于与其他
  io_uring 实例共享此上下文的文件描述符。

保留字段 `__resv` 必须清零。

## 返回值

成功时返回 0。发生错误时，返回负的 `errno` 值。

## 注意事项

此函数自 Linux 内核 6.15 起可用。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_register_ifq(3)](io_uring_register_ifq.3.md)
