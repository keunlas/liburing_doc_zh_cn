---
title: io_uring_cq_advance
section: 3
source_path: man/io_uring_cq_advance.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 9a31915aba5f016228accc12787168afc70d4df46bd4403ff377b770f5428b3d
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_cq_advance(3)

## 名称

io_uring_cq_advance - 将一个或多个 io_uring 完成事件标记为已消费

## 概要

```c
#include <liburing.h>

void io_uring_cq_advance(struct io_uring *ring,
                         unsigned nr);
```

## 描述

[io_uring_cq_advance(3)](io_uring_cq_advance.3.md)
函数将与 `ring` 参数所属的 `nr` 个 I/O 完成标记为已消费。

调用方通过
[io_uring_submit(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit.3)
提交请求后，可以使用
[io_uring_wait_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe.3)、
[io_uring_peek_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_peek_cqe.3)
或任意其他 CQE 获取辅助函数取得完成事件，然后使用
[io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md) 将其标记为已消费。

[io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md) 函数会调用
[io_uring_cq_advance(3)](io_uring_cq_advance.3.md)。

完成事件必须被标记为已见，这样其槽位才能被复用。若不这样做，下一次调用时会再次
返回同一个完成事件。

## 返回值

无。

## 参见

- [io_uring_submit(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit.3)
- [io_uring_wait_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe.3)
- [io_uring_peek_cqe(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_peek_cqe.3)
- [io_uring_wait_cqes(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqes.3)
- [io_uring_wait_cqe_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_wait_cqe_timeout.3)
- [io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md)
