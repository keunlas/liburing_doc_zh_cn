---
title: io_uring_prep_openat2
section: 3
source_path: man/io_uring_prep_openat2.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 0cb8dfa19906c464f84e616da6b02a41ee8d78aefed4fadd207dfa5bbd11ac7f
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_openat2(3)

## 名称

io_uring_prep_openat2 - 准备一个 openat2 请求

## 概要

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <linux/openat2.h>
#include <liburing.h>

void io_uring_prep_openat2(struct io_uring_sqe *sqe,
                           int dfd,
                           const char *path,
                           const struct open_how *how);

void io_uring_prep_openat2_direct(struct io_uring_sqe *sqe,
                                  int dfd,
                                  const char *path,
                                  const struct open_how *how,
                                  unsigned file_index);
```

## 描述

[io_uring_prep_openat2(3)](io_uring_prep_openat2.3.md) 函数准备一个 openat2 请求。
提交队列项 `sqe` 会被设置为使用目录文件描述符 `dfd`，开始打开由 `path` 描述的文件，
并采用 `how` 中给出的文件打开说明。

如果使用直接变体，应用必须首先通过
[io_uring_register_files(3)](io_uring_register_files.3.md)
注册一个适当大小的文件表。注册后，直接请求可以使用该表中的任意项，并在 `file_index`
中指定该项，只要其处于已注册表的范围内即可。如果指定项中已经包含文件，该文件首先会
从表中移除并关闭。这与使用
[io_uring_register_files_update(3)](io_uring_register_files.3.md)
更新已有文件的行为一致。

如果将 `IORING_FILE_INDEX_ALLOC` 用作直接打开请求的 `file_index`，则 io_uring 将在
现有表中分配一个空闲的直接描述符。所分配的描述符会像非直接打开请求那样在 CQE 的
`res` 字段中返回。如果直接描述符表中没有更多可用项，则返回 `-ENFILE`。

直接描述符是 io_uring 私有的文件描述符。它们避免了与线程共享文件表相关的一些开销，
并可用于任何后续接受文件描述符的 io_uring 请求。为此，必须在 SQE 的 `flags` 成员中
设置 `IOSQE_FIXED_FILE`，并且 SQE 的 `fd` 字段应使用直接描述符值，而不是普通文件
描述符。直接描述符的管理方式与已注册文件类似。

目录文件描述符 `dfd` 始终是普通文件描述符。

请注意，旧内核不会检查 SQE 的 `file_index` 字段。这对 liburing 辅助函数不成问题，
但使用原始 io_uring 接口的用户需要将 SQE 清零，以避免意外行为。

这些函数准备一个异步
[openat2(2)](https://man7.org/linux/man-pages/man2/openat2.2.html) 请求。详情请
参见该手册页。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果。可能值的详情请参见相关手册页。请注意，同步系统调用
失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用 `errno`，而是
直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 注意事项

与任何通过结构体传入数据的请求一样，该数据必须在请求成功提交之前保持有效。无需保持
有效到完成。请求提交后，内核内状态就是稳定的。非常早期的内核（5.4 及更早版本）
要求状态保持稳定，直到完成发生。应用可以通过检查
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 返回的
`IORING_FEAT_SUBMIT_STABLE` 标志来测试这一行为。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [openat2(2)](https://man7.org/linux/man-pages/man2/openat2.2.html)
