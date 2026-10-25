---
title: io_uring_recvmsg_out
section: 3
source_path: man/io_uring_recvmsg_out.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 822ee32d85969790b0c7130bedc1f08de783ef545a4f99e8eb7d9711513f2034
source_copyright: "Copyright (C), 2022 Dylan Yudaken <dylany@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_recvmsg_out(3)

## 名称

io_uring_recvmsg_out - 访问多轮触发 recvmsg 的数据

## 概要

```c
#include <liburing.h>

struct io_uring_recvmsg_out *io_uring_recvmsg_validate(void *buf,
                                                       int buf_len,
                                                       struct msghdr *msgh);

void *io_uring_recvmsg_name(struct io_uring_recvmsg_out *o);

struct cmsghdr *io_uring_recvmsg_cmsg_firsthdr(struct io_uring_recvmsg_out *o,
                                               struct msghdr *msgh);
struct cmsghdr *io_uring_recvmsg_cmsg_nexthdr(struct io_uring_recvmsg_out *o,
                                              struct msghdr *msgh,
                                              struct cmsghdr *cmsg);

void *io_uring_recvmsg_payload(struct io_uring_recvmsg_out *o,
                               struct msghdr *msgh);
unsigned int io_uring_recvmsg_payload_length(struct io_uring_recvmsg_out *o,
                                             int buf_len,
                                             struct msghdr *msgh);
```

## 描述

这些函数用于访问
[io_uring_prep_recvmsg_multishot(3)](io_uring_prep_recvmsg.3.md) 所交付负载中的数据。

`msgh` 应指向随请求提交的 `struct msghdr`。

[io_uring_recvmsg_validate(3)](io_uring_recvmsg_out.3.md) 将验证由
[io_uring_prep_recvmsg_multishot(3)](io_uring_prep_recvmsg.3.md) 交付的缓冲区；如果
有效，则提取其中的 `io_uring_recvmsg_out`，并返回指向该结构体的指针，否则返回
`NULL`。

该结构体定义如下：

```c
struct io_uring_recvmsg_out {
        __u32 namelen;    /* 名称字节数，与 recvmsg(2) 原本会填充的值相同 */
        __u32 controllen; /* 控制字节数 */
        __u32 payloadlen; /* 负载字节数，与 recvmsg(2) 原本会返回的值相同 */
        __u32 flags;      /* 标志结果，与 recvmsg(2) 原本会填充的值相同 */
};
```

- [io_uring_recvmsg_name(3)](io_uring_recvmsg_out.3.md) 返回指向缓冲区中名称的指针。
- [io_uring_recvmsg_cmsg_firsthdr(3)](io_uring_recvmsg_out.3.md) 返回指向缓冲区中
  第一个 cmsg 的指针，或者返回 `NULL`。
- [io_uring_recvmsg_cmsg_nexthdr(3)](io_uring_recvmsg_out.3.md) 返回指向缓冲区中
  下一个 cmsg 的指针，或者返回 `NULL`。
- [io_uring_recvmsg_payload(3)](io_uring_recvmsg_out.3.md) 返回指向缓冲区中负载的
  指针。
- [io_uring_recvmsg_payload_length(3)](io_uring_recvmsg_out.3.md) 计算可用负载长度
  （以字节为单位）。

## 参见

- [io_uring_prep_recvmsg_multishot(3)](io_uring_prep_recvmsg.3.md)
