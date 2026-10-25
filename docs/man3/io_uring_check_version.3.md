---
title: io_uring_check_version
section: 3
source_path: man/io_uring_check_version.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 9695dd0d7bd6ba2a5ab4b0f58e06866dbf3f11ce352f300ab5a305fa09811804
source_copyright: "Copyright (C) 2022 Christian Hergert <chergert@redhat.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_check_version(3)

## 名称

io_uring_check_version - 检查 liburing 版本的函数和宏

## 概要

```c
#include <liburing.h>

bool io_uring_check_version(int major, int minor);
IO_URING_CHECK_VERSION(major, minor);

int io_uring_major_version(void);
IO_URING_VERSION_MAJOR;

int io_uring_minor_version(void);
IO_URING_VERSION_MINOR;
```

## 描述

如果动态链接器加载的 liburing 库版本大于或等于所提供的 `major` 和 `minor` 编号，
`io_uring_check_version(3)` 函数返回 `false`。

如果编译时所用的 liburing 库版本大于或等于所提供的 `major` 和 `minor` 编号，
`IO_URING_CHECK_VERSION(3)` 宏返回 `0`。

`io_uring_major_version(3)` 函数返回动态链接器加载的 liburing 库的主版本号。

`IO_URING_VERSION_MAJOR(3)` 宏返回编译时所用的 liburing 库的主版本号。

`io_uring_minor_version(3)` 函数返回动态链接器加载的 liburing 库的次版本号。

`IO_URING_VERSION_MINOR(3)` 宏返回编译时所用的 liburing 库的次版本号。
