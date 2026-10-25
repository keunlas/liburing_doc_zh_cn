---
title: io_uring_setup
section: 2
source_path: man/io_uring_setup.2
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a8dfc18d9e011d529c7db64ebd46e390856a72bcbc8240e8333d79b12e0ebbbd
source_copyright: "Copyright (C) 2019 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2019 Jon Corbet <corbet@lwn.net>; Copyright (C) 2019 Red Hat, Inc."
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_setup(2)

## 名称

io_uring_setup - 设置用于执行异步 I/O 的上下文

## 概要

```c
#include <liburing.h>

int io_uring_setup(u32 entries, struct io_uring_params *params);
```

## 描述

[io_uring_setup(2)](io_uring_setup.2.md) 系统调用创建至少具有 `entries` 个项的提交队列
（SQ）和完成队列（CQ），并返回一个文件描述符，用于在 io_uring 实例上执行后续操作。
队列由用户空间和内核共享，因而在发起和完成 I/O 时无需复制数据。

`params` 用于应用向内核传递选项，也由内核回传环缓冲区信息：

```c
struct io_uring_params {
    __u32 sq_entries;
    __u32 cq_entries;
    __u32 flags;
    __u32 sq_thread_cpu;
    __u32 sq_thread_idle;
    __u32 features;
    __u32 wq_fd;
    __u32 resv[3];
    struct io_sqring_offsets sq_off;
    struct io_cqring_offsets cq_off;
};
```

`flags`、`sq_thread_cpu` 和 `sq_thread_idle` 用于配置实例。`flags` 由以下 0 个或多个值
按位或组成：

- `IORING_SETUP_IOPOLL`：忙等待 I/O 完成，而不是通过异步 IRQ 通知。文件系统和块设备
  必须支持轮询；忙等待延迟更低但可能消耗更多 CPU。使用
  `IORING_OP_{READ,WRITE}(V)(_FIXED)` 时，目前只能用于 `O_DIRECT` 打开的文件。向
  轮询上下文提交读写后，应用必须调用 `io_uring_enter(2)` 轮询 CQ。大多数非轮询请求
  不允许用于 IOPOLL 实例，允许的操作码见
  [io_uring_setup_flags(7)](../man7/io_uring_setup_flags.7.md)。目前仅适用于配置为
  轮询的存储设备；NVMe 驱动需将 `poll_queues` 参数设置为所需轮询队列数。若该数少于
  在线 CPU 线程数，队列会在 CPU 间共享。
- `IORING_SETUP_HYBRID_IOPOLL`：必须与 `IORING_SETUP_IOPOLL` 一起使用。混合轮询会延迟
  完成侧轮询，以避免浪费过多 CPU，同时仍要求设备支持轮询。
- `IORING_SETUP_SQPOLL`：创建内核线程轮询提交队列。应用填入 SQE 并查看 CQ 即可提交和
  获取 I/O，无需进入内核。内核线程空闲超过 `sq_thread_idle` 毫秒后，会在
  `struct io_sq_ring` 的 `flags` 中设置 `IORING_SQ_NEED_WAKEUP`；应用必须调用
  `io_uring_enter(2)` 唤醒它。持续繁忙时线程不会休眠。唤醒检查必须在写尾指针后使用
  获取语义读取标志：

```c
/*
 * 确保写完尾指针后读取唤醒标志。标志读取必须使用
 * 内存加载获取语义，否则应用和内核可能对唤醒标志
 * 的一致性产生分歧。
 */
unsigned flags = atomic_load_relaxed(sq_ring->flags);
if (flags & IORING_SQ_NEED_WAKEUP)
    io_uring_enter(fd, 0, 0, IORING_ENTER_SQ_WAKEUP);
```

  使用 liburing 时通常由 `io_uring_submit(3)` 自动处理是否调用
  `io_uring_enter(2)`。SQPOLL 不一定总能提高性能，应按实际应用评估。5.11 之前必须
  通过 `io_uring_register(2)` 的 `IORING_REGISTER_FILES` 注册文件，否则 I/O 会以
  `EBADF` 失败；支持情况由 `IORING_FEAT_SQPOLL_NONFIXED` 表示。5.11 起无需注册文件，
  非 root 用户具有 `CAP_SYS_NICE` 时也可使用；5.13 起新内核不再要求特殊权限，某些
  5.13 之前的稳定内核也支持非特权 SQPOLL。
