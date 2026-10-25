---
title: io_uring_peek_cqe
section: 3
source_path: man/io_uring_peek_cqe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 9cdd55f1af2ec4067190bda7980b73f8f17c2386b787f6f53250ee8b58f19f1f
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_peek_cqe(3)

## 名称

io_uring_peek_cqe - 检查是否有可用的 io_uring 完成事件

## 概要

```c
#include <liburing.h>

int io_uring_peek_cqe(struct io_uring *ring,
                      struct io_uring_cqe **cqe_ptr);

unsigned io_uring_peek_batch_cqe(struct io_uring *ring,
                                 struct io_uring_cqe **cqe_ptrs,
                                 unsigned count);
```

## 描述

如果与 `ring` 参数所属的队列中有现成可用的 I/O 完成事件，
[io_uring_peek_cqe(3)](io_uring_peek_cqe.3.md) 函数会返回其中一个。成功返回时，
`cqe_ptr` 参数会被填入一个有效的 CQE 项。

此函数不会进入内核等待事件；仅当事件已在 CQ 环中可用时，才会返回该事件。

如果与 `ring` 参数所属的完成事件中有现成可用的项，
[io_uring_peek_batch_cqe(3)](io_uring_peek_cqe.3.md) 函数会将最多 `count` 个请求
完成事件返回到 `cqe_ptrs` 中。除非 CQ 环处于溢出状态，否则它不会进入内核。成功
返回时，`cqe_ptrs` 会按返回值指示的事件数量填入。

## 返回值

成功时，[io_uring_peek_cqe(3)](io_uring_peek_cqe.3.md) 返回 `0`，并填入 `cqe_ptr`
参数。成功时，[io_uring_peek_batch_cqe(3)](io_uring_peek_cqe.3.md) 返回已填入的
完成事件数量。失败时，[io_uring_peek_cqe(3)](io_uring_peek_cqe.3.md) 可能返回
`-EAGAIN`。

## 参见

- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
