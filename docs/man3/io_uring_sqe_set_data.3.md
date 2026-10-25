---
title: io_uring_sqe_set_data
section: 3
source_path: man/io_uring_sqe_set_data.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a5830275de86b134cc723a3870cdbc1d4c5ae33117f88396c987df02425ff9ce
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_sqe_set_data(3)

## 名称

io_uring_sqe_set_data - 设置提交队列事件的用户数据

## 概要

```c
#include <liburing.h>

void io_uring_sqe_set_data(struct io_uring_sqe *sqe,
                           void *user_data);

void io_uring_sqe_set_data64(struct io_uring_sqe *sqe,
                             __u64 data);
```

## 描述

[io_uring_sqe_set_data(3)](io_uring_sqe_set_data.3.md) 函数将 `user_data` 指针与提交
队列项 `sqe` 存储在一起。

[io_uring_sqe_set_data64(3)](io_uring_sqe_set_data.3.md) 函数将 64 位 `data` 值与
提交队列项 `sqe` 存储在一起。

调用方通过
[io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
请求提交队列项（SQE）后，可以将数据指针或数据值与该 SQE 关联。完成事件到达后，
可以调用
[io_uring_cqe_get_data(3)](io_uring_cqe_get_data.3.md)
或
[io_uring_cqe_get_data64(3)](io_uring_cqe_get_data.3.md)
函数，以取得与所提交请求关联的数据指针或数据值。

请注意，如果这两个函数都未被调用，并且 `sqe` 中的 `user_data` 字段也没有被手动
设置，那么该字段可能包含此 SQE 以前使用后遗留的值。如果应用依赖始终存在有效的
`user_data` 值，则必须为每个 SQE 都设置该值。

## 返回值

无。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_cqe_get_data(3)](io_uring_cqe_get_data.3.md)
