---
title: io_uring_cq_has_overflow
section: 3
source_path: man/io_uring_cq_has_overflow.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 669ccc0a160e69e9d9e49ad1d9eafa6d1c411206d2646645b3e395d9b4d4d642
source_copyright: "Copyright (C) 2022 Dylan Yudaken <dylany@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cq_has_overflow(3)

## 名称

io_uring_cq_has_overflow - 返回是否有溢出项正等待移入 CQ 环

## 概要

```c
#include <liburing.h>

bool io_uring_cq_has_overflow(const struct io_uring *ring);
```

## 描述

[io_uring_cq_has_overflow(3)](io_uring_cq_has_overflow.3.md)
函数告知应用 CQ 项是否已溢出，并且正等待被刷新到 CQ 环。例如，可以使用
[io_uring_get_events(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_get_events.3)。

## 注意事项

仅当环设置了 `IORING_FEAT_NODROP` 时，才能使用此函数，因为它检查的是支持该特性的
内核所设置的一个标志。对于不支持此特性的很旧内核，如果发生 CQE 溢出，CQE 会丢失。
如果发生这种情况，CQ 环的溢出偏移量将递增。

## 返回值

如果有 CQ 项正等待刷新到 CQ 环，返回 `true`。

## 参见

- [io_uring_get_events(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_get_events.3)
