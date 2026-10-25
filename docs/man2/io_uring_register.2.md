---
title: io_uring_register
section: 2
source_path: man/io_uring_register.2
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 970d071b5f57562c297b34e05bd1f049537b249456ed015f318b60dd85200e68
source_copyright: "Copyright (C) 2019 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2019 Red Hat, Inc."
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register(2)

## 名称

io_uring_register - 为异步 I/O 注册文件或用户缓冲区

## 概要

```c
#include <liburing.h>

int io_uring_register(unsigned int fd, unsigned int opcode,
                      void *arg, unsigned int nr_args);
```

## 描述

[io_uring_register(2)](io_uring_register.2.md) 为 `fd` 引用的 io_uring 实例注册资源
（例如用户缓冲区、文件、eventfd、身份凭据和限制）。注册文件或用户缓冲区使内核可以持有
内部数据结构的长期引用，或建立应用内存的长期映射，从而显著降低每次 I/O 的开销。

`fd` 是 [io_uring_setup(2)](io_uring_setup.2.md) 返回的文件描述符。若 `opcode` 按位
或了 `IORING_REGISTER_USE_REGISTERED_RING`，则 `fd` 是已注册环 fd 的索引。

`opcode` 可以是：

- `IORING_REGISTER_BUFFERS`：自 5.1 起可用。`arg` 指向 `nr_args` 个 `iovec` 组成的
  数组。缓冲区会锁定在内存中，并计入 `RLIMIT_MEMLOCK`；每个缓冲区上限为 1 GiB。目前
  必须是非文件支持的匿名内存（如 `malloc` 或 `MAP_ANONYMOUS` 的 mmap）；未来可能放宽。
  支持大页，但即使只使用部分大页也会固定整个大页。成功后可使用
  `IORING_OP_READ_FIXED`/`IORING_OP_WRITE_FIXED`，将 `buf_index` 设置为索引；
  `addr`/`len` 范围必须位于该缓冲区。可使用大缓冲区中的一部分。更改注册集合前需先
  取消注册。5.13 前注册会等待环中请求全部完成。关闭实例前无需显式取消注册，但取消固定
  可能异步完成。
- `IORING_REGISTER_BUFFERS2`：自 5.13 起可用。更可扩展的注册方式。`arg` 指向
  `struct io_uring_rsrc_register`，`nr_args` 为结构大小：

```c
struct io_uring_rsrc_register {
    __u32 nr;
    __u32 flags;
    __u64 resv2;
    __aligned_u64 data;
    __aligned_u64 tags;
};
```

  `data` 指向 `nr` 个 iovec；`tags` 为 0 时禁用标签，否则指向 `nr` 个 64 位标签。标签
  为 0 表示该资源禁用标签，否则资源取消注册且不再使用后，会发布一个 `user_data` 为该
  标签、其余字段清零的 CQE。`flags` 支持
  `IORING_RSRC_REGISTER_SPARSE`：注册 `nr` 个空缓冲区，使用前必须更新，且 `data`/
  `tags` 必须为 NULL；自 5.19 起可用。资源更新返回时不一定已释放资源，旧资源可能保留到
  所有使用者完成。
- `IORING_REGISTER_BUFFERS_UPDATE`：自 5.13 起使用 `struct io_uring_rsrc_update2`
  原地更新缓冲区，可将稀疏项转为实际项或替换现有项：

```c
struct io_uring_rsrc_update2 {
    __u32 offset;
    __u32 resv;
    __aligned_u64 data;
    __aligned_u64 tags;
    __u32 nr;
    __u32 resv2;
};
```

  `arg` 指向该结构；`data` 指向 iovec 数组，`tags` 指向标签数组，`nr` 为数量。
- `IORING_UNREGISTER_BUFFERS`：自 5.1 起可用。无参数，`arg` 必须为 NULL；同步释放该实例
  先前注册的所有缓冲区。
- `IORING_REGISTER_FILES`：自 5.1 起可用。`arg` 指向 `nr_args` 个文件描述符（32 位
  有符号整数）组成的数组。使用已注册文件时必须设置 `IOSQE_FIXED_FILE`，`fd` 设置为数组
  索引。数组可以是稀疏的，fd 可设为 -1；更新方法见
  `IORING_REGISTER_FILES_UPDATE`。5.13 前注册会等待环空闲；更新现有集合没有该限制。
  关闭实例时自动取消注册，只需在注册新集合前显式取消。
