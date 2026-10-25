---
title: io_uring_close_ring_fd
section: 3
source_path: man/io_uring_close_ring_fd.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2253b829556c7a58c76a8aca96d27591dc0859897ef89868274c51551af1df1e
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2022 Josh Triplett <josh@joshtriplett.org>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_close_ring_fd(3)

## 名称

io_uring_close_ring_fd - 关闭环文件描述符并仅通过已注册索引使用环

## 概要

```c
#include <liburing.h>

int io_uring_close_ring_fd(struct io_uring *ring);
```

## 描述

[io_uring_close_ring_fd(3)](io_uring_close_ring_fd.3.md) 关闭环文件描述符，而该文件
描述符必须已在先前注册。该文件将保持打开状态，但只能通过已注册索引访问，不能通过
任何文件描述符访问。后续 liburing 调用将继续使用已注册的环 fd 正常工作。

内核必须支持 `IORING_FEAT_REG_REG_RING`。

必须避免干扰用户使用文件描述符，并且面对
[close_range(2)](https://man7.org/linux/man-pages/man2/close_range.2.html)
及类似操作时仍须继续工作的库，可以使用
[io_uring_close_ring_fd(3)](io_uring_close_ring_fd.3.md) 在不持有任何打开的文件
描述符的情况下配合 liburing 工作。

## 注意事项

每个想要使用 io_uring 的线程都必须注册 fd。可能被任意线程调用的库可能需要检测
何时在先前未见过的线程上被调用，并为该线程创建和注册一个环。

## 返回值

成功时返回 1，发生错误时返回 `-errno`。

## 参见

- [io_uring_register_ring_fd(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_ring_fd.3)
