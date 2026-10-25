---
title: io_uring_register_file_alloc_range
section: 3
source_path: man/io_uring_register_file_alloc_range.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 015f7faa33a66cfe3fb1d509fb702f07f7f44769139881cf80ca712db75dd731
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_file_alloc_range(3)

## 名称

io_uring_register_file_alloc_range - 设置固定文件分配范围

## 概要

```c
#include <liburing.h>

int io_uring_register_file_alloc_range(struct io_uring *ring,
                                       unsigned off,
                                       unsigned len);
```

## 描述

[io_uring_register_file_alloc_range(3)](io_uring_register_file_alloc_range.3.md) 函数
设置内核中允许分配固定文件索引的范围。当可以实例化新固定文件的请求与
`IORING_FILE_INDEX_ALLOC` 一起使用时，应用是在要求内核分配一个新的固定文件描述符，
而不是传入某个具体值。默认情况下，内核会在可用范围内选择任意可用的固定文件描述符。
调用此函数并将 `off` 设置为起始偏移量、将 `len` 设置为描述符数量后，应用就可以将所
分配的描述符限制在该特定范围内。这实际上允许应用预留一个专门用于动态分配的范围，而
其余部分则用于特定值。

应用必须预先注册固定文件表，例如通过
[io_uring_register_files(3)](io_uring_register_files.3.md) 或
[io_uring_register_files_sparse(3)](io_uring_register_files.3.md) 注册。

自 6.0 起可用。

## 返回值

成功时，
[io_uring_register_file_alloc_range(3)](io_uring_register_file_alloc_range.3.md) 返回
0。失败时返回 `-errno`。

## 参见

- [io_uring_register_files(3)](io_uring_register_files.3.md)
- [io_uring_prep_accept_direct(3)](io_uring_prep_accept.3.md)
- [io_uring_prep_openat_direct(3)](io_uring_prep_openat.3.md)
- [io_uring_prep_socket_direct(3)](io_uring_prep_socket.3.md)
