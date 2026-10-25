---
title: io_uring_sqpoll
section: 7
source_path: man/io_uring_sqpoll.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: ebdd8f98067b3f8e628f519b2a3ad47e3304fb22da4a19b329ca79bf144e48e0
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_sqpoll(7)

## 名称

io_uring_sqpoll - io_uring 提交队列轮询概览

## 描述

提交队列轮询（submission queue polling，SQPOLL）是一种运行模式：由 io_uring 创建的
用户空间线程留在内核中监控提交队列，并代表应用提交请求。这样，应用无需通过系统调用
提交 I/O，从而降低高吞吐工作负载的延迟和 CPU 开销。

### 为什么使用 SQPOLL？

普通 io_uring 操作中，应用必须调用
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
（通常通过 [io_uring_submit(3)](../man3/io_uring_submit.3.md)）通知内核有新提交。
虽然高效，但仍有系统调用开销。

启用 SQPOLL 后，内核线程会持续轮询提交队列中的新项。应用一旦将 SQE 写入环，内核线程
就会取得并提交它。这带来提交系统调用开销消除、更低且更可预测的延迟，以及高 IOPS
工作负载下更好的 CPU 利用率。

SQPOLL 最适合高吞吐存储工作负载（NVMe 等）、延迟敏感应用、持续 I/O 流工作负载，以及
已经高 CPU 利用率的应用。

### SQPOLL 可能没有帮助的情况

SQPOLL 并非普遍有利，每种用例都应通过基准测试确定是否提供价值。可能无效或损害性能的
情况包括：

- 低 IOPS 工作负载：如果应用很少提交 I/O，节省的系统调用开销微不足道，轮询线程反而
  浪费 CPU 周期。
- CPU 受限系统：轮询线程会消耗 CPU。如果系统已经受 CPU 限制，增加轮询线程可能与应用
  争用 CPU，降低整体性能。
- 突发工作负载：如果 I/O 以突发形式出现并有空闲期，轮询线程可能频繁休眠和唤醒，增加
  唤醒延迟。常规提交可能更高效。
- 单 CPU 上的单线程应用：轮询线程和应用会争用同一 CPU，可能导致抵消收益的上下文切换。
- 以完成处理为主的工作负载：SQPOLL 只优化提交。如果应用大部分时间都用于处理完成事件，
  SQPOLL 帮助很小。

始终应在真实条件下分别测试启用和未启用 SQPOLL 的性能。硬件、内核版本和工作负载特征会
显著影响性能差异。

### 启用 SQPOLL

创建环时设置 `IORING_SETUP_SQPOLL` 标志即可启用：

```c
struct io_uring ring;
struct io_uring_params params = {
    .flags = IORING_SETUP_SQPOLL,
    .sq_thread_idle = 2000,  /* 2 秒 */
};

ret = io_uring_queue_init_params(entries, &ring, &params);
```

`sq_thread_idle` 字段指定没有待提交内容时，内核线程在休眠前会轮询多长时间（毫秒）。
值为 0 表示线程从不休眠（消耗更多 CPU，但延迟最低）。

### 轮询线程生命周期

使用 SQPOLL 创建环时，会派生一个内核线程为其服务。线程行为如下：

1. 轮询提交队列中的新项。
2. 提交发现的所有新请求。
3. 如果 `sq_thread_idle` 毫秒内未发现新项，则进入休眠。
4. 收到应用发出的信号时唤醒。

应用可以使用
[io_uring_sq_ready(3)](../man3/io_uring_sq_ready.3.md) 检查 `sq->kflags` 中是否设置
了 `IORING_SQ_NEED_WAKEUP`，从而判断线程是否正在休眠。如果设置了该标志，应用必须调用
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
并传入 `IORING_ENTER_SQ_WAKEUP` 来唤醒线程：

```c
/* 添加 SQE 后 */
io_uring_smp_store_release(ring->sq.ktail, tail);

if (IO_URING_READ_ONCE(*ring->sq.kflags) & IORING_SQ_NEED_WAKEUP)
    io_uring_enter(ring->ring_fd, 0, 0, IORING_ENTER_SQ_WAKEUP, NULL);
```

