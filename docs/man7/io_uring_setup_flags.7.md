---
title: io_uring_setup_flags
section: 7
source_path: man/io_uring_setup_flags.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: b291ba7f247011c06ef6fbc71e4d8b56c584af1f6e5f567ce39af944cae51f81
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_setup_flags(7)

## 名称

io_uring_setup_flags - io_uring 环设置标志概览

## 描述

通过 [io_uring_queue_init_params(3)](../man3/io_uring_queue_init.3.md) 或
[io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
创建 io_uring 实例时，各种标志控制环的行为。这些标志设置于
`struct io_uring_params` 的 `flags` 字段。

正确的标志会显著影响性能。下面概述可用标志、用途以及常见组合。

### 轮询标志

- `IORING_SETUP_IOPOLL`：为支持该模式的文件描述符启用 I/O 轮询。内核不再依赖中断，
  而是轮询完成事件，从而降低高性能存储设备（NVMe 等）的延迟。它要求使用 `O_DIRECT`
  打开文件（使用 `IORING_OP_{READ,WRITE}(V)(_FIXED)` 操作码时）、硬件和驱动支持轮询、
  应用通过 `io_uring_enter(2)` 忙轮询获取完成事件，并且存储设备配置支持轮询。
  IOPOLL 环只允许 `IORING_OP_NOP(128)`、`IORING_OP_{READ,WRITE}(V)(_FIXED)`（文件
  支持忙轮询时）、`IORING_OP_FILES_UPDATE`、`IORING_OP_{PROVIDE,REMOVE}_BUFFERS`、
  `IORING_OP_MSG_RING` 和 `IORING_OP_URING_CMD(128)`。自 7.1 内核起，
  `IORING_OP_URING_CMD(128)` 在文件支持忙轮询时使用忙轮询；此前该操作只允许用于支持
  忙轮询的文件。对 NVMe 设备通常需设置内核参数 `nvme.poll_queues=X`，X 是为轮询操作
  预留的完成队列数量。
- `IORING_SETUP_SQPOLL`：创建轮询提交队列的内核线程，消除提交 I/O 的系统调用。详情
  请参见 [io_uring_sqpoll(7)](io_uring_sqpoll.7.md)。
- `IORING_SETUP_SQ_AFF`：将 SQPOLL 线程固定到特定 CPU。需要
  `IORING_SETUP_SQPOLL`，CPU 由 `struct io_uring_params` 的 `sq_thread_cpu` 指定。
- `IORING_SETUP_HYBRID_IOPOLL`：启用混合轮询。内核采用自适应方式而非纯忙轮询，可能
  短暂休眠，在保持低延迟的同时减少 CPU 使用，是中断驱动与纯轮询之间的折中。

### 任务执行标志

- `IORING_SETUP_COOP_TASKRUN`：禁用完成处理对应用的中断。通常内核会在完成事件就绪时
  通知应用，这可能中断系统调用。设置后，应用从任意系统调用返回用户空间时都会处理完成
  事件，而不限于 io_uring 相关调用。应用必须经常进入内核。
- `IORING_SETUP_TASKRUN_FLAG`：有完成工作待处理时，在 SQ 环标志中设置
  `IORING_SQ_TASKRUN`，使应用无需系统调用即可检查。通常与
  `IORING_SETUP_COOP_TASKRUN` 配合。
- `IORING_SETUP_DEFER_TASKRUN`：仅当应用通过 `io_uring_enter(2)` 显式进入内核时处理
  完成工作，而不是在任意系统调用返回时处理。这提供最严格、最可预测的控制，并改善缓存
  行为。它要求 `IORING_SETUP_SINGLE_ISSUER`，且每个线程创建自己的环。应用必须定期
  调用 `io_uring_enter(2)`（通过 `io_uring_submit`、`io_uring_wait_cqe` 等）；否则
  完成事件会停滞。环大小调整和零拷贝接收（`IORING_OP_RECV_ZC`）等功能要求此标志。
- `IORING_SETUP_SINGLE_ISSUER`：提示只有一个任务向此环提交请求，启用减少锁开销等内部
  优化。第一个提交者成为指定提交者；其他任务尝试提交会得到 `-EEXIST`。每个线程或任务
  使用自己的环是 io_uring 的惯用方式；不建议在多个线程之间共享环。

### 环大小标志

- `IORING_SETUP_CQSIZE`：覆盖默认 CQ 大小。默认 CQ 项数是 SQ 的两倍。通过
  `struct io_uring_params` 的 `cq_entries` 指定自定义 CQ 大小，必须为 2 的幂。
- `IORING_SETUP_CLAMP`：请求大小超过允许值时，将 SQ/CQ 大小限制为最大值，而不是返回
  `-EINVAL`。
- `IORING_SETUP_SQE128`：使用 128 字节 SQE 而非默认 64 字节。某些需要额外空间的操作
  （如 `IORING_OP_URING_CMD` 透传命令）要求此标志。
- `IORING_SETUP_CQE32`：使用 32 字节 CQE 而非默认 16 字节。某些返回额外数据的操作
  （例如部分透传命令或 `IORING_OP_MSG_RING`）要求此标志。
- `IORING_SETUP_NO_SQARRAY`：不创建 SQ 数组。SQ 数组是一层间接索引，允许提交顺序
  不同于环中的排列。多数按顺序提交的应用不需要它。此标志节省内存，并且
  `IORING_SETUP_REGISTERED_FD_ONLY` 等模式要求它。
- `IORING_SETUP_SQ_REWIND`：使用非循环 SQ 模式。内核忽略 SQ 头尾指针，每次提交都从
  索引 0 开始取 SQE。应用在调用 `io_uring_enter(2)` 前将所有 SQE 放在环开头，
  `sq_entries` 决定提交多少个 SQE。要求 `IORING_SETUP_NO_SQARRAY`，不兼容
  `IORING_SETUP_SQPOLL`。该模式总访问环开头相同内存位置，使 SQE 保持热缓存。
- `IORING_SETUP_CQE_MIXED`：允许每个请求选择返回 16 或 32 字节 CQE。请求需要 32 字节
  CQE 时设置 `IOSQE_BIG_CQE`，否则使用 16 字节。要求 `IORING_SETUP_CQE32`。这适合
  只有部分操作需要扩展 CQE 的场景，比始终使用 32 字节 CQE 更节省内存带宽。
- `IORING_SETUP_SQE_MIXED`：允许环接受 64 和 128 字节 SQE。请求需要 128 字节时设置
  `IOSQE_BIG_SQE`。要求 `IORING_SETUP_SQE128`。这适合只有部分操作（如
  `IORING_OP_URING_CMD`）需要大 SQE 的场景。

### 内存与初始化标志

- `IORING_SETUP_NO_MMAP`：应用为环提供自己的内存，而不是由内核分配后应用 mmap。
  应用用所分配内存地址填写 `struct io_uring_params` 的 `sq_off.user_addr`、
  `cq_off.user_addr` 和 `sq_sqes.user_addr`。这可将环放入大页、共享内存等特定内存，
  或在不用 mmap 的情况下创建环。
- `IORING_SETUP_REGISTERED_FD_ONLY`：环 fd 不安装到进程文件描述符表，而是在 `ring_fd`
  返回“已注册环”索引。设置 `IORING_ENTER_REGISTERED_RING` 后可通过
  `io_uring_enter(2)` 使用。要求 `IORING_SETUP_NO_SQARRAY`，并且应用必须使用
  [io_uring_register_ring_fd(3)](../man3/io_uring_register_ring_fd.3.md) 或通过已注册
  索引访问环。
- `IORING_SETUP_R_DISABLED`：以禁用状态创建环，直到通过
  [io_uring_enable_rings(3)](../man3/io_uring_enable_rings.3.md) 启用后才接受提交。
  适合在允许 I/O 前设置限制或已注册资源；参见
  [io_uring_register_restrictions(3)](../man3/io_uring_register_restrictions.3.md)。

### 提交标志

- `IORING_SETUP_SUBMIT_ALL`：即使某个提交失败也继续处理后续提交。通常同一提交调用中
  某个 SQE 在提交阶段失败（非执行阶段）后，后续 SQE 不再处理。失败 SQE 仍会生成错误
  CQE；此标志只影响后续 SQE 是否提交，通常更符合应用预期。

### 工作队列标志

- `IORING_SETUP_ATTACH_WQ`：与另一个环共享异步工作线程池。将
  `struct io_uring_params` 的 `wq_fd` 设置为目标环的文件描述符。应用使用多个环时可
  减少资源使用。与 `IORING_SETUP_SQPOLL` 组合时，SQPOLL 线程也会共享。

### 常见标志组合

高性能单线程应用：

```c
.flags = IORING_SETUP_SINGLE_ISSUER |
         IORING_SETUP_DEFER_TASKRUN |
         IORING_SETUP_COOP_TASKRUN
```

每个线程有独立环并采用专用事件循环处理完成事件时，此组合提供最佳延迟和吞吐量。

低延迟存储轮询：

```c
.flags = IORING_SETUP_IOPOLL |
         IORING_SETUP_SINGLE_ISSUER |
         IORING_SETUP_DEFER_TASKRUN
```

适用于 NVMe 等支持轮询的设备，消除中断开销，并用 `DEFER_TASKRUN` 优化完成处理。

无系统调用提交：

```c
.flags = IORING_SETUP_SQPOLL |
         IORING_SETUP_SQ_AFF
.sq_thread_cpu = preferred_cpu
.sq_thread_idle = 1000
```

适用于从消除提交系统调用开销中获益的工作负载；参见
[io_uring_sqpoll(7)](io_uring_sqpoll.7.md)。

多个环共享资源：

```c
/* 第一个环 */
p1.flags = IORING_SETUP_SQPOLL;

/* 后续环 */
p2.flags = IORING_SETUP_SQPOLL | IORING_SETUP_ATTACH_WQ;
p2.wq_fd = ring1_fd;
```

使用多个环时，这会减少内核线程和工作队列开销。

## 注意事项

- 并非所有标志组合都有效；对不兼容组合，内核返回 `-EINVAL`。
- 某些标志要求特定内核版本，请查看
  [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
  的版本要求。
- [io_uring_queue_init_params(3)](../man3/io_uring_queue_init.3.md) 会处理环设置的
  复杂性；直接使用 `io_uring_setup(2)` 系统调用需要谨慎完成 mmap 设置。
- 对于大多数具有正规事件循环的应用，建议默认将
  `IORING_SETUP_DEFER_TASKRUN` 与 `IORING_SETUP_SINGLE_ISSUER` 组合，以获得对完成
  工作执行时机的最佳控制及最佳缓存局部性。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_sqpoll(7)](io_uring_sqpoll.7.md)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
- [io_uring_queue_init_params(3)](../man3/io_uring_queue_init.3.md)
- [io_uring_register_restrictions(3)](../man3/io_uring_register_restrictions.3.md)
- [io_uring_enable_rings(3)](../man3/io_uring_enable_rings.3.md)
