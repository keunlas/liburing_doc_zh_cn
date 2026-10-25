---
title: io_uring_wait_cqe_timeout
section: 3
source_path: man/io_uring_wait_cqe_timeout.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: e30e54b17b277d113c14d740935dc6a76ae5aac3c61e09f5e5cafb4290183923
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_wait_cqe_timeout(3)

## 名称

io_uring_wait_cqe_timeout - 在带超时的情况下等待一个 io_uring 完成事件

## 概要

```c
#include <liburing.h>

int io_uring_wait_cqe_timeout(struct io_uring *ring,
                              struct io_uring_cqe **cqe_ptr,
                              struct __kernel_timespec *ts);
```

## 描述

[io_uring_wait_cqe_timeout(3)](io_uring_wait_cqe_timeout.3.md) 函数从与 `ring` 参数
所属的队列中等待一个可用的 I/O 完成事件，必要时会等待，或者等待到超时 `ts` 到期。
如果调用时环中已有可用事件，则不会等待。

成功时，`cqe_ptr` 参数会被填入。

如果指定了 `ts`，并且使用的是不支持 `IORING_FEAT_EXT_ARG` 的较旧内核，则应用在
调用 [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md) 前不需要调用
[io_uring_submit(3)](io_uring_submit.3.md)。对于设置了该特性标志的较新内核，在等待
请求时不会隐含提交。

如果 `ts` 为 `NULL`，则此函数的行为与
[io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md) 类似，会一直等待事件。

## 返回值

成功时，[io_uring_wait_cqe_timeout(3)](io_uring_wait_cqe_timeout.3.md) 返回 0，并
填入 `cqe_ptr` 参数。失败时返回 `-errno`。返回值表示等待 CQE 的结果，与 CQE 自身的
结果无关。如果发生超时，将返回 `-ETIME`。

## 参见

- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
