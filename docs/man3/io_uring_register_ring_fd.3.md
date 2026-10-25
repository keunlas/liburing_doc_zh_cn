---
title: io_uring_register_ring_fd
section: 3
source_path: man/io_uring_register_ring_fd.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 90b6e29830a0794262d2786fff20118b0233f2ace4e065d88ae5d3540a8b586d
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_ring_fd(3)

## 名称

io_uring_register_ring_fd - 注册一个环文件描述符

## 概要

```c
#include <liburing.h>

int io_uring_register_ring_fd(struct io_uring *ring);
```

## 描述

[io_uring_register_ring_fd(3)](io_uring_register_ring_fd.3.md) 注册该环的文件
描述符。

每当调用
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
提交请求或等待完成事件时，内核都必须获取该文件描述符的一个引用。如果使用 io_uring
的应用是多线程的，则文件表会被标记为共享，此时获取和释放文件描述符计数的引用，比
非多线程应用中的开销更大。

与 io_uring 允许注册文件类似，此功能允许注册环文件描述符本身。这会降低
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
系统调用的开销。

如果使用 liburing 的应用是多线程的，则应用应在设置环时调用此函数来注册环描述符。
有关共享环时的限制，请参见注意事项。

自内核 5.18 起可用。

## 注意事项

环描述符注册后，会存储在 `struct io_uring` 结构的内部。对于在线程之间共享环的应用，
例如一个线程执行提交而另一个线程获取事件，则不能使用此优化，因为每个线程可能具有
不同的已注册环 fd 索引。

## 返回值

成功时返回 1，表示注册了一个文件描述符；发生错误时返回 `-errno`。

## 参见

- [io_uring_unregister_ring_fd(3)](io_uring_unregister_ring_fd.3.md)
- [io_uring_register_files(3)](io_uring_register_files.3.md)