- `IORING_SETUP_SQ_AFF`：将轮询线程绑定到 `sq_thread_cpu` 指定的 CPU。仅对 SQPOLL
  有意义。cgroup 的 `cpuset.cpus` 改变时，绑定 CPU 集合也可能改变。
- `IORING_SETUP_CQSIZE`：按 `params.cq_entries` 创建 CQ。该值必须大于 `entries`，
  并可能向上舍入为 2 的幂。
- `IORING_SETUP_CLAMP`：`entries` 超过 `IORING_MAX_ENTRIES` 时将其限制到该值；设置
  `CQSIZE` 且 `cq_entries` 超过 `IORING_MAX_CQ_ENTRIES` 时同样限制。
- `IORING_SETUP_ATTACH_WQ`：将 `wq_fd` 设置为现有 io_uring 环 fd，新实例会共享其异步
  工作线程后端，而不是创建新线程池；设置 SQPOLL 时也共享 SQ 轮询线程。
- `IORING_SETUP_R_DISABLED`：环以禁用状态启动，可注册限制但不能提交。启用方法见
  `io_uring_register(2)`。自 5.10 起可用。
- `IORING_SETUP_SUBMIT_ALL`：通常批量提交中某个请求出错会停止提交后续请求。设置后，
  即使某请求提交出错，`io_uring_enter(2)` 仍继续处理后续请求。失败请求仍产生 CQE，
  区别仅在于是否停止提交序列。自 5.18 起可用。
- `IORING_SETUP_COOP_TASKRUN`：禁用完成事件对用户空间任务的强制中断。完成只在应用从
  任意系统调用返回用户空间时处理。这消除处理器间中断和内核/用户转换开销，但要求应用
  定期进入内核；适用于大多数事件循环应用。自 5.19 起可用。
- `IORING_SETUP_TASKRUN_FLAG`：与 `COOP_TASKRUN` 或 `DEFER_TASKRUN` 一起使用时，有
  待处理完成工作会在 SQ `flags` 中设置 `IORING_SQ_TASKRUN`。liburing 在
  `io_uring_peek_cqe(3)` 中也会检查并进入内核处理，因此 peek 风格应用可安全使用。自
  5.19 起可用。
- `IORING_SETUP_SQE128`：使用 128 字节 SQE 而非 64 字节。某些请求要求该标志；截至
  5.19，NVMe 透传的 `IORING_OP_URING_CMD` 需要它。自 5.19 起可用。
- `IORING_SETUP_CQE32`：使用 32 字节 CQE 而非 16 字节。某些请求要求该标志；截至
  5.19，NVMe 透传的 `IORING_OP_URING_CMD` 需要它。替代方案见
  `IORING_SETUP_CQE_MIXED`。自 5.19 起可用。
- `IORING_SETUP_SINGLE_ISSUER`：提示内核只有一个任务会提交请求，以启用内部优化。
  提交者是创建环的任务；若设置了 `R_DISABLED`，则是通过 `io_uring_register(2)` 启用
  环的任务。违反规则会以 `-EEXIST` 失败。设置 SQPOLL 时，内核认为轮询线程代表用户空间
  提交，因此无论多少用户空间任务调用 `io_uring_enter(2)` 都符合规则。自 6.0 起可用。
- `IORING_SETUP_DEFER_TASKRUN`：将未完成工作推迟到带 `IORING_ENTER_GETEVENTS` 的
  `io_uring_enter(2)`。这要求 `SINGLE_ISSUER`，且 `io_uring_enter(2)` 必须由提交请求
  的同一线程调用。应用必须定期触发工作，否则完成事件可能无法交付。自 6.1 起可用。