[io_uring_submit(3)](../man3/io_uring_submit.3.md) 会自动处理这一过程。

### CPU 亲和性

默认情况下，内核可以将轮询线程调度到任意可用 CPU。为了改善缓存局部性并降低延迟，可以
将线程固定到特定 CPU：

```c
struct io_uring_params params = {
    .flags = IORING_SETUP_SQPOLL | IORING_SETUP_SQ_AFF,
    .sq_thread_cpu = 3,  /* 固定到 CPU 3 */
    .sq_thread_idle = 1000,
};
```

`IORING_SETUP_SQ_AFF` 标志启用 CPU 亲和性，`sq_thread_cpu` 指定使用哪个 CPU。

### 凭据要求

传统上，创建 SQPOLL 环需要较高权限，因为内核线程代表应用运行。要求已经演变：

- 内核 5.11 及更早版本：需要 `CAP_SYS_ADMIN` 或 `CAP_SYS_NICE`。
- 内核 5.12 及更高版本：非特权用户可以创建 SQPOLL 环，但轮询线程以降低后的能力运行。
- `IORING_SETUP_NO_SQARRAY` 标志（内核 6.6+）可以简化仅使用 SQPOLL 的环设置。

### 共享轮询线程

多个环可以使用 `IORING_SETUP_ATTACH_WQ` 共享一个轮询线程。当应用使用多个环时，这可
减少资源使用：

```c
/* 创建第一个 SQPOLL 环 */
struct io_uring_params p1 = { .flags = IORING_SETUP_SQPOLL };
io_uring_queue_init_params(entries, &ring1, &p1);

/* 创建第二个环并附加到第一个环的线程 */
struct io_uring_params p2 = {
    .flags = IORING_SETUP_SQPOLL | IORING_SETUP_ATTACH_WQ,
    .wq_fd = ring1.ring_fd,
};
io_uring_queue_init_params(entries, &ring2, &p2);
```

### 完成事件处理

SQPOLL 只影响提交。完成事件仍按常规方式处理——应用必须直接忙等待轮询完成队列、使用
带 `IORING_ENTER_GETEVENTS` 的
[io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
等待完成，或使用 eventfd 通知。

如果要在提交和完成两端都进行轮询，可将 SQPOLL 与
[io_uring_peek_cqe(3)](../man3/io_uring_peek_cqe.3.md) 等完成队列轮询函数结合使用。

### 性能注意事项

- CPU 使用：轮询线程活动时会消耗 CPU。如果 I/O 是偶发的，线程可能浪费周期轮询空队列。
  请根据工作负载适当设置 `sq_thread_idle`。
- 空闲超时权衡：较短空闲超时节省 CPU，但可能增加线程唤醒延迟。较长超时（或从不休眠的
  0）使用更多 CPU，但提供稳定的低延迟。
- 批处理：即使使用 SQPOLL，在更新尾指针前添加多个 SQE 进行批量提交仍能提高吞吐量。
- CPU 亲和性：将轮询线程固定到应用 CPU 附近可以改善缓存行为，并减少跨 CPU 通信。

## 注意事项

- 除非通过 `IORING_SETUP_ATTACH_WQ` 共享，轮询线程是每个环一个。创建许多不共享的
  SQPOLL 环会消耗大量内核资源。
- SQPOLL 环在等待完成（除非忙轮询 CQ）、线程空闲后唤醒以及注册操作时仍需要系统调用。
- 轮询线程会继承创建进程的资源限制和 cgroup 成员关系。
- 如果轮询线程遇到无法恢复的错误，`sq->kflags` 中可能设置
  `IORING_SQ_CQ_OVERFLOW`。
- SQPOLL 与已注册文件和缓冲区配合良好，可进一步降低单次 I/O 开销。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
- [io_uring_queue_init_params(3)](../man3/io_uring_queue_init.3.md)
- [io_uring_register_files(3)](../man3/io_uring_register_files.3.md)
- [io_uring_registered_buffers(7)](io_uring_registered_buffers.7.md)
