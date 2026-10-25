---
title: io_uring_prep_setxattr
section: 3
source_path: man/io_uring_prep_setxattr.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 13079a9598011191773832b559fe25684f092c21b63e621f8350e8cbe62aa974
source_copyright: "Copyright (C) 2023 Rutvik Patel <heyrutvik@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_setxattr(3)

## 名称

io_uring_prep_setxattr、io_uring_prep_fsetxattr - 准备设置扩展属性值的请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_setxattr(struct io_uring_sqe *sqe,
                            const char *name,
                            const char *value,
                            const char *path,
                            int flags,
                            unsigned int len);

void io_uring_prep_fsetxattr(struct io_uring_sqe *sqe,
                             int fd,
                             const char *name,
                             const char *value,
                             int flags,
                             unsigned int len);
```

## 描述

[io_uring_prep_setxattr(3)](io_uring_prep_setxattr.3.md) 函数准备一个设置扩展属性值
的请求。提交队列项 `sqe` 会被设置为使用修饰标志 `flags`，设置由 `name` 标识、与
文件系统中给定 `path` 关联的扩展属性值 `value`。`len` 参数指定 `value` 的大小
（以字节为单位）。

[io_uring_prep_fsetxattr(3)](io_uring_prep_setxattr.3.md) 与
[io_uring_prep_setxattr(3)](io_uring_prep_setxattr.3.md) 相同，区别在于扩展属性设置
在 `fd` 所引用的已打开文件上，而不是 `path` 上。

此函数准备一个异步
[setxattr(2)](https://man7.org/linux/man-pages/man2/setxattr.2.html) 请求。详情请
参见该手册页。

## 返回值

无。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [setxattr(2)](https://man7.org/linux/man-pages/man2/setxattr.2.html)
