---
title: io_uring_prep_accept
section: 3
source_path: man/io_uring_prep_accept.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: d8c7cbe813faf526ba8d83f2cbbc9b2ea577bed87efb4388a27e8e705bc01c13
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_accept(3)

## 名称

io_uring_prep_accept - 准备一个 accept 请求

## 概要

```c
#include <sys/socket.h>
#include <liburing.h>

void io_uring_prep_accept(struct io_uring_sqe *sqe,
                          int sockfd,
                          struct sockaddr *addr,
                          socklen_t *addrlen,
                          int flags);

void io_uring_prep_accept_direct(struct io_uring_sqe *sqe,
                                 int sockfd,
                                 struct sockaddr *addr,
                                 socklen_t *addrlen,
                                 int flags,
                                 unsigned int file_index);

void io_uring_prep_multishot_accept(struct io_uring_sqe *sqe,
                                    int sockfd,
                                    struct sockaddr *addr,
                                    socklen_t *addrlen,
                                    int flags);

void io_uring_prep_multishot_accept_direct(struct io_uring_sqe *sqe,
                                           int sockfd,
                                           struct sockaddr *addr,
                                           socklen_t *addrlen,
                                           int flags);
```

## 描述

[io_uring_prep_accept(3)](io_uring_prep_accept.3.md) 函数及其三个变体准备一个
类似于
[accept4(2)](https://man7.org/linux/man-pages/man2/accept4.2.html) 的 accept 请求。
提交队列项 `sqe` 会被设置为使用文件描述符 `sockfd`，开始接受由 `addr` 处的套接字
地址描述、结构体长度为 `addrlen` 且使用 `flags` 中修饰标志的连接请求。

这三个变体允许组合直接文件表和多轮触发特性。

直接描述符是 io_uring 私有的文件描述符。它们避免了与线程共享文件表相关的一些开销，
并可用于任何接受文件描述符的 io_uring 请求。这里的两个直接变体创建这样的直接
描述符。创建后，可以通过在 SQE 的 `flags` 成员中设置 `IOSQE_FIXED_FILE`，并将 SQE
的 `fd` 字段设置为直接描述符值而不是普通文件描述符来使用它们。直接描述符的管理
方式与已注册文件类似。

要使用 accept 直接变体，应用必须首先通过
[io_uring_register_files(3)](io_uring_register_files.3.md)
或
[io_uring_register_files_sparse(3)](io_uring_register_files.3.md)
注册一个所需大小的文件表。注册后，
[io_uring_prep_accept_direct(3)](io_uring_prep_accept.3.md) 允许通过 `file_index`
参数专门选择该表中的一个项。如果指定项中已经包含文件，该文件首先会从表中移除并关闭，
这与使用
[io_uring_register_files_update(3)](io_uring_register_files.3.md)
更新已有文件的行为一致。对于此变体，也可以将 `file_index` 设置为
`IORING_FILE_INDEX_ALLOC`，此时会动态选择一个未使用的表索引并返回。类似地，
`io_uring_prep_multishot_accept_direct` 会为接受的每个连接动态选择一个未使用的表索引
并返回。如果要同时采用特定选择和动态选择两种直接选择形式，请参见
[io_uring_register_file_alloc_range(3)](io_uring_register_file_alloc_range.3.md)
以设置该表，使动态选择的项与特定请求所针对的范围不同。

请注意，旧内核不会检查 SQE 的 `file_index` 字段；这意味着当内核过旧时，应用不能
依赖返回 `-EINVAL` 的 CQE `res`，因为较旧的内核可能无法识别自己正被要求使用直接表
槽位。

当直接描述符 accept 请求要求动态选择表槽位，但没有空闲项时，CQE 的 `res` 会返回
`-ENFILE`。

多轮触发变体允许应用发出一个 accept 请求，并在连接请求到来时反复触发 CQE。与其他
多轮触发类型的请求一样，应用应检查 CQE 的 `flags`，看完成事件中是否设置了
`IORING_CQE_F_MORE`，以判断该 accept 请求是否还会产生更多 CQE。请注意，对于多轮
触发变体，设置 `addr` 和 `addrlen` 可能没有太大意义，因为每个被接受的连接都会使用
相同的值。这意味着，在应用有时间处理完一个先前的连接之前，写入 `addr` 的数据可能
会被新连接覆盖。如果应用确知先前连接处理完之前不会到来新连接，则可以按预期使用该
功能。多轮触发变体自 5.19 起可用。

有关 accept 函数本身的详情，请参见
[accept4(2)](https://man7.org/linux/man-pages/man2/accept4.2.html) 手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。

[io_uring_prep_accept(3)](io_uring_prep_accept.3.md) 会生成已安装的文件描述符作为
结果。

使用 [io_uring_prep_accept_direct(3)](io_uring_prep_accept.3.md) 且 `file_index`
设置为特定直接描述符时，成功会生成 `0`。调用方必须记住为此次请求选择了哪个直接
描述符。

使用 [io_uring_prep_accept_direct(3)](io_uring_prep_accept.3.md) 且 `file_index`
设置为 `IORING_FILE_INDEX_ALLOC` 时，会生成动态选择的直接描述符。

[io_uring_prep_multishot_accept(3)](io_uring_prep_accept.3.md) 会在每个结果中生成
已安装的文件描述符。

[io_uring_prep_multishot_accept_direct(3)](io_uring_prep_accept.3.md) 会在每个结果中
生成动态选择的直接描述符。

请注意，同步系统调用失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring
从不使用 `errno`，而是直接在 CQE 的 `res` 字段中生成取负后的 `errno`。

## 注意事项

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

请注意，accept 的直接版本不接受 `SOCK_CLOEXEC`；设置该标志会导致 CQE 中出现
`-EINVAL` 错误。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register_files(3)](io_uring_register_files.3.md)
- [io_uring_register_files_sparse(3)](io_uring_register_files.3.md)
- [io_uring_register_file_alloc_range(3)](io_uring_register_file_alloc_range.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [accept4(2)](https://man7.org/linux/man-pages/man2/accept4.2.html)
