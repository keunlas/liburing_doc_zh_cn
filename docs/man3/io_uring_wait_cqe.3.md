---
title: io_uring_wait_cqe
section: 3
source_path: man/io_uring_wait_cqe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 095430866aec40dc240cb0a427edc9cce8a6f385a8571878df8dc9a7e9ef32cd
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_wait_cqe(3)

## 名称

io_uring_wait_cqe - 等待一个 io_uring 完成事件

## 概要

```c
#include <liburing.h>

int io_uring_wait_cqe(struct io_uring *ring,
                      struct io_uring_cqe **cqe_ptr);
```

## 描述

[io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md) 函数等待与 `ring` 参数所属的队列中的
一个 I/O 完成事件，必要时会等待。如果调用时环中已有可用事件，则不会等待。成功时，
`cqe_ptr` 参数会被填入。

调用方通过
[io_uring_submit(3)](io_uring_submit.3.md)
提交请求后，应用可以使用
[io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md) 取得完成事件。

## 返回值

成功时，[io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md) 返回 0，并填入 `cqe_ptr`
参数。失败时返回 `-errno`。返回值表示等待 CQE 的结果，与 CQE 自身的结果无关。

## 参见

- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_wait_cqe_timeout(3)](io_uring_wait_cqe_timeout.3.md)
- [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md)
