---
title: io_uring_prep_getxattr
section: 3
source_path: man/io_uring_prep_getxattr.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: f3c79c9947be00e3c511feddfa905eecde3cfa6b031e3a90f1380b06cab7d138
source_copyright: "Copyright (C) 2023 Rutvik Patel <heyrutvik@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_getxattr(3)

## 名称

io_uring_prep_getxattr、io_uring_prep_fgetxattr - 准备获取扩展属性值的请求

## 概要

```c
#include <liburing.h>

void io_uring_prep_getxattr(struct io_uring_sqe *sqe,
                            const char *name,
                            char *value,
                            const char *path,
                            unsigned int len);

void io_uring_prep_fgetxattr(struct io_uring_sqe *sqe,
                             int fd,
                             const char *name,
                             char *value,
                             unsigned int len);
```

## 描述

[io_uring_prep_getxattr(3)](io_uring_prep_getxattr.3.md) 函数准备一个获取扩展属性值
的请求。提交队列项 `sqe` 会被设置为获取由 `name` 标识、与文件系统中给定 `path`
关联的扩展属性值 `value`。`len` 参数指定 `value` 的大小（以字节为单位）。

[io_uring_prep_fgetxattr(3)](io_uring_prep_getxattr.3.md) 与
[io_uring_prep_getxattr(3)](io_uring_prep_getxattr.3.md) 相同，区别在于查询的是 `fd`
所引用的已打开文件，而不是 `path`。

此函数准备一个异步
[getxattr(2)](https://man7.org/linux/man-pages/man2/getxattr.2.html) 请求。详情请
参见该手册页。

## 返回值

无。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [getxattr(2)](https://man7.org/linux/man-pages/man2/getxattr.2.html)