- `IORING_REGISTER_FILES2`：自 5.13 起可用。与 FILES 类似，`arg` 指向
  `struct io_uring_rsrc_register`，`data` 指向 `nr` 个 fd，`tags` 为 0 或标签数组。
  资源更新返回时不一定释放旧资源，可能保留到使用者完成。
- `IORING_REGISTER_FILES_UPDATE`：自 5.5 起可用。用新文件替换、填充稀疏项（fd 为 -1
  表示空项）、移除现有项（新 fd 为 -1）或替换现有项。`arg` 指向
  `struct io_uring_rsrc_update`，其中含起始偏移和 fd 数组；`nr_args` 为数量。自 5.12
  起，fd 可设为 `IORING_REGISTER_FILES_SKIP` 跳过该索引且不触碰原文件。
- `IORING_REGISTER_FILES_UPDATE2`：自 5.13 起可用。与 FILES_UPDATE 类似，但使用
  `struct io_uring_rsrc_update2`：`data` 指向 fd 数组，`tags` 指向标签数组，`nr` 为数量。
- `IORING_UNREGISTER_FILES`：自 5.1 起可用。无参数，`arg` 必须为 NULL；取消注册所有文件。
- `IORING_REGISTER_EVENTFD`：自 5.2 起可用。`arg` 指向 eventfd fd，`nr_args` 必须为 1。
  eventfd 通知可能虚假出现，多个 CQE 的批量完成也可能只产生一个通知；通知只能视为检查
  CQ 的提示。应用可通过在 CQ 环 `flags` 中设置 `IORING_CQ_EVENTFD_DISABLED` 暂时禁用
  通知；自 5.8 起可用。
- `IORING_REGISTER_EVENTFD_ASYNC`：自 5.6 起可用。类似 EVENTFD，但仅异步完成的 event
  发布通知，提交时内联完成的事件不通知；参数规则相同。
- `IORING_UNREGISTER_EVENTFD`：自 5.2 起可用。只需一个 eventfd；无参数，`arg` 为 NULL，
  `nr_args` 为 0。
- `IORING_REGISTER_PROBE`：自 5.6 起可用。`arg` 指向 `struct io_uring_probe`，`nr_args`
  为 ops 数组大小。每个 `io_uring_probe_op` 包含操作码和 flags；设置
  `IO_URING_OP_SUPPORTED` 表示支持。
- `IORING_REGISTER_PERSONALITY`：自 5.6 起可用。注册当前应用凭据并返回 ID，可在 SQE
  的 `personality` 字段使用。无参数，`arg` 为 NULL，`nr_args` 为 0。
- `IORING_UNREGISTER_PERSONALITY`：自 5.6 起可用。`nr_args` 为要取消的 ID，`arg` 为 NULL。
- `IORING_REGISTER_ENABLE_RINGS`：自 5.10 起可用。启用通过
  `IORING_SETUP_R_DISABLED` 创建的环。禁用期间不能提交，但注册不受限；启用后提交和注册
  须符合已注册限制。无参数，`arg` 为 NULL，`nr_args` 为 0。
- `IORING_REGISTER_RESTRICTIONS`：自 5.10 起可用。`arg` 指向 `nr_args` 个
  `struct io_uring_restriction`。条目可允许注册操作码、允许的 SQE 操作码/标志，或要求
  每个 SQE 必须设置某些标志。所有限制必须一次调用提交，并按允许列表处理（未注册的操作码
  和标志不被允许）。环必须以 `IORING_SETUP_R_DISABLED` 创建。可为调用任务注册限制：
  `fd` 为 -1，`arg` 指向 `struct io_uring_task_restriction`，`nr_args` 为 1：

