---
title: io_uring_prep_writev_fixed
section: 3
source_path: man/io_uring_prep_writev_fixed.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 70df1409816b291d359314887041784d4aa5468f71cd023fb5a5e965caab557c
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_writev_fixed(3)

## 名称

io_uring_prep_writev_fixed - 使用固定缓冲区准备向量写入请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_writev_fixed(struct io_uring_sqe *sqe,
                                int fd,
                                const struct iovec *iovecs,
                                unsigned nr_vecs,
                                __u64 offset,
                                int flags,
                                int buf_index);
```

## 描述

[io_uring_prep_writev_fixed(3)](io_uring_prep_writev_fixed.3.md) 使用固定（已注册）
缓冲区准备一个向量写入请求。提交队列项 `sqe` 会被设置为使用文件描述符 `fd`，从文件
位置 `offset` 开始写入 `nr_vecs` 个 iovec。

`iovecs` 参数指向一个 iovec 结构体数组，这些结构体描述写入缓冲区。所有缓冲区都必须
属于索引 `buf_index` 处的已注册缓冲区集合，并且该集合已先前通过
[io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
注册。

`flags` 参数可以包含任意按请求生效的标志，例如 `RWF_APPEND` 或
[pwritev2(2)](https://man7.org/linux/man-pages/man2/pwritev2.2.html) 支持的其他标志。

使用固定缓冲区可避免在每次 I/O 操作时映射缓冲区的开销，从而提高重用同一组缓冲区的
应用的性能。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果；成功时为写入的字节数。发生错误时，返回负的 `errno`
值。

## 注意事项

尽管此函数接受一个 iovec 数组，其中每个 iovec 的字节数为 `size_t`，但每次调用最多
只能传输 `INT_MAX` 字节（底层系统调用接口的最大值）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_writev(3)](io_uring_prep_writev.3.md)
- [io_uring_prep_writev2(3)](io_uring_prep_writev2.3.md)
- [io_uring_prep_write_fixed(3)](io_uring_prep_write_fixed.3.md)
- [io_uring_prep_readv_fixed(3)](io_uring_prep_readv_fixed.3.md)
- [io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
