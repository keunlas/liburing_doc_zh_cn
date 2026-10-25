---
title: io_uring_registered_buffers
section: 7
source_path: man/io_uring_registered_buffers.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: db72e395ca54145d5419c9e36ff35337921979818fd5894a3a2141ba929b442a
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_registered_buffers(7)

## 名称

io_uring_registered_buffers - io_uring 已注册缓冲区概览

## 描述

已注册缓冲区是 io_uring 的性能优化特性，允许应用预先向内核注册一组缓冲区。注册后，
内核会固定内存并建立长期映射，消除每次 I/O 操作映射和取消映射缓冲区内存的开销。

### 为什么使用已注册缓冲区？

对于每次在用户空间和内核之间传输数据的 I/O 操作，内核必须对缓冲区内存执行若干操作：

- 验证进程可以访问该内存。
- 固定内存页，防止它们被换出。
- 建立访问该内存的内核映射。

这些操作虽然单独执行时很快，但在执行大量小 I/O 时会累积。通过预先注册缓冲区，这些
成本只需支付一次，后续 I/O 操作可以直接使用预先映射的缓冲区。

已注册缓冲区最适合以下应用：执行大量小 I/O；反复复用同一组缓冲区；需要尽可能低的
单次 I/O 开销。

### 注册缓冲区

使用 [io_uring_register_buffers(3)](../man3/io_uring_register_buffers.3.md) 或
[io_uring_register_buffers_tags(3)](../man3/io_uring_register_buffers.3.md) 注册
缓冲区。缓冲区通过 `struct iovec` 数组描述：

```c
struct iovec iovecs[2];
iovecs[0].iov_base = buf1;
iovecs[0].iov_len = 4096;
iovecs[1].iov_base = buf2;
iovecs[1].iov_len = 8192;

ret = io_uring_register_buffers(ring, iovecs, 2);
```

缓冲区必须是匿名内存（通过 `malloc(3)`、带 `MAP_ANONYMOUS` 的 `mmap(2)` 或类似方式
分配）。不支持文件支持的内存。

单个缓冲区上限为 1 GiB。支持大页；即使只使用大页的一部分，整个大页也会被固定。

在 5.12 之前的内核中，缓冲区计入用户的 `RLIMIT_MEMLOCK` 资源限制。5.12 及更高版本并
支持 `IORING_FEAT_NATIVE_WORKERS` 的内核改用 cgroup 内存统计，因此不适用 memlock
限制。

