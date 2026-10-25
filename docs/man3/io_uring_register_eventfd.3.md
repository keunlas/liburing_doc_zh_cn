---
title: io_uring_register_eventfd
section: 3
source_path: man/io_uring_register_eventfd.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: e685c36e0f54da37061309ff9717a74fe40e52fe4b52c3ef15bdca0fba409a63
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_eventfd(3)

## 名称

io_uring_register_eventfd - 向环注册一个 eventfd

## 概要

```c
#include <liburing.h>

int io_uring_register_eventfd(struct io_uring *ring,
                              int fd);

int io_uring_register_eventfd_async(struct io_uring *ring,
                                    int fd);

int io_uring_unregister_eventfd(struct io_uring *ring);
```

## 描述

[io_uring_register_eventfd(3)](io_uring_register_eventfd.3.md) 将 eventfd 文件
描述符 `fd` 注册到由 `ring` 标识的环。

每当完成事件发布到 CQ 环时，就会使用已注册的 eventfd 描述符生成 eventfd 通知。如果
使用
[io_uring_register_eventfd_async(3)](io_uring_register_eventfd.3.md)，则只有
非内联（out-of-line）完成的那些事件才会触发通知。

如果不再需要通知，可以调用
[io_uring_unregister_eventfd(3)](io_uring_register_eventfd.3.md) 删除 eventfd
注册。由于一个环只能注册一个 eventfd，因此不需要提供 eventfd 参数。

## 注意事项

尽管 io_uring 通常会尽量避免伪通知，但它们仍可能发生。类似地，批量完成 CQE 时，即使
发布了多个 CQE，也可能只触发一个 eventfd 通知。应用不应假定可用事件数量与已发布的
eventfd 通知数量之间存在直接对应关系。因此，eventfd 通知只能被视为提示，用于检查
CQ 环中的完成事件。

## 返回值

成功时返回 0，发生错误时返回 `-errno`。

## 参见

- [eventfd(2)](https://man7.org/linux/man-pages/man2/eventfd.2.html)
