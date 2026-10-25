---
title: io_uring_prep_socket
section: 3
source_path: man/io_uring_prep_socket.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 23df8a9ff83e553e090391febaaa60954b1818acea1b91ac349ba5bee13f3695
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_socket(3)

## 名称

io_uring_prep_socket - 准备一个套接字创建请求

## 概要

```c
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_socket(struct io_uring_sqe *sqe,
                          int domain,
                          int type,
                          int protocol,
                          unsigned int flags);

void io_uring_prep_socket_direct(struct io_uring_sqe *sqe,
                                 int domain,
                                 int type,
                                 int protocol,
                                 unsigned int file_index,
                                 unsigned int flags);

void io_uring_prep_socket_direct_alloc(struct io_uring_sqe *sqe,
                                 int domain,
                                 int type,
                                 int protocol,
                                 unsigned int flags);
```

## 描述

[io_uring_prep_socket(3)](io_uring_prep_socket.3.md) 函数准备一个套接字创建请求。
提交队列项 `sqe` 会被设置为使用 `domain` 定义的通信域、`type` 定义的通信类型以及
`protocol` 设置的协议。`flags` 参数目前未使用。

[io_uring_prep_socket_direct(3)](io_uring_prep_socket.3.md) 辅助函数的工作方式与
[io_uring_prep_socket(3)](io_uring_prep_socket.3.md) 相同，区别在于它将套接字映射到
直接描述符，而不是返回普通文件描述符。`file_index` 参数应设置为该套接字要使用的
槽位。

[io_uring_prep_socket_direct_alloc(3)](io_uring_prep_socket.3.md) 辅助函数的工作方式
与 [io_uring_prep_socket_direct(3)](io_uring_prep_socket.3.md) 相同，区别在于它会
分配一个新的直接描述符，而不是传入空闲槽位。这等效于使用
[io_uring_prep_socket_direct(3)](io_uring_prep_socket.3.md) 并将 `file_index` 设置
为 `IORING_FILE_INDEX_ALLOC`。完成时，CQE 的 `res` 字段将返回为套接字分配的直接
槽位。

如果使用直接变体，应用必须首先通过
[io_uring_register_files(3)](io_uring_register_files.3.md)
注册一个适当大小的文件表。注册后，直接套接字请求可以使用该表中的任意项，只要其处于
已注册表的范围内即可。如果指定项中已经包含文件，该文件首先会从表中移除并关闭。这与
使用
[io_uring_register_files_update(3)](io_uring_register_files.3.md)
更新已有文件的行为一致。

对于直接描述符套接字请求，可以将 `file_index` 参数设置为
`IORING_FILE_INDEX_ALLOC`。在这种情况下，将自动使用 io_uring 文件表中的一个空闲
项，并以 CQE 的 `res` 返回文件索引。否则，如果 io_uring 文件表中没有空闲项，将返回
`-ENFILE`。

这些函数准备一个异步
[socket(2)](https://man7.org/linux/man-pages/man2/socket.2.html) 请求。详情请参见
该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [socket(2)](https://man7.org/linux/man-pages/man2/socket.2.html)