```c
struct io_uring_task_restriction {
    __u16 flags;
    __u16 nr_res;
    __u32 resv[3];
    struct io_uring_restriction restrictions[];
};
```

  任务限制适用于之后创建的所有环，由子进程继承，每个任务只能注册一次；`flags`、`resv`
  必须为 0；调用方需有 `CAP_SYS_ADMIN` 或设置 `no_new_privs`。没有环、以 `fd=-1` 发起的
  注册操作也受允许的注册操作码约束，包括 `IORING_REGISTER_SEND_MSG_RING`、
  `IORING_REGISTER_QUERY` 和 `IORING_REGISTER_BPF_FILTER`。`SEND_MSG_RING` 没有源环，
  因此不受 `IORING_OP_MSG_RING` 限制或 BPF 过滤器约束。自 7.4 起可用。
- `IORING_REGISTER_IOWQ_AFF`：自 5.14 起可用。`arg` 指向 `cpu_set_t`，`nr_args` 为字节
  大小。异步 worker 默认继承父 CPU 掩码，可用此操作指定允许的 CPU。
- `IORING_UNREGISTER_IOWQ_AFF`：自 5.14 起可用。恢复默认 CPU 掩码；`arg` 和 `nr_args`
  必须未设置。
- `IORING_REGISTER_IOWQ_MAX_WORKERS`：自 5.15 起可用。`arg` 指向两个 `unsigned int`：
  索引 0 为每个 NUMA 节点的 bounded worker 上限，索引 1 为 unbounded worker 上限；
  `nr_args` 为 2。成功后数组返回先前上限；传入 0 时只返回当前上限而不修改。
- `IORING_REGISTER_RING_FDS`：自 5.18 起可用。`arg` 指向 `nr_args` 个
  `struct io_uring_rsrc_update`，其中 `data` 为 io_uring fd，`offset` 为 -1 或指定注册
  索引。`offset=-1` 时成功后写回可用的注册 fd。调用 `io_uring_enter(2)` 时设置
  `IORING_ENTER_REGISTERED_RING` 即可使用注册描述符。每个使用环的线程/进程都必须直接
  注册；最多支持 16 个已注册环描述符。
- `IORING_UNREGISTER_RING_FDS`：自 5.18 起可用。`arg` 指向 `nr_args` 个
  `struct io_uring_rsrc_update`，仅设置 `offset`（先前注册返回的偏移）。任务未退出时环
  退出不会自动取消注册；任务仍存活时应手动取消以释放槽位。
- `IORING_REGISTER_PBUF_RING`：自 5.19 起可用。注册用于
  `IOSQE_BUFFER_SELECT` 的共享提供的缓冲区环，替代 `IORING_OP_PROVIDE_BUFFERS`。
  `arg` 指向：

```c
struct io_uring_buf_reg {
    __u64 ring_addr;
    __u32 ring_entries;
    __u16 bgid;
    __u16 flags;
    __u32 min_left;
    __u32 resv[5];
};
```

  `ring_addr` 必须是页对齐内存，大小等于 `ring_entries * sizeof(struct io_uring_buf)`；
  项数必须是 2 的幂，最大 32768。`bgid` 是组 ID；CQE 设置 `IORING_CQE_F_BUFFER` 并在
  flags 中携带缓冲区 ID。`min_left` 是增量消费缓冲区被视为有效所需保留的最小值，默认
  1 字节，仅在 `IOU_PBUF_RING_INC` 时有效；其余字段清零。`nr_args` 为 1。详情见
  [io_uring_register_buf_ring(3)](../man3/io_uring_register_buf_ring.3.md)。
- `IORING_UNREGISTER_PBUF_RING`：自 5.19 起可用。`arg` 指向仅设置 `bgid` 的
  `io_uring_buf_reg`，`nr_args` 为 1。
- `IORING_REGISTER_SYNC_CANCEL`：自 6.0 起可用。执行内联同步取消；`arg` 指向
  `struct io_uring_sync_cancel_reg`，`nr_args` 为 1。返回值与异步取消相同，但同步返回，
  不通过 CQE `res`。见
  [io_uring_register_sync_cancel(3)](../man3/io_uring_register_sync_cancel.3.md)。
- `IORING_REGISTER_FILE_ALLOC_RANGE`：自 6.0 起可用。`arg` 指向
  `struct io_uring_file_index_range`，`nr_args` 为 1：

