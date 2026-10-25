---
title: io_uring_prep_cmd_getsockname
section: 3
source_path: man/io_uring_prep_cmd_getsockname.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: eed532bd954b58c95e8b4e0ab045a8c566871ecd09a0a1c9b026c52f5196e2ec
source_copyright: "Copyright (C) 2025 SUSE LLC.; Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_cmd_getsockname(3)

## 名称

io_uring_prep_cmd_getsockname - 准备一个 getsockname 或 getpeername 请求

## 概要

```c
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_cmd_getsockname(struct io_uring_sqe *sqe,
                                   int fd,
                                   struct sockaddr *sockaddr,
                                   socklen_t *sockaddr_len,
                                   int peer);
```

## 描述

[io_uring_prep_cmd_getsockname(3)](io_uring_prep_cmd_getsockname.3.md) 函数准备一个
getsockname/getpeername 请求。提交队列项 `sqe` 会被设置为获取套接字文件描述符
`sockfd` 所指向的本地绑定地址或对端地址。参数 `sockaddr` 指向大小为 `sockaddr_len`
的区域，输出会写入其中。返回时，内核会修改 `sockaddr_len`，以表示写入了多少字节。
如果 `peer` 设置为 `0`，输出地址是本地绑定地址；如果 `peer` 设置为 `1`，输出地址
是对端地址。

此函数准备一个异步
[getsockname(2)](https://man7.org/linux/man-pages/man2/getsockname.2.html) 或
[getpeername(2)](https://man7.org/linux/man-pages/man2/getpeername.2.html) 请求。
详情请参见这些手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

与等价系统调用不同，如果用户尝试在非套接字文件描述符上使用此操作，CQE 错误结果是
`ENOTSUP`，而不是 `ENOSOCK`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [getsockname(2)](https://man7.org/linux/man-pages/man2/getsockname.2.html)
- [getpeername(2)](https://man7.org/linux/man-pages/man2/getpeername.2.html)