如果不是以 root 运行，且缓冲区注册以 `ENOMEM` 失败，则可能需要提高 memlock 限制。
可以用 `ulimit -l` 检查，使用 `ulimit -l unlimited` 为当前 shell 会话提高限制。永久
修改可编辑 `/etc/security/limits.conf`，或通过
[setrlimit(2)](https://man7.org/linux/man-pages/man2/setrlimit.2.html) 设置
`RLIMIT_MEMLOCK`。

### 使用已注册缓冲区

要在 I/O 操作中使用已注册缓冲区，请使用 prep 函数的固定缓冲区变体：
[io_uring_prep_read_fixed(3)](../man3/io_uring_prep_read_fixed.3.md)、
[io_uring_prep_write_fixed(3)](../man3/io_uring_prep_write_fixed.3.md)、
[io_uring_prep_readv_fixed(3)](../man3/io_uring_prep_readv_fixed.3.md) 和
[io_uring_prep_writev_fixed(3)](../man3/io_uring_prep_writev_fixed.3.md)。

零拷贝发送也可以使用已注册缓冲区：为
[io_uring_prep_send_zc(3)](../man3/io_uring_prep_send_zc.3.md) 或
[io_uring_prep_sendmsg_zc(3)](../man3/io_uring_prep_sendmsg.3.md) 设置
`IORING_RECVSEND_FIXED_BUF`。

这些函数的 `buf_index` 参数指定要使用的已注册缓冲区（对应传给
[io_uring_register_buffers(3)](../man3/io_uring_register_buffers.3.md) 的数组，
从 0 开始）。I/O 使用的内存范围必须位于已注册缓冲区边界内；可以只使用已注册缓冲区的
一部分。

```c
/* 使用已注册缓冲区 0 的前 1024 字节 */
io_uring_prep_read_fixed(sqe, fd, buf1, 1024, offset, 0);

/* 使用已注册缓冲区 1 */
io_uring_prep_write_fixed(sqe, fd, buf2, 2048, offset, 1);
```

### 稀疏缓冲区注册

应用可以使用
[io_uring_register_buffers_sparse(3)](../man3/io_uring_register_buffers.3.md) 注册
稀疏缓冲区表，创建含空槽位的表，之后再通过
[io_uring_register_buffers_update_tag(3)](../man3/io_uring_register_buffers.3.md)
填入。注册时尚不知道完整缓冲区集合的情况下，这很有用。

```c
/* 创建含 10 个槽位的稀疏表 */
ret = io_uring_register_buffers_sparse(ring, 10);

/* 稍后填入槽位 3 */
struct iovec iov = { .iov_base = buf, .iov_len = 4096 };
ret = io_uring_register_buffers_update_tag(ring, 3, &iov, NULL, 1);
```

### 缓冲区标签

使用 [io_uring_register_buffers_tags(3)](../man3/io_uring_register_buffers.3.md) 或
[io_uring_register_buffers_update_tag(3)](../man3/io_uring_register_buffers.3.md) 时，
每个缓冲区可以关联一个标签值。当缓冲区被取消注册（显式取消或替换），并且不再有在途
操作使用该缓冲区时，会发布一个 CQE，其 `user_data` 设置为标签值，其他字段清零。这使
应用能够知道何时可以安全释放或复用缓冲区内存。

### 更新已注册缓冲区

可以使用
[io_uring_register_buffers_update_tag(3)](../man3/io_uring_register_buffers.3.md)
原地更新已注册缓冲区：用新缓冲区替换现有缓冲区、填充稀疏槽位，或将 iovec 长度设为 0
来移除缓冲区。更新不会立即释放资源；旧缓冲区在所有在途操作完成前仍然有效。

### 取消注册缓冲区

使用
[io_uring_unregister_buffers(3)](../man3/io_uring_unregister_buffers.3.md) 取消注册
缓冲区，释放所有已注册缓冲区。io_uring 实例销毁时也会自动取消注册。应用在关闭环前
无需显式取消注册，但解除页固定可能异步发生，因此环销毁后页面可能不会立即可用。

### 克隆缓冲区

可使用
[io_uring_clone_buffers(3)](../man3/io_uring_clone_buffers.3.md) 或
[io_uring_clone_buffers_offset(3)](../man3/io_uring_clone_buffers.3.md) 将一个环的
已注册缓冲区克隆到另一个环，使多个环共享同一组已注册缓冲区而无需重新注册。

## 注意事项

- 对于单次开销显著的小型、频繁 I/O，已注册缓冲区收益最大。
- 大 I/O 的映射开销相对实际 I/O 时间较小，因此收益可能有限。
- 最大已注册缓冲区数量受可用内核内存和（旧内核上的）`RLIMIT_MEMLOCK` 限制。
- 已注册缓冲区不能与使用 `IOSQE_BUFFER_SELECT` 的提供的缓冲区环混用；它们是用于不同
  场景的独立机制。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_registered_files(7)](io_uring_registered_files.7.md)
- [setrlimit(2)](https://man7.org/linux/man-pages/man2/setrlimit.2.html)
- [io_uring_register_buffers(3)](../man3/io_uring_register_buffers.3.md)
- [io_uring_register_buffers_tags(3)](../man3/io_uring_register_buffers.3.md)
- [io_uring_register_buffers_sparse(3)](../man3/io_uring_register_buffers.3.md)
- [io_uring_register_buffers_update_tag(3)](../man3/io_uring_register_buffers.3.md)
- [io_uring_unregister_buffers(3)](../man3/io_uring_unregister_buffers.3.md)
- [io_uring_prep_read_fixed(3)](../man3/io_uring_prep_read_fixed.3.md)
- [io_uring_prep_write_fixed(3)](../man3/io_uring_prep_write_fixed.3.md)
- [io_uring_prep_send_zc(3)](../man3/io_uring_prep_send_zc.3.md)
- [io_uring_prep_sendmsg_zc(3)](../man3/io_uring_prep_sendmsg.3.md)
- [io_uring_clone_buffers(3)](../man3/io_uring_clone_buffers.3.md)
