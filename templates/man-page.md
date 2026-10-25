---
title: io_uring_example
section: 3
source_path: man/io_uring_example.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: REPLACE_WITH_SOURCE_SHA256
source_copyright: "REPLACE_WITH_UPSTREAM_COPYRIGHT_LINES"
translation_status: draft
translated_at: YYYY-MM-DD
license: LGPL-2.0-or-later
---

# io_uring_example(3)

## 名称

io_uring_example - 用一句话说明该 API 的用途

## 概要

```c
#include <liburing.h>

int io_uring_example(struct io_uring *ring);
```

## 描述

在此完整翻译上游 `DESCRIPTION`。

## 返回值

在此翻译成功和失败时的返回值；保留 `errno` 名称。

## 错误

按上游 `ERRORS` 列出错误条件，不合并不同的错误含义。

## 版本

保留上游的版本信息和内核版本限制。

## 注意事项

保留并发、生命周期、权限和性能方面的限制。

## 示例

优先原样保留代码；翻译依赖上下文的注释。

```c
/* 示例代码 */
```

## 参见

- [io_uring_queue_init(3)](io_uring_queue_init.3.md)

<!--
提交前删除本注释，并完成以下操作：
1. 替换所有占位字段。
2. 删除上游不存在的章节。
3. 对照锁定版本逐节复核。
4. 运行 make check。
-->
