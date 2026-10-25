---
title: io_uring_prep_write_fixed
section: 3
source_path: man/io_uring_prep_write_fixed.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 68d1712e2ec4b7ce45c4b7a19bff7358890e9a69d8fdd8370b2762d26051e36c
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_write_fixed(3)

## 名称

io_uring_prep_write_fixed - 准备使用已注册缓冲区的 I/O 写入请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_write_fixed(struct io_uring_sqe *sqe,
                        int fd,
                        const void *buf,
                        unsigned nbytes,
                        __u64 offset,
                        int buf_index);
```

## 描述

[io_uring_prep_write_fixed(3)](io_uring_prep_write_fixed.3.md) 使用先前注册的 I/O
缓冲区准备一个 I/O 写入请求。提交队列项 `sqe` 会被设置为使用文件描述符 `fd`，从
指定的 `offset` 开始将缓冲区 `buf` 中的 `nbytes` 字节写入，并且缓冲区与
`buf_index` 的已注册索引匹配。

其工作方式与
[io_uring_prep_write(3)](io_uring_prep_write.3.md) 相同，只是要求使用已通过
[io_uring_register_buffers(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_buffers.3)
注册的缓冲区。`buf` 和 `nbytes` 参数必须位于先前注册的缓冲区中由 `buf_index` 指定
的区域内。缓冲区无需与已注册缓冲区的起始位置对齐。

写入请求准备好后，可以使用某个提交函数提交。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

尽管此函数接受无符号的字节数，但每次调用最多只能传输 `INT_MAX` 字节（底层系统调用
接口的最大值）。

## 参见

- [io_uring_prep_write(3)](io_uring_prep_write.3.md)
- [io_uring_register_buffers(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_buffers.3)
