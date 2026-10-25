---
title: io_uring_prep_read_multishot
section: 3
source_path: man/io_uring_prep_read_multishot.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 56374880b4eb576042419606de7c81d907ed341e89236c55c66007886e572683
source_copyright: "Copyright (C) 2023 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_read_multishot(3)

## 名称

io_uring_prep_read_multishot - 准备 I/O 多轮触发读取请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_read_multishot(struct io_uring_sqe *sqe,
                                  int fd,
                                  unsigned nbytes,
                                  __u64 offset,
                                  int buf_group);
```

## 描述

[io_uring_prep_read_multishot(3)](io_uring_prep_read_multishot.3.md) 辅助函数准备
一个 I/O 多轮触发读取请求。提交队列项 `sqe` 会被设置为使用文件描述符 `fd`，从指定
的 `offset` 开始，读取到 ID 为 `buf_group` 的提供的缓冲区组中的某个缓冲区。

`nbytes` 必须设置为 0，因为读取大小由指定缓冲区组中缓冲区的大小决定。

对于不能寻址的文件，偏移量必须为 0 或 -1。

如果 `nbytes` 超过指定缓冲区组中缓冲区的大小，或者 `nbytes` 为 `0`，则将使用该组中
缓冲区的大小进行传输。

只要文件中有可读取的数据，多轮触发读取请求就会反复触发完成事件。因此，这种类型的
请求只能用于可轮询的文件类型。示例包括管道、tun 设备等。如果用于普通文件，或一般
情况下的错误文件类型，该请求将失败，并在 CQE 的 `res` 字段中返回 `-EBADFD`。

由于多轮触发请求会在数据到达时反复触发完成事件，因此它必须与提供的缓冲区配合使用。
使用提供的缓冲区时，应用预先向 io_uring 提供缓冲区，然后当请求准备好传输数据时，
内核从 `buf_group` 中指定的组里选择一个缓冲区。

只要处理该请求期间未遇到任何错误，多轮触发请求就会持续存在。对于代表该请求发布的
每个 CQE，如果应用应预期该请求还会产生更多完成事件，则 CQE 的 `flags` 中会设置
`IORING_CQE_F_MORE`。如果未设置此标志，则表示该多轮触发读取请求已终止。

读取请求准备好后，可以使用某个提交函数提交。

自 6.7 起可用。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

此函数接受无符号的字节数，但 `io_uring_cqe` 的结果代码是 `__s32` 值，因此理论上，
如果 `nbytes` 足够大，短读可能产生有歧义的返回值。但是，实际传输的字节数具有与
[read(2)](https://man7.org/linux/man-pages/man2/read.2.html) 相同的限制，因此在
实践中不会发生这种情况。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_prep_read(3)](io_uring_prep_read.3.md)
- [io_uring_buf_ring_init(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_buf_ring_init.3)
- [io_uring_buf_ring_add(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_buf_ring_add.3)
- [io_uring_submit(3)](io_uring_submit.3.md)
