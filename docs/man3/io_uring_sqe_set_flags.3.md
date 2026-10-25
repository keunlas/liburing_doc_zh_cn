---
title: io_uring_sqe_set_flags
section: 3
source_path: man/io_uring_sqe_set_flags.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 49febe08b2c06735773e3f1284419e524378b896704b131fd2406d34fe5f0572
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_sqe_set_flags(3)

## 名称

io_uring_sqe_set_flags - 设置提交队列项的标志

## 概要

```c
#include <liburing.h>

void io_uring_sqe_set_flags(struct io_uring_sqe *sqe,
                            unsigned flags);
```

## 描述

[io_uring_sqe_set_flags(3)](io_uring_sqe_set_flags.3.md) 函数允许调用方通过指定标志来
改变提交队列项的行为。它设置属于 `sqe` 提交队列项参数的 `flags`。

`flags` 是由下列 0 个或多个值按位或组合而成的位掩码：

- `IOSQE_FIXED_FILE`：SQE 中的文件描述符指代先前注册的文件或直接文件描述符的
  索引，而不是普通的文件描述符。

- `IOSQE_ASYNC`：io_uring 的正常操作是首先尝试以非阻塞方式发出 SQE，如果失败，
  再以异步方式执行它。为了对应用已知或假定会始终（或大多数时候）阻塞的请求提供
  更高效的重叠操作，应用可以要求从一开始就以异步方式发出 SQE。请注意，此标志会
  立即将 SQE 卸载到异步辅助线程，不再进行初始的非阻塞尝试。这可能降低效率，不应
  随意使用，也不应在未理解性能与效率权衡时使用。

- `IOSQE_IO_LINK`：指定此标志时，该 SQE 与提交环中的下一个 SQE 形成链接。在上一
  个请求完成之前，不会启动下一个 SQE。这实际上形成一条 SQE 链，链的长度可以任意。
  链尾由第一个未设置此标志的 SQE 表示。不支持跨提交边界链接。即使一次提交中的
  最后一个 SQE 设置了此标志，它仍然会终止当前链。此标志不会影响先前的 SQE 提交，
  也不会影响位于链尾之外的 SQE。这意味着多条链可以并行执行，链和单个 SQE 也可以
  并行执行；只有链内的成员会被串行化。如果链中任一请求以错误结束，整条 SQE 链都会
  断开。

- `IOSQE_IO_HARDLINK`：与 `IOSQE_IO_LINK` 类似，区别在于即使发生错误或意外结果，
  链接也不会断开。

- `IOSQE_IO_DRAIN`：指定此标志时，在先前提交的 SQE 完成之前，不会启动该 SQE；在
  该 SQE 完成之前，也不会启动新的 SQE。

- `IOSQE_CQE_SKIP_SUCCESS`：请求在此请求成功完成时不生成 CQE。当应用不需要知道某个
  特定请求是否成功完成时，此标志可能很有用。

- `IOSQE_BUFFER_SELECT`：如果设置此标志，并且请求类型支持该操作，则从指定的缓冲区
  组中选择一个 I/O 缓冲区。此标志可用于从文件或套接字读取或接收数据的请求；此时
  缓冲区选择会推迟到内核准备好传输数据时，而不是在最初提交 I/O 时进行。应用还必须
  设置 SQE 中的 `buf_group` 字段，以指明从哪个先前注册的缓冲区组中选择缓冲区。

## 返回值

无。

## 参见

- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
- [io_uring_register_buf_ring(3)](io_uring_register_buf_ring.3.md)
