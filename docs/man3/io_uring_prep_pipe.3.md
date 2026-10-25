---
title: io_uring_prep_pipe
section: 3
source_path: man/io_uring_prep_pipe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 57927988b63b9bb0ee6e5f60708cc45d40e38bc14f20929d3ad6dd57c9633b85
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_pipe(3)

## 名称

io_uring_prep_pipe - 准备一个管道创建请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_pipe(struct io_uring_sqe *sqe,
                        int *fds,
                        int pipe_flags);

void io_uring_prep_pipe_direct(struct io_uring_sqe *sqe,
                               int *fds,
                               int pipe_flags,
                               unsigned int file_index);
```

## 描述

[io_uring_prep_pipe(3)](io_uring_prep_pipe.3.md) 函数准备一个管道创建请求。提交队列
项 `sqe` 会被设置为创建一个管道，创建出的描述符会复制到 `fds` 指示的数组中，并使用
`pipe_flags` 作为管道创建标志。有关可接受标志的详情，请参见
[pipe2(2)](https://man7.org/linux/man-pages/man2/pipe2.2.html)。

[io_uring_prep_pipe_direct(3)](io_uring_prep_pipe.3.md) 函数的工作方式相同，但使用
固定/已注册文件描述符，而不是普通文件描述符。此辅助函数额外接受 `file_index` 参数，
可将其设置为用于创建两个管道文件描述符的显式直接描述符偏移量，也可设置为
`IORING_FILE_INDEX_ALLOC`，让 io_uring 为管道的读取端和写入端选择任意可用描述符。
如果给出特定索引，则管道的读取端会在该偏移量处创建（如果该位置空闲），写入端会在
下一个（+1）索引处创建。这两项当前都必须未使用，否则操作将失败。有关 `file_index`
参数的详情，另请参见
[io_uring_prep_accept_direct(3)](io_uring_prep_accept.3.md) 或
[io_uring_prep_socket_direct(3)](io_uring_prep_socket.3.md)。

对于直接和普通文件描述符管道请求，在此请求成功完成后，所得管道的输入/读取端会存储在
`fds[0]` 中，输出/写入端会存储在 `fds[1]` 中。

此函数准备一个异步
[pipe2(2)](https://man7.org/linux/man-pages/man2/pipe2.2.html) 请求。详情请参见该
手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [pipe2(2)](https://man7.org/linux/man-pages/man2/pipe2.2.html)
- [io_uring_prep_accept_direct(3)](io_uring_prep_accept.3.md)
- [io_uring_prep_socket_direct(3)](io_uring_prep_socket.3.md)
