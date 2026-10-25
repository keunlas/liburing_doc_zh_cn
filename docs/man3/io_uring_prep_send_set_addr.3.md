---
title: io_uring_prep_send_set_addr
section: 3
source_path: man/io_uring_prep_send_set_addr.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 1897a539ce31f59365e24db8194e908feca26cad87d1c3e677b446c16d20c173
source_copyright: "Copyright (C) 2023 Rutvik Patel <heyrutvik@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_send_set_addr(3)

## 名称

io_uring_prep_send_set_addr - 设置发送请求的地址详情

## 概要

```c
#include <liburing.h>

void io_uring_prep_send_set_addr(struct io_uring_sqe *sqe,
                                 const struct sockaddr *dest_addr,
                                 __u16 addr_len);
```

## 描述

[io_uring_prep_send_set_addr(3)](io_uring_prep_send_set_addr.3.md) 函数使用
`addr_len` 参数设置由 `dest_addr` 指定的套接字目标地址及其长度。在通过任意
[send(2)](https://man7.org/linux/man-pages/man2/send.2.html) io_uring 辅助函数准备好
`sqe` 后，可以使用此函数。请参见
[io_uring_prep_send(3)](io_uring_prep_send.3.md) 或
[io_uring_prep_send_zc(3)](io_uring_prep_send_zc.3.md) 的手册页。

## 返回值

无。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_prep_send(3)](io_uring_prep_send.3.md)
- [io_uring_prep_send_zc(3)](io_uring_prep_send_zc.3.md)
- [send(2)](https://man7.org/linux/man-pages/man2/send.2.html)
