---
title: io_uring_cqe_seen
section: 3
source_path: man/io_uring_cqe_seen.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 2c4cb8631b5722c2ab50f2253a0d63e97e4ab4ca47a3fb91d20a2e76f3d1bcd8
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cqe_seen(3)

## 名称

io_uring_cqe_seen - 将 io_uring 完成事件标记为已消费

## 概要

```c
#include <liburing.h>

void io_uring_cqe_seen(struct io_uring *ring,
                       struct io_uring_cqe *cqe);
```

## 描述

[io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md)
函数将与 `ring` 参数所属的 I/O 完成事件 `cqe` 标记为已消费。

调用方通过
[io_uring_submit(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit.3)
提交请求后，可以使用
[io_uring_wait_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe.3)、
[io_uring_peek_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_peek_cqe.3)
或任意其他 CQE 获取辅助函数取得完成事件，然后使用
[io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md)
将其标记为已消费。

必须对完成事件进行标记，以便其槽位可以被复用。

## 返回值

无。

## 参见

- [io_uring_submit(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit.3)
- [io_uring_peek_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_peek_cqe.3)
- [io_uring_wait_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe.3)
- [io_uring_wait_cqes(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqes.3)
- [io_uring_wait_cqe_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe_timeout.3)
