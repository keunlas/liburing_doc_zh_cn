---
title: io_uring_provided_buffers
section: 7
source_path: man/io_uring_provided_buffers.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a0576170b2e0b131596b276c3573acb8791fc221d5f230b08118991fdb3d303d
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_provided_buffers(7)

## 名称

io_uring_provided_buffers - io_uring 提供的缓冲区环概览

## 描述

提供的缓冲区环允许应用向内核提供一组缓冲区，由内核在操作完成时动态选择。对于无法
预先确定缓冲区需求的操作用途尤其明显，例如从网络套接字接收数据或从管道读取。

### 为什么使用提供的缓冲区？

传统 I/O 操作要求在提交请求时指定缓冲区。对于套接字接收或管道读取，这带来挑战：应用
不知道将到达多少数据，因此必须选择为每个待处理操作分配大缓冲区（浪费内存）、使用小
缓冲区并可能需要多次操作，或者限制待处理操作数量以控制内存使用。

提供的缓冲区环通过允许内核在完成时从共享池中选择大小合适的缓冲区来解决此问题。多个
操作可以共享同一缓冲区池，并且只有数据实际到达时才消费缓冲区。

提供的缓冲区最适合具有大量并发连接的网络服务器、接收变长消息的应用，以及内存效率
重要的场景。

### 缓冲区环概念

提供的缓冲区环是应用与内核共享的环形缓冲区：

- 应用通过写入项并推进尾部来向环添加缓冲区。
- 内核通过读取项并推进头部来从环消费缓冲区。
- 每个缓冲区在其缓冲区组内具有唯一的缓冲区 ID（`bid`）。
- 缓冲区组由缓冲区组 ID（`bgid`）标识。

可以同时存在多个缓冲区环，每个环具有不同缓冲区组 ID。操作会指定使用哪个缓冲区组。

### 设置缓冲区环

使用 [io_uring_setup_buf_ring(3)](../man3/io_uring_setup_buf_ring.3.md) 设置缓冲区
环；该函数处理分配、注册和初始化：

```c
struct io_uring_buf_ring *br;
int bgid = 1;  /* 缓冲区组 ID */
int err;

br = io_uring_setup_buf_ring(ring, 128, bgid, 0, &err);
if (!br) {
    fprintf(stderr, "缓冲区环设置失败: %d\n", err);
    return err;
}
```

环的项数必须是 2 的幂，最大为 32768（2^15）。

应用也可以使用
[io_uring_register_buf_ring(3)](../man3/io_uring_register_buf_ring.3.md) 更精细地
控制设置过程，包括使用 `IOU_PBUF_RING_MMAP` 标志由内核分配环。

### 向环添加缓冲区

使用 [io_uring_buf_ring_add(3)](../man3/io_uring_buf_ring_add.3.md) 添加缓冲区，再
通过 [io_uring_buf_ring_advance(3)](../man3/io_uring_buf_ring_advance.3.md) 使其对
内核可见：

```c
int mask = io_uring_buf_ring_mask(128);

for (int i = 0; i < 128; i++) {
    void *buf = malloc(4096);
    io_uring_buf_ring_add(br, buf, 4096, i, mask, i);
}
io_uring_buf_ring_advance(br, 128);
```

每个缓冲区都会分配一个缓冲区 ID（第三个参数）。缓冲区 ID 应在缓冲区组内唯一，但缓冲区
归还后可以复用。

### 在操作中使用提供的缓冲区

要使用提供的缓冲区，请在 SQE 上设置 `IOSQE_BUFFER_SELECT` 并指定缓冲区组 ID：

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_recv(sqe, sockfd, NULL, 4096, 0);
io_uring_sqe_set_flags(sqe, IOSQE_BUFFER_SELECT);
io_uring_sqe_set_buf_group(sqe, bgid);
```

请注意，由于内核将选择缓冲区，`addr` 设置为 `NULL`（或被忽略）；`len` 指定最多接收
多少数据。

支持提供的缓冲区的操作包括 `IORING_OP_READ` / `IORING_OP_RECV`、
`IORING_OP_READV`（仅单个向量）以及 `IORING_OP_RECVMSG`。

### 处理完成事件

使用提供的缓冲区的操作完成时，CQE 会指示使用了哪个缓冲区：

- `cqe->flags` 中设置 `IORING_CQE_F_BUFFER`。
- 缓冲区 ID 位于 `cqe->flags` 高 16 位，可通过
  `cqe->flags >> IORING_CQE_BUFFER_SHIFT` 提取。
- `cqe->res` 包含传输的字节数。

```c
struct io_uring_cqe *cqe;
io_uring_wait_cqe(ring, &cqe);

