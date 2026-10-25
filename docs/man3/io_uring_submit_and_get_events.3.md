---
title: io_uring_submit_and_get_events
section: 3
source_path: man/io_uring_submit_and_get_events.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 8ff6c1ad45e37f50737898c75e08967524de81cb516cc35c13fa2af52c90ac55
source_copyright: "Copyright (C), 2022 dylany"
translation_status: draft
translated_at: 2026-10-25
license: LicenseRef-GFDL
---

# io_uring_submit_and_get_events(3)

## 名称

io_uring_submit_and_get_events - 向提交队列提交请求并刷新完成事件

## 概要

```c
#include <liburing.h>

int io_uring_submit_and_get_events(struct io_uring *ring);
```

## 描述

[io_uring_submit_and_get_events(3)](io_uring_submit_and_get_events.3.md) 函数像
[io_uring_submit(3)](io_uring_submit.3.md) 一样，将提交队列中的下一批事件提交。提交后，
它会像
[io_uring_get_events(3)](io_uring_get_events.3.md) 一样刷新 CQE。

此函数的优势是只使用一次系统调用即可完成这两项操作。

## 返回值

成功时，[io_uring_submit_and_get_events(3)](io_uring_submit_and_get_events.3.md) 返回
已提交的提交队列项数量。失败时返回 `-errno`。有关
[io_uring_submit_and_get_events(3)](io_uring_submit_and_get_events.3.md) 可能返回的
错误码详情，请参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。

## 参见

- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_get_events(3)](io_uring_get_events.3.md)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