- `IORING_SETUP_NO_MMAP`：使用调用方分配的内存，而不是内核分配后由调用方 mmap。
  `p->sq_off.user_addr` 和 `p->cq_off.user_addr` 指向 SQ/CQ 环内存，
  `p->sq_sqes.user_addr`（源文中写作 `sq_off.user_addr`）指向 SQE 内存；各分配必须
  连续，通常用 mmap 分配大页。设置后 mmap io_uring fd 会失败。自 6.5 起可用。
- `IORING_SETUP_REGISTERED_FD_ONLY`：注册环 fd 并返回注册索引，不分配未注册 fd。
  调用 `io_uring_register(2)` 时需使用 `IORING_REGISTER_USE_REGISTERED_RING`。必须与
  `NO_MMAP` 一起使用。自 6.5 起可用。
- `IORING_SETUP_NO_SQARRAY`：SQE 按顺序提交，到达末尾后回绕，不再经提交数组间接索引，
  队列直接由尾部及模运算索引。应用不应映射 SQ 数组，`sq_off.array` 为 0。自 6.6 起
  可用。
- `IORING_SETUP_CQE_MIXED`：允许同时发布 16 字节和 32 字节 CQE。32 字节 CQE 的
  `flags` 设置 `IORING_CQE_F_32`；若 32 字节 CQE 会跨越环尾，内核可发布设置
  `IORING_CQE_F_SKIP` 的填充 16 字节 CQE，应用应跳过。自 6.18 起可用。
- `IORING_SETUP_SQ_REWIND`：内核忽略 SQ 头尾，每次提交都从索引 0 获取 SQE；应用在每次
  提交前将 SQE 放在环开头，`io_uring_enter(2)` 的 `sq_entries` 指定数量。要求
  `NO_SQARRAY`，不兼容 `SQPOLL`。自 7.0 起可用。

未指定标志时使用中断驱动 I/O，通过 `io_uring_enter(2)` 提交并轮询 CQ。`resv` 数组必须
清零。内核填写 `features`：

- `IORING_FEAT_SINGLE_MMAP`：可用一次 mmap 映射 SQ/CQ，SQE 仍需单独映射；自 5.4。
- `IORING_FEAT_NODROP`：CQ 满时内核内部保存完成事件，几乎不丢弃；旧内核溢出时提交可能
  以 `-EBUSY` 失败，需要先取出事件再重试。自 5.5。自 5.19 起，下一次原本会休眠等待完成
  的 `io_uring_enter(2)` 会返回 `-EBADR`。
- `IORING_FEAT_SUBMIT_STABLE`：内核消费 SQE 后，异步卸载所需数据也已被消费；自 5.5。
- `IORING_FEAT_RW_CUR_POS`：支持读写请求的 `offset == -1` 表示当前文件位置，行为类似
  preadv2/pwritev2 的 `-1`；自 5.6。
- `IORING_FEAT_CUR_PERSONALITY`：同步和异步请求都采用调用 `io_uring_enter(2)` 排队
  任务的凭据；否则采用最初注册 io_uring 的任务凭据；自 5.6。
- `IORING_FEAT_FAST_POLL`：内部 poll 驱动数据/空间就绪，无需将不可读写请求交给异步
  线程；自 5.7。
- `IORING_FEAT_POLL_32BITS`：`IORING_OP_POLL_ADD` 接受完整 32 位 epoll 标志，包括
  `EPOLLEXCLUSIVE`；自 5.9。
- `IORING_FEAT_SQPOLL_NONFIXED`：SQPOLL 不再要求固定文件；自 5.11。
- `IORING_FEAT_EXT_ARG`：`io_uring_enter(2)` 支持扩展参数；
- `IORING_FEAT_NATIVE_WORKERS`：异步辅助使用原生 worker；自 5.12。
- `IORING_FEAT_RSRC_TAGS`：支持固定文件/缓冲区相关特性，尤其支持原地更新已注册缓冲区；
  自 5.13。
- `IORING_FEAT_CQE_SKIP`：支持 `IOSQE_CQE_SKIP_SUCCESS`；成功不发布 CQE，错误仍发布；
  自 5.17。
