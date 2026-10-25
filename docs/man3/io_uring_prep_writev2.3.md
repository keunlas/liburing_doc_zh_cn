---
title: io_uring_prep_writev2
section: 3
source_path: man/io_uring_prep_writev2.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 60dbb01c455369464a4488abbbdbc2ce7c5a11752937c969eaeee83b9a010a88
source_copyright: "Copyright (C) 2021 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_writev2(3)

## 名称

io_uring_prep_writev2 - 准备带标志的向量 I/O 写入请求

## 概要

```c
#include <sys/uio.h>
#include <liburing.h>

void io_uring_prep_writev2(struct io_uring_sqe *sqe,
                           int fd,
                           const struct iovec *iovecs,
                           unsigned nr_vecs,
                           __u64 offset,
                           int flags);
```

## 描述

[io_uring_prep_writev2(3)](io_uring_prep_writev2.3.md) 准备一个向量 I/O 写入请求。
提交队列项 `sqe` 会被设置为使用文件描述符 `fd`，从指定的 `offset` 开始写入 `iovecs`
数组中的 `nr_vecs` 个向量。函数的行为可以通过 `flags` 参数控制。

`flags` 支持的值为：

- `RWF_HIPRI`：高优先级请求，如可能则轮询。
- `RWF_DSYNC`：按 I/O 生效的 `O_DSYNC`。
- `RWF_SYNC`：按 I/O 生效的 `O_SYNC`。
- `RWF_NOWAIT`：按 I/O 生效；如果操作会阻塞，则返回 `-EAGAIN`。
- `RWF_APPEND`：按 I/O 生效的 `O_APPEND`。

对于支持寻址的文件，如果将偏移量设置为 `-1`，则写入操作从文件偏移量开始，并且文件
偏移量会增加实际写入的字节数。详情请参见
[write(2)](https://man7.org/linux/man-pages/man2/write.2.html)。请注意，对于异步
API，除非对文件的访问已串行化，否则读取并更新当前文件偏移量可能导致不可预测的
行为。如果应用或库能够提供所需的 I/O 偏移量，不鼓励使用此特性。

对于不能寻址的文件，偏移量必须为 0 或 -1。

写入请求准备好后，可以使用某个提交函数提交。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

除非应用明确需要传入多个 iovec，否则使用
[io_uring_prep_write(3)](io_uring_prep_write.3.md) 比使用此函数更高效，因为非向量
I/O 请求无需维护状态。与任何通过结构体传入数据的请求一样，该数据必须在请求成功
提交之前保持有效。无需保持有效到完成。请求提交后，内核内状态就是稳定的。非常早期
的内核（5.4 及更早版本）要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

尽管此函数接受一个 iovec 数组，其中每个 iovec 的字节数为 `size_t`，但每次调用最多
只能传输 `INT_MAX` 字节（底层系统调用接口的最大值）。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_prep_write(3)](io_uring_prep_write.3.md)
- [io_uring_prep_writev(3)](io_uring_prep_writev.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
