---
title: io_uring_prep_read
section: 3
source_path: man/io_uring_prep_read.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 5dc27179822be1e675c90b9902b8e1533d07fc29f7ba5b6e0b0ef773176194a5
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_read(3)

## 名称

io_uring_prep_read - 准备 I/O 读取请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_read(struct io_uring_sqe *sqe,
                        int fd,
                        void *buf,
                        unsigned nbytes,
                        __u64 offset);
```

## 描述

[io_uring_prep_read(3)](io_uring_prep_read.3.md) 准备一个 I/O 读取请求。提交队列项
`sqe` 会被设置为使用文件描述符 `fd`，从指定的 `offset` 开始将 `nbytes` 字节读入
缓冲区 `buf`。

对于支持寻址的文件，如果将偏移量设置为 `-1`，则读取操作从文件偏移量开始，并且文件
偏移量会增加实际读取的字节数。详情请参见
[read(2)](https://man7.org/linux/man-pages/man2/read.2.html)。请注意，对于异步
API，除非对文件的访问已串行化，否则读取并更新当前文件偏移量可能导致不可预测的
行为。如果应用或库能够提供所需的 I/O 偏移量，不鼓励使用此特性。

对于不能寻址的文件，偏移量必须为 0 或 -1。

读取请求准备好后，可以使用某个提交函数提交。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

此函数接受无符号的字节数，但 `io_uring_cqe` 的结果代码是 `__s32` 值，因此理论上，
如果 `nbytes` 足够大，短读可能产生有歧义的返回值。但是，实际传输的字节数具有与
[read(2)](https://man7.org/linux/man-pages/man2/read.2.html) 相同的限制，因此在
实践中不会发生这种情况。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_prep_readv(3)](io_uring_prep_readv.3.md)
- [io_uring_prep_readv2(3)](io_uring_prep_readv2.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
