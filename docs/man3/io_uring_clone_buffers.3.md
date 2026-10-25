---
title: io_uring_clone_buffers
section: 3
source_path: man/io_uring_clone_buffers.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 7b6a202e1daa9adf0c50c38e49eaa17b299fe8caf1196b4f294e009f4b7f8924
source_copyright: "Copyright (C) 2024 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_clone_buffers(3)

## 名称

io_uring_clone_buffers - 在环之间克隆已注册缓冲区

## 概要

```c
#include <liburing.h>

int io_uring_clone_buffers(struct io_uring *dst,
                           struct io_uring *src);

int __io_uring_clone_buffers(struct io_uring *dst,
                             struct io_uring *src,
                             unsigned int flags);

int io_uring_clone_buffers_offset(struct io_uring *dst,
                                  struct io_uring *src,
                                  unsigned int dst_off,
                                  unsigned int src_off,
                                  unsigned int nr,
                                  unsigned int flags);

int __io_uring_clone_buffers_offset(struct io_uring *dst,
                                    struct io_uring *src,
                                    unsigned int dst_off,
                                    unsigned int src_off,
                                    unsigned int nr,
                                    unsigned int flags);
```

## 描述

[io_uring_clone_buffers(3)](io_uring_clone_buffers.3.md) 函数将已注册缓冲区从 `src`
指示的环克隆到 `dst` 指示的环。操作成功完成后，`src` 和 `dst` 将拥有同一组已注册
缓冲区。如果 `src` 环先前完成过相同的缓冲区注册，此操作等同于在 `dst` 环上执行
[io_uring_register_buffers(3)](io_uring_register_buffers.3.md)。

`dst` 环当前不能注册有任何缓冲区。如果目标环当前注册了缓冲区，必须先使用
[io_uring_unregister_buffers(3)](io_uring_unregister_buffers.3.md) 取消注册。

[__io_uring_clone_buffers(3)](io_uring_clone_buffers.3.md) 的唯一区别是接受 `flags`
参数。默认情况下，如果目标环通过
[io_uring_register_ring_fd(3)](io_uring_register_ring_fd.3.md) 注册了文件描述符，
且调用应用不是注册该环的线程，则内核不知道如何查找目标。这会造成问题，因为
[io_uring_clone_buffers(3)](io_uring_clone_buffers.3.md) 在目标按此方式设置时默认使用
已注册索引。应使用不会默认设置 `IORING_REGISTER_SRC_REGISTERED` 的
[__io_uring_clone_buffers(3)](io_uring_clone_buffers.3.md)。这要求应用仍持有原始环
文件描述符。标志定义见下文。

自内核 6.12 起可用。

[io_uring_clone_buffers_offset(3)](io_uring_clone_buffers.3.md) 也会将缓冲区从 `src`
环克隆到 `dst` 环，但支持只克隆一部分缓冲区，而
[io_uring_clone_buffers(3)](io_uring_clone_buffers.3.md) 始终克隆全部缓冲区。
`dst_off` 指示目标中的克隆起始偏移量，`src_off` 指示源中的克隆起始偏移量，`nr`
指示在给定偏移量处克隆多少个缓冲区。如果 `dst_off`、`src_off` 和 `nr` 都设置为 `0`，
则 [io_uring_clone_buffers_offset(3)](io_uring_clone_buffers.3.md) 执行与
[io_uring_clone_buffers(3)](io_uring_clone_buffers.3.md) 相同的操作。

`io_uring_clone_buffers_offset` 默认设置 `IORING_REGISTER_SRC_REGISTERED`，而
`__io_uring_clone_buffers_offset` 不设置。详情请参见
[__io_uring_clone_buffers(3)](io_uring_clone_buffers.3.md) 的说明。

`flags` 可以设置为以下值：

- `IORING_REGISTER_SRC_REGISTERED`：如果源环已注册，并且调用线程是最初注册其环 fd 的
  线程，则可以设置此标志，以查找已注册索引而不是使用普通文件描述符。如果注册后没有
  关闭普通文件描述符，则无需设置此标志。
- `IORING_REGISTER_DST_REPLACE`：如果设置，则可以对已分配缓冲区表的目标环执行克隆。
  此时，与指定范围重叠的现有节点会被释放并替换。

自内核 6.13 起可用。

## 注意事项

源环和目标环必须共享地址空间，因此也必须共享内核内部统计信息。

## 返回值

成功时，`io_uring_clone_buffers` 和 `io_uring_clone_buffers_offset` 返回 0。失败时返回
`-errno`，具体包括：

- `-EBUSY`：目标环已注册缓冲区，且未设置 `IORING_REGISTER_DST_REPLACE`。
- `-ENOMEM`：内核内存耗尽。
- `-ENXIO`：源环未注册任何缓冲区。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_unregister_buffers(3)](io_uring_unregister_buffers.3.md)
- [io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
- [io_uring_prep_read_fixed(3)](io_uring_prep_read_fixed.3.md)
- [io_uring_prep_write_fixed(3)](io_uring_prep_write_fixed.3.md)
