---
title: io_uring_queue_init
section: 3
source_path: man/io_uring_queue_init.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 3f52a666344af23e7f1d38db3a4d38df1254505b0bfb69e260923f98a7853154
source_copyright: "Copyright (C) 2020 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2020 Red Hat, Inc."
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_queue_init(3)

## 名称

io_uring_queue_init - 初始化 io_uring 提交队列和完成队列

## 概要

```c
#include <liburing.h>

int io_uring_queue_init(unsigned entries,
                        struct io_uring *ring,
                        unsigned flags);

int io_uring_queue_init_params(unsigned entries,
                               struct io_uring *ring,
                               struct io_uring_params *params);

int io_uring_queue_init_mem(unsigned entries,
                            struct io_uring *ring,
                            struct io_uring_params *params,
                            void *buf, size_t buf_size);
```

## 描述

[io_uring_queue_init(3)](io_uring_queue_init.3.md) 函数执行
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
系统调用，以内核中至少 `entries` 个提交队列项来初始化提交队列和完成队列，然后将所得
文件描述符映射到应用与内核之间共享的内存。

默认情况下，CQ 环的项数是 SQ 环 `entries` 所指定数量的两倍。这对于普通文件或存储
工作负载已经足够，但对网络工作负载而言可能过小。SQ 环中的项数并不限制环可以支持的
在途请求数量，它仅限制一次（一批）可以提交给内核的数量。如果 CQ 环溢出，例如应用
能够获取这些项之前生成的项数超过环容量，那么在内核支持 `IORING_FEAT_NODROP` 时，
环会进入 CQ 环溢出状态。否则，内核会丢弃 CQE，并将丢弃的 CQE 数量累加到
`struct io_uring` 中的 `cq.koverflow`。如果在 SQ 环标志中设置了
`IORING_SQ_CQ_OVERFLOW`，则表示处于溢出状态。除非内核可用内存耗尽，否则不会丢弃
项，但这条完成路径要慢得多，并且会拖慢请求处理。因此，应避免溢出，并根据工作负载
将 CQ 环设置为适当大小。在 `struct io_uring_params` 中设置 `cq_entries` 会告知内核
为 CQ 环分配这么多项，而不考虑 `entries` 中给出的 SQ 环大小。如果该值不是 2 的
幂，则会向上舍入到最接近的 2 的幂。

成功时，[io_uring_queue_init(3)](io_uring_queue_init.3.md) 返回 0，`ring` 将指向
包含 io_uring 队列的共享内存。失败时返回 `-errno`。

`flags` 会传递给 `io_uring_setup` 系统调用（参见
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)）。

[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 和
[io_uring_queue_init_mem(3)](io_uring_queue_init.3.md) 变体会将由 `params` 指示的
参数直接传递给 [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
系统调用。

[io_uring_queue_init_mem(3)](io_uring_queue_init.3.md) 变体使用所提供的 `buf` 及其
关联大小 `buf_size` 作为环的内存，并向
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
使用 `IORING_SETUP_NO_MMAP` 标志。传递给
[io_uring_queue_init_mem(3)](io_uring_queue_init.3.md) 的缓冲区必须在主机上按页大小
对齐，并且必须已经清零。通常，调用方应分配一个大页，并将其传给
[io_uring_queue_init_mem(3)](io_uring_queue_init.3.md)。通过 `mmap` 分配的页已经
清零。[io_uring_queue_init_mem(3)](io_uring_queue_init.3.md) 返回从所提供的缓冲区
中使用的字节数，以便应用可以使用返回的偏移量复用该缓冲区，在同一大页中放置更多环。

成功时，应通过相应的
[io_uring_queue_exit(3)](io_uring_queue_exit.3.md) 调用释放 `ring` 持有的资源。

## 返回值

[io_uring_queue_init(3)](io_uring_queue_init.3.md) 和
[io_uring_queue_init_params(3)](io_uring_queue_init.3.md) 成功时返回 0，失败时返回
`-errno`。返回值 `-ENOMEM` 表示没有足够的锁定内存来容纳指定数量的项。请减少项数，
或调用
[setrlimit(2)](https://man7.org/linux/man-pages/man2/setrlimit.2.html)
增大可锁定到 RAM 中的最大内存字节数。请注意，在循环中调用
[io_uring_queue_init(3)](io_uring_queue_init.3.md) 和
[io_uring_queue_exit(3)](io_uring_queue_exit.3.md) 会暂时锁定大量内存，因为
[io_uring_queue_exit(3)](io_uring_queue_exit.3.md) 会异步执行部分统计工作。

[io_uring_queue_init_mem(3)](io_uring_queue_init.3.md) 成功时返回从所提供的缓冲区中
使用的字节数，失败时返回 `-errno`。

## 参见

- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
- [io_uring_register_ring_fd(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register_ring_fd.3)
- [mmap(2)](https://man7.org/linux/man-pages/man2/mmap.2.html)
- [io_uring_queue_exit(3)](io_uring_queue_exit.3.md)