if (cqe->flags & IORING_CQE_F_BUFFER) {
    int bid = cqe->flags >> IORING_CQE_BUFFER_SHIFT;
    void *buf = buffers[bid];  /* 应用的缓冲区跟踪表 */
    int len = cqe->res;

    /* 处理 buf 中的数据 */
    process_data(buf, len);

    /* 将缓冲区归还到环中以便复用 */
    io_uring_buf_ring_add(br, buf, 4096, bid, mask, 0);
    io_uring_buf_ring_advance(br, 1);
}
io_uring_cqe_seen(ring, cqe);
```

如果操作完成时没有可用缓冲区，操作会以 `-ENOBUFS` 失败。

### 多轮触发操作

提供的缓冲区与
[io_uring_prep_recv_multishot(3)](../man3/io_uring_prep_recv.3.md) 等多轮触发操作
结合使用时尤其强大。单个 SQE 可以生成多个完成事件，每个完成事件从环中消费一个缓冲区：

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_recv_multishot(sqe, sockfd, NULL, 0, 0);
io_uring_sqe_set_flags(sqe, IOSQE_BUFFER_SELECT);
io_uring_sqe_set_buf_group(sqe, bgid);
```

设置了 `IORING_CQE_F_MORE` 的完成事件表示后续还会有完成事件。多轮触发操作会持续到发生
错误、缓冲区环耗尽或操作被取消。

### 增量缓冲区消费

可以使用 `IOU_PBUF_RING_INC` 标志设置缓冲区环，以启用增量消费。在此模式下，大缓冲区
可以跨多次操作部分消费：

- 设置 `IORING_CQE_F_BUF_MORE` 的完成事件表示该缓冲区还将用于更多完成事件。
- 每次完成都从先前停止处继续。
- 仅当缓冲区完全消费或发生错误时才归还。

这适合注册大缓冲区区域并以较小块消费。

### 归还缓冲区

使用完缓冲区后，应通过
[io_uring_buf_ring_add(3)](../man3/io_uring_buf_ring_add.3.md) 将它归还到环中，然后
调用 [io_uring_buf_ring_advance(3)](../man3/io_uring_buf_ring_advance.3.md)。处理多个
CQE 时，为提高效率，可使用
[io_uring_buf_ring_cq_advance(3)](../man3/io_uring_buf_ring_cq_advance.3.md) 在单个
操作中同时推进 CQ 环和缓冲区环。

### 缓冲区环状态

应用可以使用
[io_uring_buf_ring_available(3)](../man3/io_uring_buf_ring_available.3.md) 查询可用
缓冲区数量；它返回内核尚未消费的缓冲区数量。可用
[io_uring_buf_ring_head(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_buf_ring_head.3)
获取当前内核头位置。

### 清理

使用 [io_uring_free_buf_ring(3)](../man3/io_uring_free_buf_ring.3.md) 释放缓冲区环；
该函数会取消注册环并释放环内存（如果环由
[io_uring_setup_buf_ring(3)](../man3/io_uring_setup_buf_ring.3.md) 分配）。应用必须
自行释放各个缓冲区。

## 注意事项

- 缓冲区环项数必须是 2 的幂，最大为 32768。
- 缓冲区 ID 是 16 位值（0-65535）。
- 操作需要缓冲区但没有可用缓冲区时，会以 `-ENOBUFS` 失败；应用应确保环中有足够库存。
- 提供的缓冲区不能与已注册（固定）缓冲区一起使用；它们是独立机制。
- 多轮触发接收应及时归还缓冲区，避免耗尽。

### 旧式提供的缓冲区

较早内核通过 `IORING_OP_PROVIDE_BUFFERS` 和 `IORING_OP_REMOVE_BUFFERS` 支持提供的
缓冲区。该机制需要提交 SQE 来添加或移除缓冲区，增加延迟和开销。上述基于环的机制取代
了此方式，所有新应用都应使用基于环的机制。旧接口仅为向后兼容而保留。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_setup_buf_ring(3)](../man3/io_uring_setup_buf_ring.3.md)
- [io_uring_free_buf_ring(3)](../man3/io_uring_free_buf_ring.3.md)
- [io_uring_register_buf_ring(3)](../man3/io_uring_register_buf_ring.3.md)
- [io_uring_unregister_buf_ring(3)](../man3/io_uring_unregister_buf_ring.3.md)
- [io_uring_buf_ring_add(3)](../man3/io_uring_buf_ring_add.3.md)
- [io_uring_buf_ring_advance(3)](../man3/io_uring_buf_ring_advance.3.md)
- [io_uring_buf_ring_cq_advance(3)](../man3/io_uring_buf_ring_cq_advance.3.md)
- [io_uring_buf_ring_available(3)](../man3/io_uring_buf_ring_available.3.md)
- [io_uring_prep_recv_multishot(3)](../man3/io_uring_prep_recv.3.md)