```c
struct io_uring_file_index_range {
    __u32 off;
    __u32 len;
    __u64 resv;
};
```

  `off`/`len` 设置动态固定文件分配范围，`resv` 清零。必须预先注册文件表。
- `IORING_REGISTER_PBUF_STATUS`：自 6.8 起可用。获取先前注册缓冲区环的当前头部。
  `arg` 指向：

```c
struct io_uring_buf_status {
	__u32	buf_group;	/* 输入 */
	__u32	head;		/* 输出 */
	__u32	resv[8];
};
```

  `buf_group` 为组 ID，`nr_args` 为 1，`resv` 清零，当前头部返回到 `head`。
- `IORING_REGISTER_NAPI`：自 6.9 起可用。`arg` 指向：

```c
struct io_uring_napi {
	__u32	busy_poll_to;
	__u8	prefer_busy_poll;
	__u8	pad[3];
	__u64	resv;
};
```

  `busy_poll_to` 为微秒忙轮询超时，`prefer_busy_poll` 选择忙轮询而非 IRQ；`nr_args`
  为 1，`pad`/`resv` 清零。成功后返回先前设置。
- `IORING_UNREGISTER_NAPI`：自 6.9 起可用。`arg` 指向 `io_uring_napi`，成功后包含先前设置。
- `IORING_REGISTER_CLOCK`：自 6.12 起支持，在带超时调用
  `IORING_ENTER_GETEVENTS` 时设置时钟源；仅设置 `io_uring_getevents_arg` 超时时有意义。
  与 `IORING_ENTER_ABS_TIMER` 一起使用时，超时值是所选时钟的绝对时间。默认为
  `CLOCK_MONOTONIC`，支持 `CLOCK_MONOTONIC` 和 `CLOCK_BOOTTIME`。
- `IORING_REGISTER_CLONE_BUFFERS`：`arg` 指向 `nr_args=1` 的
  `struct io_uring_clone_buffers`：

```c
struct io_uring_clone_buffers {
    __u32 src_fd;
    __u32 flags;
    __u32 src_off;
    __u32 dst_off;
    __u32 nr;
    __u32 pad[3];
};
```

  `src_fd` 为源环，`src_off`/`dst_off`/`nr` 指定克隆子集，`pad` 清零。6.12 只支持三项
  全为 0 的整表克隆，目标表必须为空；6.13 支持部分克隆以及覆盖现有目标表，后者要求在
  `flags` 中设置 `IORING_REGISTER_DST_REPLACE`。
- `IORING_REGISTER_SEND_MSG_RING`：自 6.13 起可用。在无源环情况下发送等价于
  `IORING_OP_MSG_RING` 的请求。`arg` 指向由 `io_uring_prep_msg_ring(3)` 准备的
  `struct io_uring_sqe`；只支持 `IORING_MSG_DATA`，`fd` 为 -1。任务限制允许列表中必须
  包含此注册操作码，否则以 `EACCES` 失败。
- `IORING_REGISTER_RESIZE_RINGS`：自 6.13 起可用。`arg` 指向 `io_uring_params`，
  `sq_entries`/`cq_entries` 设置目标大小；只支持有限标志，主要有 `CQSIZE` 和 `CLAMP`。
  手动使用系统调用者必须像新建环一样执行取消映射和重新映射；成功后 `params` 返回偏移
  信息。见 [io_uring_resize_rings(3)](../man3/io_uring_resize_rings.3.md)。
- `IORING_REGISTER_MEM_REGION`：自 6.13 起可用。`arg` 指向：

```c
struct io_uring_mem_region_reg {
    __u64 region_uptr;
    __u64 flags;
    __u64 __resv[2];
};
```

  `region_uptr` 指向内存区域描述，`flags` 当前必须为
  `IORING_MEM_REGION_REG_WAIT_ARG`，保留字段清零。区域描述如下：

```c
struct io_uring_region_desc {
    __u64 user_addr;
    __u64 size;
    __u32 flags;
    __u32 id;
    __u64 mmap_offset;
    __u64 __resv[4];
};
```

  等待区域数组元素为：

