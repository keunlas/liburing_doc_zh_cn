---
title: io_uring_prep_cmd_zone_reset_all
section: 3
source_path: man/io_uring_prep_cmd_zone_reset_all.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b459b1dc0c4691860b3a3bb219613c53503474a137520988502b5e5cc860a0ff
source_copyright: "Copyright (C) 2026 Christoph Hellwig <hch@lst.de>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_cmd_zone_reset_all(3)

## 名称

io_uring_prep_cmd_zone_reset_all - 准备一个 zone_reset_all 命令

## 概要

```c
#include <liburing.h>

void io_uring_prep_cmd_zone_reset_all(struct io_uring_sqe *sqe, int fd);
```

## 描述

[io_uring_prep_cmd_zone_reset_all(3)](io_uring_prep_cmd_zone_reset_all.3.md) 函数
准备一个 zone_reset_all 命令请求。提交队列项 `sqe` 会被设置为重置 `fd` 所指向块设备
上所有要求顺序写入的区域（zone）。

此命令不会与并发文件操作同步，包括但不限于读取、写入、ioctl 和其他 uring_cmd，并且
只会尽力使该设备的页缓存失效。用户必须确保没有其他在途请求正在修改或读取这些范围。
否则，可能导致页缓存过期和数据不一致。

自 Linux 7.3 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。成功时，该字段设置为 `0`。发生错误时，返回负的
错误值。请注意，同步系统调用失败时会返回 `-1`，并将 `errno` 设置为实际错误值；
io_uring 从不使用 `errno`，而是直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
