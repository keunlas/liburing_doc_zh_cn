---
title: io_uring_register_files
section: 3
source_path: man/io_uring_register_files.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: d2cc8a306a009bd76d0aacb23c792b5538704ab6c7624e677e7381ab11c7c6d4
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_files(3)

## 名称

io_uring_register_files - 注册文件描述符

## 概要

```c
#include <liburing.h>

int io_uring_register_files(struct io_uring *ring,
                            const int *files,
                            unsigned nr_files);

int io_uring_register_files_tags(struct io_uring *ring,
                                 const int *files,
                                 const __u64 *tags,
                                 unsigned nr);

int io_uring_register_files_sparse(struct io_uring *ring,
                                   unsigned nr_files);

int io_uring_register_files_update(struct io_uring *ring,
                                   unsigned off,
                                   const int *files,
                                   unsigned nr_files);

int io_uring_register_files_update_tag(struct io_uring *ring,
                                   unsigned off,
                                   const int *files,
                                   const __u64 *tags,
                                   unsigned nr_files);
```

## 描述

[io_uring_register_files(3)](io_uring_register_files.3.md) 函数为 `ring` 所属的后续
操作注册由数组 `files` 定义的 `nr_files` 个文件描述符。

[io_uring_register_files_tags(3)](io_uring_register_files.3.md) 函数的行为与
[io_uring_register_files(3)](io_uring_register_files.3.md) 函数相同，但额外接受
`tags` 参数。有关资源标签的说明，请参见 `IORING_REGISTER_BUFFERS2`。

[io_uring_register_files_sparse(3)](io_uring_register_files.3.md) 函数注册一个包含
`nr_files` 个文件描述符的空文件表。使用前必须更新这些文件，例如使用
[io_uring_register_files_update_tag(3)](io_uring_register_files.3.md)。请注意，如果
稀疏表的大小超过 `RLIMIT_NOFILE` 允许的值，则
[io_uring_register_files_sparse(3)](io_uring_register_files.3.md) 会尝试使用
[setrlimit(2)](https://man7.org/linux/man-pages/man2/setrlimit.2.html) 提高该限制，
并重试此操作。如果执行该操作后注册仍然失败，则返回错误。稀疏变体在内核 5.19 及更高
版本中可用。

注册文件表是使用任何采用直接描述符的请求的前提条件。

已注册文件的每次操作开销低于普通文件。这是因为内核会在操作开始时获取文件的引用计数，
并在操作完成时释放它。当进程文件表被共享时，例如进程曾经创建过任何线程，这一开销会
进一步增加。使用已注册文件可以降低对文件进行操作的多个请求之间管理文件引用的开销。

[io_uring_register_files_update(3)](io_uring_register_files.3.md) 函数更新现有的
已注册文件。`off` 是开始更新 `ring` 所属、由数组 `files` 定义的 `nr_files` 个文件时
所用的偏移量。

[io_uring_register_files_update_tag(3)](io_uring_register_files.3.md) 函数的行为与
[io_uring_register_files_update(3)](io_uring_register_files.3.md) 函数相同，但额外
接受 `tags` 参数。有关资源标签的说明，请参见 `IORING_REGISTER_BUFFERS2`。

## 返回值

成功时，[io_uring_register_files(3)](io_uring_register_files.3.md)、
[io_uring_register_files_tags(3)](io_uring_register_files.3.md) 和
[io_uring_register_files_sparse(3)](io_uring_register_files.3.md) 返回 0。
[io_uring_register_files_update(3)](io_uring_register_files.3.md) 和
[io_uring_register_files_update_tag(3)](io_uring_register_files.3.md) 返回已更新的
文件数量。失败时，这些函数返回 `-errno`。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_unregister_files(3)](io_uring_unregister_files.3.md)
