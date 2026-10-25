---
title: io_uring_prep_cmd_discard
section: 3
source_path: man/io_uring_prep_cmd_discard.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 8aeb32f117ff9e8384f057d57ae5411a6d5cd48a5dcab05f4518cf4707d670e1
source_copyright: "Copyright (C) 2024 Pavel Begunkov <asml.silence@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_cmd_discard(3)

## 名称

io_uring_prep_cmd_discard - 准备一个 discard 命令

## 概要

```c
#include <liburing.h>

void io_uring_prep_cmd_discard(struct io_uring_sqe *sqe,
                          int fd,
                          uint64_t offset,
                          uint64_t nbytes);
```

## 描述

[io_uring_prep_cmd_discard(3)](io_uring_prep_cmd_discard.3.md) 函数准备一个 discard
命令请求。提交队列项 `sqe` 会被设置为使用文件描述符 `fd`，从指定 `offset` 开始丢弃
`nbytes`。

该命令是 `BLKDISCARD` ioctl 的异步等价物，但存在一些差异。它允许并行执行多个 discard，
并且不会排除并发写入和读取。因此，如果应用对 discard 操作的相同范围有在途 I/O，
可能会在磁盘数据上引发竞态。用户有责任考虑这一点。此外，只会尽力使页缓存失效。用户
必须确保没有其他在途请求正在修改或读取这些范围。否则，可能导致页缓存过期和数据不
一致。

自 6.12 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。成功时，该字段设置为 `0`。发生错误时，返回负的
错误值。请注意，同步系统调用失败时会返回 `-1`，并将 `errno` 设置为实际错误值；
io_uring 从不使用 `errno`，而是直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
