---
title: io_uring_register_clock
section: 3
source_path: man/io_uring_register_clock.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: dc2c3b5eac518604e6dbbaaf179f2c21a66b59a75e504bc2dd0c5cc279eb625d
source_copyright: "Copyright (C) 2024 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_clock(3)

## 名称

io_uring_register_clock - 设置等待事件所用的时钟源

## 概要

```c
#include <liburing.h>

int io_uring_register_clock(struct io_uring *ring,
                            struct io_uring_clock_register *arg);
```

## 描述

当应用等待事件完成时，[io_uring_register_clock(3)](io_uring_register_clock.3.md) 函数
注册 io_uring 应使用的时钟源。`ring` 参数应指向相关环，`arg` 参数应指向一个
`struct io_uring_clock_register`。

`arg` 参数必须填入适当信息。其结构如下：

```c
struct io_uring_clock_register {
    __u32 clockid;
    __u32 __resv[3];
};
```

`clockid` 字段必须包含时钟源，有效来源为：

- `CLOCK_MONOTONIC`：一种不可设置的全系统时钟，表示单调时间。
- `CLOCK_BOOTTIME`：一种不可设置的全系统时钟，与 `CLOCK_MONOTONIC` 相同，区别在于
  它还会计入系统挂起的时间。

详情请参见
[clock_gettime(3)](https://man7.org/linux/man-pages/man3/clock_gettime.3.html)。

`__resv` 字段必须填入 0。

自 6.12 起可用。

## 返回值

成功时，[io_uring_register_clock(3)](io_uring_register_clock.3.md) 返回 0。失败时
返回 `-errno`。

## 参见

- [clock_gettime(3)](https://man7.org/linux/man-pages/man3/clock_gettime.3.html)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
- [io_uring_wait_cqe_timeout(3)](io_uring_wait_cqe_timeout.3.md)
