---
title: io_uring_cqe_get_data
section: 3
source_path: man/io_uring_cqe_get_data.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2f35b11a9a53fa4cdf74ab680163983a75c8e67f1e758ccd7d778e37cba92387
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cqe_get_data(3)

## 名称

io_uring_cqe_get_data - 获取完成事件的用户数据

## 概要

```c
#include <liburing.h>

void *io_uring_cqe_get_data(struct io_uring_cqe *cqe);

__u64 io_uring_cqe_get_data64(struct io_uring_cqe *cqe);
```

## 描述

[io_uring_cqe_get_data(3)](io_uring_cqe_get_data.3.md)
函数将完成队列项 `cqe` 中的 `user_data` 作为数据指针返回。

[io_uring_cqe_get_data64(3)](io_uring_cqe_get_data.3.md)
函数将完成队列项 `cqe` 中的 `user_data` 作为 64 位数据值返回。

调用方通过
[io_uring_wait_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe.3)
收到完成队列项（CQE）后，可以调用
[io_uring_cqe_get_data(3)](io_uring_cqe_get_data.3.md)
或
[io_uring_cqe_get_data64(3)](io_uring_cqe_get_data.3.md)
函数取得 `user_data` 值。这要求此前已使用
[io_uring_sqe_set_data(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_sqe_set_data.3)
或
[io_uring_sqe_set_data64(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_sqe_set_data.3)
函数设置 `user_data`。

## 返回值

如果在提交请求前已经设置了 `user_data` 值，则返回该值。否则，返回值未定义。

## 参见

- [io_uring_get_sqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_get_sqe.3)
- [io_uring_sqe_set_data(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_sqe_set_data.3)
- [io_uring_submit(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit.3)