- `IORING_FEAT_LINKED_FILE`：对具有依赖的 SQE 延迟文件分配，直到请求开始执行；自 5.17。
- `IORING_FEAT_REG_REG_RING`：支持通过已注册环 fd 和
  `IORING_REGISTER_USE_REGISTERED_RING` 调用 `io_uring_register(2)`；自 6.3。
- `IORING_FEAT_MIN_TIMEOUT`：支持最小批量等待超时；参见
  [io_uring_submit_and_wait_min_timeout(3)](../man3/io_uring_submit_and_wait_min_timeout.3.md)。
- `IORING_FEAT_RECVSEND_BUNDLE`：支持捆绑发送/接收，并意味着发送支持提供的缓冲区。

`features` 支持扩展参数时，`struct io_uring_getevents_arg` 布局为：

```c
struct io_uring_getevents_arg {
    __u64 sigmask;
    __u32 sigmask_sz;
    __u32 pad;
    __u64 ts;
};
```

设置 `IORING_ENTER_EXT_ARG` 时必须传入该结构指针。自 5.11 起可用。

内核还会填写 `sq_entries` 和 `sq_off`，用于映射 SQ：

```c
struct io_sqring_offsets {
    __u32 head;
    __u32 tail;
    __u32 ring_mask;
    __u32 ring_entries;
    __u32 flags;
    __u32 dropped;
    __u32 array;
    __u32 resv1;
    __u64 user_addr;
};
```

SQ 映射示例：

```c
ptr = mmap(0, sq_off.array + sq_entries * sizeof(__u32),
           PROT_READ|PROT_WRITE, MAP_SHARED|MAP_POPULATE,
           ring_fd, IORING_OFF_SQ_RING);
```

头部指针地址为 `ptr + sq_off.head`。索引通过 `tail & ring_mask` 计算。SQE 数组映射：

```c
sqentries = mmap(0, sq_entries * sizeof(struct io_uring_sqe),
                 PROT_READ|PROT_WRITE, MAP_SHARED|MAP_POPULATE,
                 ring_fd, IORING_OFF_SQES);
```

`flags` 用于通知何时需要调用 `io_uring_enter(2)`；`dropped` 对遇到的每个无效 SQE
递增。应用推进 tail，内核推进 head。

CQ 由 `cq_entries` 和 `cq_off` 描述：

```c
struct io_cqring_offsets {
    __u32 head;
    __u32 tail;
    __u32 ring_mask;
    __u32 ring_entries;
    __u32 overflow;
    __u32 cqes;
    __u32 flags;
    __u32 resv1;
    __u64 user_addr;
};
```

```c
ptr = mmap(0, cq_off.cqes + cq_entries * sizeof(struct io_uring_cqe),
           PROT_READ|PROT_WRITE, MAP_SHARED|MAP_POPULATE, ring_fd,
           IORING_OFF_CQ_RING);
```

关闭返回的 fd 会释放上下文资源，但释放可能异步发生。

## 返回值

成功时返回新的文件描述符，可用于 mmap、`io_uring_register(2)` 和
`io_uring_enter(2)`。失败时返回负错误码，调用方不应依赖 `errno`。

## 错误

- `EFAULT`：`params` 位于不可访问地址空间。
- `EINVAL`：`resv` 非零、包含不支持的标志、`entries` 越界、只设置 `SQ_AFF` 未设置
  `SQPOLL`、设置 `CQSIZE` 但 `cq_entries` 无效，或设置 `REGISTERED_FD_ONLY` 但未设置
  `NO_MMAP`。
- `EMFILE`：达到进程打开文件数限制（`RLIMIT_NOFILE`）。
- `ENFILE`：达到系统级打开文件总数限制。
- `ENOMEM`：内核资源不足。
- `EPERM`：设置 `SQPOLL`，但有效用户 ID 权限不足。
- `EPERM`：`/proc/sys/kernel/io_uring_disabled` 为 2，或为 1 且调用进程没有
  `CAP_SYS_ADMIN` 且不属于 `/proc/sys/kernel/io_uring_group`。
- `ENXIO`：设置 `ATTACH_WQ`，但 `wq_fd` 不是 io_uring 实例或该实例正在关闭。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
