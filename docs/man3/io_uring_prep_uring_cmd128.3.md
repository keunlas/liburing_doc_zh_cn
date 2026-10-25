---
title: io_uring_prep_uring_cmd128
section: 3
source_path: man/io_uring_prep_uring_cmd128.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: ac9fe203f4edbc2958c472c70658dfeb4b6b481175abd02a868f27415e5077b6
source_copyright: "Copyright (C) 2022 Samuel Williams"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_uring_cmd128(3)

## 名称

io_uring_prep_uring_cmd128 - 准备一个 uring_cmd 请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_uring_cmd128(struct io_uring_sqe *sqe,
                                           int cmd_op,
                                           int fd);
```

## 描述

[io_uring_prep_uring_cmd128(3)](io_uring_prep_uring_cmd128.3.md) 函数为 128 字节
提交队列项准备一个 uring_cmd（特定于文件描述符的）请求。提交队列项 `sqe` 会被设置为
使用文件描述符 `fd` 发送特定于该文件描述符的 `cmd_op`。

保留字段会初始化为 0。除此之外，调用方必须设置提交队列项中操作特定的字段。

## 返回值

无。

## 错误

无。

## 参见

- [io_uring_prep_uring_cmd(3)](io_uring_prep_uring_cmd.3.md)
- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
