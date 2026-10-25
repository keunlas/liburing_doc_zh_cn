---
title: io_uring_opcode_supported
section: 3
source_path: man/io_uring_opcode_supported.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: d4cf7738143c642e0828e41bd999765a1d93d51b60b46b951f7e4d02f0cec4b3
source_copyright: "Copyright (C) 2022 Stefan Roesch <shr@fb.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_opcode_supported(3)

## 名称

io_uring_opcode_supported - 操作码是否受支持？

## 概要

```c
#include <liburing.h>

int io_uring_opcode_supported(struct io_uring_probe *probe,
                              int opcode);
```

## 描述

[io_uring_opcode_supported(3)](io_uring_opcode_supported.3.md) 函数允许调用方确定
属于 `probe` 参数、传入的 `opcode` 是否受支持。可以调用
[io_uring_get_probe(3)](io_uring_get_probe.3.md) 函数获取一个 `io_uring_probe` 实例。

## 返回值

成功时返回 1，否则返回 0。

## 参见

- [io_uring_get_probe(3)](io_uring_get_probe.3.md)
