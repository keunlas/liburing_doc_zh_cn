---
title: io_uring_wait_cqe_nr
section: 3
source_path: man/io_uring_wait_cqe_nr.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 9e13be0263b4c19758f1c45421e4eda62fd22ce41b68ca758888199b51495335
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_wait_cqe_nr(3)

## 名称

io_uring_wait_cqe_nr - 等待一个或多个 io_uring 完成事件

## 概要

```c
#include <liburing.h>

int io_uring_wait_cqe_nr(struct io_uring *ring,
                         struct io_uring_cqe **cqe_ptr,
                         unsigned wait_nr);
```

## 描述

[io_uring_wait_cqe_nr(3)](io_uring_wait_cqe_nr.3.md) 函数从与 `ring` 参数所属的队列
中返回 `wait_nr` 个 I/O 完成事件，必要时会等待。如果调用时环中已有请求数量的事件
可用，则不会等待。成功时，`cqe_ptr` 参数会被填入。

调用方通过
[io_uring_submit(3)](io_uring_submit.3.md)
提交请求后，应用可以使用
[io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md) 取得完成事件。

理想情况下，应与使用
`IORING_SETUP_SINGLE_ISSUER | IORING_SETUP_DEFER_TASKRUN` 设置的环配合使用，因为
这会大幅减少应用等待多个请求时出现的上下文切换次数。

## 返回值

成功时，[io_uring_wait_cqe_nr(3)](io_uring_wait_cqe_nr.3.md) 返回 0，并填入
`cqe_ptr` 参数。失败时返回 `-errno`。返回值表示等待 CQE 的结果，与 CQE 自身的结果
无关。

## 参见

- [io_uring_queue_init_params(3)](io_uring_queue_init.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md)
