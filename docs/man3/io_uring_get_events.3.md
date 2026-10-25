---
title: io_uring_get_events
section: 3
source_path: man/io_uring_get_events.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 903733a68b6815bbf08e23acd86d17e4c483227430ef85f5af3d23631913d49f
source_copyright: "Copyright (C) 2022 Dylan Yudaken"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_get_events(3)

## 名称

io_uring_get_events - 将未完成的请求刷新到 CQE 环

## 概要

```c
#include <liburing.h>

int io_uring_get_events(struct io_uring *ring);
```

## 描述

[io_uring_get_events(3)](io_uring_get_events.3.md) 函数运行未完成的工作，并将完成
事件刷新到 CQE 环。

如果环已满并发生了溢出，可能会有事件需要刷新。另外，如果环使用
`IORING_SETUP_DEFER_TASKRUN` 标志设置，此函数将处理未完成的任务，并可能因此产生
更多 CQE。

## 返回值

成功时，[io_uring_get_events(3)](io_uring_get_events.3.md) 返回 0。失败时返回
`-errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit_and_get_events(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_get_events.3)
- [io_uring_cq_has_overflow(3)](io_uring_cq_has_overflow.3.md)
