---
title: io_uring_submit_and_wait_reg
section: 3
source_path: man/io_uring_submit_and_wait_reg.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: fd513b5069c0b9493f6d3d40d023fe7fdcc698f017182b6e49d81ca79f103a05
source_copyright: "Copyright (C) 2024 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_submit_and_wait_reg(3)

## 名称

io_uring_submit_and_wait_reg - 设置并使用已注册的固定等待区域

## 概要

```c
#include <liburing.h>

int io_uring_submit_and_wait_reg(struct io_uring *ring,
                                 struct io_uring_cqe **cqe_ptr,
                                 unsigned wait_nr,
                                 int reg_index);
```

## 描述

[io_uring_submit_and_wait_reg(3)](io_uring_submit_and_wait_reg.3.md) 提交环 `ring`
中先前准备好的请求，并使用已注册的等待索引 `reg_index` 等待 `wait_nr` 个完成事件。
成功返回时，完成事件存储在 `cqe_ptr` 数组中。

此函数的工作方式与
[io_uring_submit_and_wait_min_timeout(3)](io_uring_submit_and_wait_min_timeout.3.md)
类似，支持该辅助函数的所有特性，但它不通过需要复制的结构体传入全部信息，而是引用一个
已注册等待索引；该索引所对应的先前注册等待区域包含如何执行等待的信息。这些信息包括
总超时、要使用的最小超时等。有关已注册区域（特别是已注册等待区域）的详情，请参见
[io_uring_register_region(3)](io_uring_register_region.3.md)。

使用已注册等待区域比其他等待方式的开销更低，因为不需要复制数据。

即使不应提交任何新请求，也可以纯粹使用此函数等待事件。

## 返回值

成功时，[io_uring_submit_and_wait_reg(3)](io_uring_submit_and_wait_reg.3.md) 返回新
提交的请求数量。失败时返回 `-errno`。如果内核不支持此功能，则返回 `-EINVAL`。如果
没有提交事件且等待操作超时，则返回 `-ETIME`。否则，其余可能错误码的详情请参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。

## 参见

- [io_uring_register_region(3)](io_uring_register_region.3.md)
- [io_uring_submit_and_wait_min_timeout(3)](io_uring_submit_and_wait_min_timeout.3.md)
- [io_uring_submit_and_wait_timeout(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_submit_and_wait_timeout.3)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
