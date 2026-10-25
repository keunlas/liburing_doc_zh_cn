---
title: io_uring_prep_sendmsg
section: 3
source_path: man/io_uring_prep_sendmsg.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: f166492a9077bda17ebd811cd9254f5a1f88e7cc08d2bee60b9bbecc4a523e92
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_sendmsg(3)

## 名称

io_uring_prep_sendmsg - 准备一个 sendmsg 请求

## 概要

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_sendmsg(struct io_uring_sqe *sqe,
                           int fd,
                           const struct msghdr *msg,
                           unsigned flags);

void io_uring_prep_sendmsg_zc(struct io_uring_sqe *sqe,
                              int fd,
                              const struct msghdr *msg,
                              unsigned flags);
```

## 描述

[io_uring_prep_sendmsg(3)](io_uring_prep_sendmsg.3.md) 函数准备一个 sendmsg 请求。
提交队列项 `sqe` 会被设置为使用文件描述符 `fd`，开始发送由 `msg` 指示的数据，并在
`flags` 参数中使用
[sendmsg(2)](https://man7.org/linux/man-pages/man2/sendmsg.2.html) 定义的标志。

[io_uring_prep_sendmsg_zc(3)](io_uring_prep_sendmsg.3.md) 接受与
[io_uring_prep_sendmsg(3)](io_uring_prep_sendmsg.3.md) 相同的参数，但准备的是一个
零拷贝 sendmsg 请求。

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

此函数准备一个异步
[sendmsg(2)](https://man7.org/linux/man-pages/man2/sendmsg.2.html) 请求。详情请
参见该手册页。

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

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

尽管这些函数接受一个 iovec 数组，其中每个 iovec 的字节数为 `size_t`，但每次调用
最多只能传输 `INT_MAX` 字节（底层系统调用接口的最大值）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_buf_ring_init(3)](io_uring_buf_ring_init.3.md)
- [io_uring_buf_ring_add(3)](io_uring_buf_ring_add.3.md)
- [sendmsg(2)](https://man7.org/linux/man-pages/man2/sendmsg.2.html)
