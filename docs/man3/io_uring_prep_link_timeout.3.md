---
title: io_uring_prep_link_timeout
section: 3
source_path: man/io_uring_prep_link_timeout.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 1bd05c8cfa7a17b2c7b19d072b645e1865249534747f692e1b82c8d6df1ab2f2
source_copyright: "Copyright (C) 2023 Rutvik Patel <heyrutvik@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_link_timeout(3)

## 名称

io_uring_prep_link_timeout - 为链接的 SQE 准备一个超时请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_link_timeout(struct io_uring_sqe *sqe,
                                const struct __kernel_timespec *ts,
                                unsigned flags);
```

## 描述

[io_uring_prep_link_timeout(3)](io_uring_prep_link_timeout.3.md) 函数为链接的 SQE
准备一个超时请求。提交队列项 `sqe` 会被设置为使用 `ts` 指定的超时。flags 参数包含
用于指定该请求超时行为的修饰标志 `flags`。

`ts` 参数必须填入适用于该超时的信息。其结构如下：

```c
struct __kernel_timespec {
    __kernel_time64_t tv_sec;
    long long tv_nsec;
};
```

`flags` 参数可以包含：

- `IORING_TIMEOUT_ABS`：`ts` 中指定的值是绝对值，而不是相对值。
- `IORING_TIMEOUT_BOOTTIME`：应使用 boottime 时钟源。
- `IORING_TIMEOUT_REALTIME`：应使用 realtime 时钟源。
- `IORING_TIMEOUT_ETIME_SUCCESS`：在已发布完成事件的意义上将超时到期视为成功。

创建一条只包含链接超时请求的链是无效的。如果链中的所有请求都在超时之前完成，那么
链接超时请求会被取消。发生超时时，链中所有未完成的请求都会被取消。

## 返回值

无。

## 错误

以下是 CQE 的 `res` 字段中报告的错误。成功时返回 `0`。

- `-ETIME`：指定的超时已发生，并触发了完成事件。
- `-EINVAL`：SQE 中设置的某个字段无效。例如，给出了两个时钟源，或者指定的超时秒数
  或纳秒数小于 0。
- `-EFAULT`：io_uring 无法访问 `ts` 指定的数据。
- `-ECANCELED`：由于所有已提交请求都成功完成，或者其中一个请求失败，该超时被取消。
- `-ENOENT`：链接超时所指的请求已经完成，因此定时器到期时无法找到该请求。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_prep_timeout(3)](io_uring_prep_timeout.3.md)
