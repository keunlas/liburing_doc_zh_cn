---
title: io_uring_prep_cmd_sock
section: 3
source_path: man/io_uring_prep_cmd_sock.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 52c85006063e3f179ae28fbc7d772f8e71c2b7f1f74ea01514bd23938c5c2e01
source_copyright: "Copyright (C) 2023 Breno Leitao <leitao@debian.org>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_cmd_sock(3)

## 名称

io_uring_prep_cmd_sock - 准备一个套接字命令请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_cmd_sock(struct io_uring_sqe *sqe,
                            int cmd_op,
                            int fd,
                            int level,
                            int optname,
                            void *optval,
                            int optlen);
```

## 描述

[io_uring_prep_cmd_sock(3)](io_uring_prep_cmd_sock.3.md) 函数准备一个套接字命令请求。
提交队列项 `sqe` 会被设置为使用 `fd` 所指向的套接字文件描述符，启动由 `cmd_op`
定义的命令操作。

这是一个通用函数，每条命令都有自己的 `level`、`optname`、`optval` 值。`optlen`
定义 `optval` 所指向数据的大小。

### 可用命令

- `SOCKET_URING_OP_SIOCINQ`：返回接收缓冲区中已排队但未读取的数据量。套接字不得处于
  LISTEN 状态，否则 CQE 的 `res` 字段中会返回 `-EINVAL` 错误。此命令不使用
  `level`、`optname`、`optval` 和 `optlen`。负返回值表示错误。详情请参见
  [unix(7)](https://man7.org/linux/man-pages/man7/unix.7.html)。自 6.7 起可用。
- `SOCKET_URING_OP_SIOCOUTQ`：返回套接字发送队列中尚未发送的数据量。套接字不得处于
  LISTEN 状态，否则 CQE 的 `res` 字段中会返回 `-EINVAL` 错误。此命令不使用
  `level`、`optname`、`optval` 和 `optlen`。负返回值表示错误。详情请参见
  [unix(7)](https://man7.org/linux/man-pages/man7/unix.7.html)。
- `SOCKET_URING_OP_GETSOCKOPT`：获取 `fd` 所引用套接字的选项。参数类似于
  [getsockopt(2)](https://man7.org/linux/man-pages/man2/getsockopt.2.html)。此命令
  仅限 `SOL_SOCKET` 级别的选项。与 `getsockopt` 系统调用不同，成功时更新后的
  `optlen` 值会在 CQE 的 `res` 字段中返回；失败时 `res` 包含负错误号。
- `SOCKET_URING_OP_SETSOCKOPT`：设置 `fd` 所引用套接字的选项。参数类似于
  [setsockopt(2)](https://man7.org/linux/man-pages/man2/setsockopt.2.html)。自 6.7
  起可用。
- `SOCKET_URING_OP_TX_TIMESTAMP`：从套接字错误队列获取发送时间戳。它为获取 TX
  时间戳提供了传统 `recvmsg` 错误队列接口的替代方案。该命令以轮询多轮触发模式运行，
  直到请求被取消或失败。环必须使用 `IORING_SETUP_CQE32` 或
  `IORING_SETUP_CQE_MIXED` 创建，以提供时间戳数据空间。每个时间戳 CQE 的
  `cqe->flags` 中会设置 `IORING_CQE_F_MORE`，`cqe->res` 包含时间戳键 `tskey`，
  时间戳类型保存在 `cqe->flags` 高位的 `IORING_TIMESTAMP_TYPE_SHIFT` 偏移处，实际
  时间戳值存储在 `(cqe + 1)` 的扩展 CQE 区域。最后一个 CQE 不设置
  `IORING_CQE_F_MORE`，其 `res` 成功时为 0。自 6.17 起可用。
- `SOCKET_URING_OP_GETSOCKNAME`：返回套接字当前绑定的地址。结果存储在 `optval`
  指向的缓冲区中，该缓冲区应指向 `struct sockaddr` 或适当变体；`optlen` 指定其大小。
  成功时 CQE 的 `res` 包含套接字地址的实际大小；如果缓冲区太小，结果会被截断。这是
  [getsockname(2)](https://man7.org/linux/man-pages/man2/getsockname.2.html) 的
  io_uring 等价物。自 6.19 起可用。

## 注意事项

`optval` 指向的内存块必须在 CQE 返回之前保持有效。

## 返回值

取决于具体命令。

## 错误

CQE 的 `res` 字段会包含操作结果。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [unix(7)](https://man7.org/linux/man-pages/man7/unix.7.html)
