---
title: io_uring_queue_mmap
section: 3
source_path: man/io_uring_queue_mmap.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: d844b37feef9c03059667d4dc1628e746b8e021854a1e33ae7fda8bfd46cfa25
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_queue_mmap(3)

## 名称

io_uring_queue_mmap - 在设置完成后 mmap io_uring 环

## 概要

```c
#include <liburing.h>

int io_uring_queue_mmap(int fd, struct io_uring_params *p,
                        struct io_uring *ring);
```

## 描述

[io_uring_queue_mmap(3)](io_uring_queue_mmap.3.md) 函数使用 `p` 中的参数，将
io_uring 环文件描述符 `fd` 映射到内存中。所得的环存储在 `ring` 中。

此函数是供需要自定义环设置过程的应用使用的辅助函数。大多数应用应改用
[io_uring_queue_init(3)](io_uring_queue_init.3.md) 或
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md)，它们会自动调用
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
和此函数。

`fd` 参数应是由
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
返回的文件描述符，`p` 应包含设置调用返回的参数。

## 返回值

成功时返回 0，发生错误时返回负的 `errno` 值。

## 参见

- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
- [io_uring_queue_init(3)](io_uring_queue_init.3.md)
- [io_uring_queue_init_params(3)](io_uring_queue_init.3.md)
- [io_uring_queue_exit(3)](io_uring_queue_exit.3.md)
