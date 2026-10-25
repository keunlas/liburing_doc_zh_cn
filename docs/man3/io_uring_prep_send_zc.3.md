---
title: io_uring_prep_send_zc
section: 3
source_path: man/io_uring_prep_send_zc.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 16bf3c7df7641e7eebc8c180378a904ecdda6ed8ff820f0d8dd6e747af3188dd
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_send_zc(3)

## 名称

io_uring_prep_send_zc - 准备一个零拷贝发送请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_send_zc(struct io_uring_sqe *sqe,
                           int sockfd,
                           const void *buf,
                           size_t len,
                           int flags,
                           unsigned zc_flags);

void io_uring_prep_send_zc_fixed(struct io_uring_sqe *sqe,
                                 int sockfd,
                                 const void *buf,
                                 size_t len,
                                 int flags,
                                 unsigned zc_flags,
                                 unsigned buf_index);
```

## 描述

[io_uring_prep_send_zc(3)](io_uring_prep_send_zc.3.md) 函数准备一个零拷贝发送请求。
提交队列项 `sqe` 会被设置为使用文件描述符 `sockfd`，开始发送缓冲区 `buf` 中大小为
`len` 字节的数据，并使用发送修饰标志 `flags` 和零拷贝修饰标志 `zc_flags`。

[io_uring_prep_send_zc_fixed(3)](io_uring_prep_send_zc.3.md) 的工作方式与
[io_uring_prep_send_zc(3)](io_uring_prep_send_zc.3.md) 相同，只是要求使用已通过
[io_uring_register_buffers(3)](io_uring_register_buffers.3.md)
注册的缓冲区。`buf` 和 `len` 参数必须位于先前注册的缓冲区中由 `buf_index` 指定的
区域内。缓冲区无需与已注册缓冲区的起始位置对齐。

有关可以在 SQE 的 `ioprio` 字段中设置的标志，请参见
[io_uring_prep_send(3)](io_uring_prep_send.3.md)。除这些标志外，零拷贝发送还支持
设置 `IORING_SEND_ZC_REPORT_USAGE`。如果设置该标志，通知 CQE 的 `res` 字段将报告
通过复制而不是零拷贝发送的字节数。值为 `0` 表示成功。如果值为
`IORING_NOTIF_USAGE_ZC_COPIED`，则表示数据是通过复制处理的。

与非零拷贝发送请求不同，零拷贝发送通常会生成两个 CQE。第一个 CQE 包含发送操作本身
的结果；如果该 CQE 的 `flags` 字段中设置了 `IORING_CQE_F_MORE`，则还会为该操作
发布第二个通知 CQE。第二个通知会告知应用，与此次发送关联的内存可以安全复用。第二个
CQE 的 `flags` 字段中将设置 `IORING_CQE_F_NOTIF`。有关通知 CQE 的更完整说明，另请
参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
手册页。

请注意，对此请求类型使用 `IOSQE_IO_LINK` 时，需要在 `flags` 参数中设置
`MSG_WAITALL`，因为在未设置该项的情况下，短发送不会被视为错误情况。

这些函数准备一个异步零拷贝
[send(2)](https://man7.org/linux/man-pages/man2/send.2.html) 请求。详情请参见该
手册页。有关零拷贝性质的详情，请参见
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。一些常见错误情况如下：

- `-ENOMEM`：
  [ulimit(1)](https://man7.org/linux/man-pages/man1/ulimit.1p.html) 的 `-l` 设置过低，
  无法支持所尝试零拷贝发送的大小。提高该限制可能有帮助。
- `-ENOMEM`：内核内存耗尽。

## 注意事项

尽管这些函数接受以字节数表示的 `size_t` 参数，但每次调用最多只能传输 `INT_MAX`
字节（底层系统调用接口的最大值）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_prep_send(3)](io_uring_prep_send.3.md)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
- [send(2)](https://man7.org/linux/man-pages/man2/send.2.html)
