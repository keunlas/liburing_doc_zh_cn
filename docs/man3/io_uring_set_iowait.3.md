---
title: io_uring_set_iowait
section: 3
source_path: man/io_uring_set_iowait.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 8bee6a74f87e2b03e1dd29f31ebc7104cd2d02d9449d47f27152277a1b710976
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2025 Ammar Faizi <ammarfaizi2@gnuweeb.org>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_set_iowait(3)

## 名称

io_uring_set_iowait - 切换等待 CQE 时的 iowait 用法

## 概要

```c
#include <liburing.h>

int io_uring_set_iowait(struct io_uring *ring,
                        bool enable_iowait);
```

## 描述

默认情况下，如果任务正在休眠等待事件并且存在待处理请求，io_uring 会将等待任务标记为
处于 iowait。这不总是有用，并且在预期不会出现 iowait 的非存储设置中可能造成困惑。
它还可能阻止 CPU 进入更低的睡眠状态，从而增加功耗。

[io_uring_set_iowait(3)](io_uring_set_iowait.3.md) 函数允许用户切换此行为。如果
`enable_iowait` 设置为 `true`，则启用 iowait 行为。如果设置为 `false`，则禁用
iowait 行为。创建环时默认启用 iowait 行为。

如果禁用 iowait，提交函数会在
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
的 `flags` 参数中设置 `IORING_ENTER_NO_IOWAIT`。

如果内核支持此特性，则会通过设置 `IORING_FEAT_NO_IOWAIT` 特性标志来表明这一点。

自内核 6.15 起可用。

## 返回值

成功时，[io_uring_set_iowait(3)](io_uring_set_iowait.3.md) 返回 0。失败时返回
`-EOPNOTSUPP`。

## 参见

- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_submit_and_wait(3)](io_uring_submit_and_wait.3.md)
