---
title: io_uring_register_buffers
section: 3
source_path: man/io_uring_register_buffers.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 888f131195d23f35c642d0be48d9a54f9aac4c700716c112f795ab9737a7c5de
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_buffers(3)

## 名称

io_uring_register_buffers - 为固定缓冲区操作注册缓冲区

## 概要

```c
#include <liburing.h>

int io_uring_register_buffers(struct io_uring *ring,
                              const struct iovec *iovecs,
                              unsigned nr_iovecs);

int io_uring_register_buffers_tags(struct io_uring *ring,
                                   const struct iovec *iovecs,
                                   const __u64 *tags,
                                   unsigned nr);

int io_uring_register_buffers_sparse(struct io_uring *ring,
                                     unsigned nr_iovecs);

int io_uring_register_buffers_update_tag(struct io_uring *ring,
                                         unsigned off,
                                         const struct iovec *iovecs,
                                         const __u64 *tags,
                                         unsigned nr);
```

## 描述

[io_uring_register_buffers(3)](io_uring_register_buffers.3.md) 函数为 `ring` 所属的
操作注册由数组 `iovecs` 定义的 `nr_iovecs` 个缓冲区。

[io_uring_register_buffers_tags(3)](io_uring_register_buffers.3.md) 函数的行为与
[io_uring_register_buffers(3)](io_uring_register_buffers.3.md) 函数相同，但额外接受
`tags` 参数。有关资源标签的说明，请参见 `IORING_REGISTER_BUFFERS2`。

[io_uring_register_buffers_sparse(3)](io_uring_register_buffers.3.md) 函数为 `ring`
所属的操作注册 `nr_iovecs` 个空缓冲区。使用前必须更新这些缓冲区，例如使用
[io_uring_register_buffers_update_tag(3)](io_uring_register_buffers.3.md)。

调用方注册缓冲区后，可以在某个固定缓冲区函数中使用它们。

iovec 仅由内核用于注册目的，注册完成后即可释放（也可以放在栈上）。

注册缓冲区是一种优化，与 `O_DIRECT` 读写结合使用时很有用：注册缓冲区时会将指定范围
映射到内核一次，而不是每次对该区域执行 I/O 时都进行映射和取消映射。此外，它还避免
在每次 I/O 时操作页引用计数。

[io_uring_register_buffers_update_tag(3)](io_uring_register_buffers.3.md) 函数使用新
缓冲区更新已注册缓冲区，可以将稀疏项转换为实际项，也可以替换现有项。`off` 是开始
更新 `ring` 所属、由数组 `iovecs` 定义的 `nr` 个缓冲区时所用的偏移量。`tags` 指向
标签数组。有关资源标签的说明，请参见 `IORING_REGISTER_BUFFERS2`。

## 返回值

成功时，[io_uring_register_buffers(3)](io_uring_register_buffers.3.md)、
[io_uring_register_buffers_tags(3)](io_uring_register_buffers.3.md) 和
[io_uring_register_buffers_sparse(3)](io_uring_register_buffers.3.md) 返回 0。
[io_uring_register_buffers_update_tag(3)](io_uring_register_buffers.3.md) 返回已更新的
缓冲区数量。失败时，这些函数返回 `-errno`。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_unregister_buffers(3)](io_uring_unregister_buffers.3.md)
- [io_uring_clone_buffers(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_clone_buffers.3)
- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
- [io_uring_prep_read_fixed(3)](io_uring_prep_read_fixed.3.md)
- [io_uring_prep_write_fixed(3)](io_uring_prep_write_fixed.3.md)
