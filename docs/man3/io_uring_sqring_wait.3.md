---
title: io_uring_sqring_wait
section: 3
source_path: man/io_uring_sqring_wait.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: c767d2cb3be0ddcb624257924708bd0b42801189d037c7856d4281bed106c695
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_sqring_wait(3)

## 名称

io_uring_sqring_wait - 等待 SQ 环中腾出空间

## 概要

```c
#include <liburing.h>

int io_uring_sqring_wait(struct io_uring *ring);
```

## 描述

[io_uring_sqring_wait(3)](io_uring_sqring_wait.3.md) 函数允许调用方等待与 `ring`
参数所属的 SQ 环中腾出空间；当内核侧线程消费一个或多个项时，空间就会释放。如果 SQ
环当前未满，则不会采取任何操作。

仅当环使用 `IORING_SETUP_SQPOLL` 设置，因而采用卸载式请求提交方式时，才能使用此
特性。

## 返回值

成功时返回剩余空间。如果内核不支持此特性，则返回 `-EINVAL`。

## 参见

- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
- [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md)