```c
struct io_uring_reg_wait {
    struct __kernel_timespec ts;
    __u32                    min_wait_usec;
    __u32                    flags;
    __u64                    sigmask;
    __u32                    sigmask_sz;
    __u32                    pad[3];
    __u64                    pad2[2];
};
```

  `flags` 当前唯一有效值 `IORING_REG_WAIT_TS` 表示 `ts` 有效。最多可映射一页，每项 64
  字节，4K 页至少 64 项。调用 `io_uring_enter(2)` 时设置
  `IORING_ENTER_EXT_ARG_REG`，`argp` 设置为等待区域偏移，而不是
  `io_uring_getevents_arg` 指针。已注册区域不能取消注册，生命周期与环相同；每次调用前可
  修改区域内容。
- `IORING_REGISTER_ZCRX_IFQ`：自 6.15 起可用。`arg` 指向
  `struct io_uring_zcrx_ifq_reg`，`nr_args=1`。字段依次包括网络接口索引 `if_idx`、
  接收队列索引 `if_rxq`、补充队列项数 `rq_entries`（向上舍入到 2 的幂）、修饰标志、
  区域指针 `area_ptr`、内存区域指针 `region_ptr`、内核返回的 `offsets`、成功后返回的
  `zcrx_id` 及保留字段。环必须设置 `DEFER_TASKRUN` 以及 `CQE32` 或 `CQE_MIXED`，调用方
  需有 `CAP_NET_ADMIN`。
- `IORING_REGISTER_QUERY`：自 6.15 起可用。无需环，`fd=-1`，`arg` 指向
  `struct io_uring_query_hdr`，`nr_args=0`。查询可经 `next_entry` 串联，`query_op` 可为
  `IO_URING_QUERY_OPCODES`、`IO_URING_QUERY_ZCRX` 或 `IO_URING_QUERY_SCQ`；`size`
  为 `query_data` 大小，结果写入 `result`。
- `IORING_REGISTER_ZCRX_CTRL`：自 6.15 起可用。`arg` 指向 `struct zcrx_ctrl`，
  `nr_args=0`。`zcrx_id` 来自 ZCRX_IFQ；`op` 为 `ZCRX_CTRL_FLUSH_RQ`（刷新补充队列）
  或 `ZCRX_CTRL_EXPORT`（导出上下文供其他环使用）。

## 返回值

成功时返回 0 或正值，具体取决于 `opcode`。失败时返回负错误值；调用方不应依赖 `errno`。

## 错误

- `EACCES`：操作码被注册限制禁止。
- `EBADF`：fd 数组中有一个或多个无效 fd。
- `EBADFD`：指定 `ENABLE_RINGS` 或 `RESTRICTIONS`，但环未禁用。
- `EBUSY`：已注册 BUFFERS、FILES 或 RESTRICTIONS 时再次注册同名资源。
- `EEXIST`：执行注册的线程无效。
- `EFAULT`：缓冲区不可访问，或 `iov_len` 大于 1 GiB。
- `EINVAL`：BUFFERS/FILES 的 `nr_args` 为 0；BUFFERS 的 `nr_args` 超过 `UIO_MAXIOV`；
  UNREGISTER_BUFFERS/FILES 的 `nr_args` 非零或 `arg` 非 NULL；RESTRICTIONS 数量过多或
  操作码无效。
- `EMFILE`：固定文件集超过允许上限，或新增文件引用超过用户级 `RLIMIT_NOFILE`，且调用方
  无 `CAP_SYS_RESOURCE`。
- `ENOMEM`：内核资源不足，或超过 `RLIMIT_MEMLOCK` 且无 `CAP_IPC_LOCK`。
- `ENXIO`：取消注册不存在的资源，或环正在注册/销毁。
- `EOPNOTSUPP`：用户缓冲区指向文件支持的内存（旧内核）。
- `EFAULT`：用户缓冲区指向文件支持的内存（新内核）。
- `ENOENT`：PBUF_STATUS 的 `buf_group` 不存在。
- `EINVAL`：PBUF_STATUS 的组不是由 `REGISTER_PBUF_RING` 注册。
- `EINVAL`：REGISTER_NAPI 时，关联环未使用 `IORING_SETUP_IOPOLL` 创建。
