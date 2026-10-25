---
title: io_uring_free_buf_ring
section: 3
source_path: man/io_uring_free_buf_ring.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 571ed9337b6ee25a8f7ed7582e8c4dd8c75beef7a8152059c913c02897f84fc4
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_free_buf_ring(3)

## 名称

io_uring_free_buf_ring - 取消注册并释放用于提供的缓冲区的缓冲区环

## 概要

```c
#include <liburing.h>

int io_uring_free_buf_ring(struct io_uring *ring,
                           struct io_uring_buf_ring *br,
                           unsigned int nentries,
                           int bgid);
```

## 描述

[io_uring_free_buf_ring(3)](io_uring_free_buf_ring.3.md) 函数取消注册先前注册的共享
缓冲区环。该环必须先前由
[io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md) 返回。

`ring` 参数必须指向正在为其取消注册提供的缓冲区环的环；`br` 必须指向先前由
[io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md) 返回的缓冲区环；
`nentries` 是缓冲区环中请求的项数；`bgid` 是设置 `br` 时使用的缓冲区组 ID。

在内部，此函数使用
[io_uring_unregister_buf_ring(3)](io_uring_unregister_buf_ring.3.md) 取消注册该环，
并处理环的释放，而不是让应用通过内联代码自行完成。

自 5.19 起可用。

## 返回值

成功时，[io_uring_free_buf_ring(3)](io_uring_free_buf_ring.3.md) 返回 0。失败时返回
`-errno`。

## 参见

- [io_uring_setup_buf_ring(3)](io_uring_setup_buf_ring.3.md)
