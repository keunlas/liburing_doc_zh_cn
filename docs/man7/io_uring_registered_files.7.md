---
title: io_uring_registered_files
section: 7
source_path: man/io_uring_registered_files.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: 6cfae7d416d4aae1258446b49d7751ccf90db014aeaedc9914b8a844e0b7b726
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_registered_files(7)

## 名称

io_uring_registered_files - io_uring 已注册文件概览

## 描述

已注册文件（也称为固定文件）是 io_uring 的性能优化特性，允许应用预先向内核注册一组
文件描述符。文件注册后，内核会持有每个文件的引用，从而避免每次 I/O 操作都查找文件
描述符并获取引用。

### 为什么使用已注册文件？

对于每次使用文件描述符的 I/O 操作，内核必须：

- 在进程文件描述符表中查找文件描述符。
- 获取文件引用，确保其在操作期间保持有效。
- 在操作完成后释放引用。

对于执行大量 I/O 操作的应用，尤其是文件表被共享、引用计数成本更高的多线程应用，这些
开销会累积。通过一次性注册文件，引用会在注册生命周期内持续持有，操作可以直接使用文件，
无需每次查找或引用计数。

已注册文件最适合以下应用：

- 对同一组文件执行大量 I/O 操作。
- 是多线程的（文件表操作成本更高）。
- 需要尽可能低的单次 I/O 开销。

### 注册文件

使用 [io_uring_register_files(3)](../man3/io_uring_register_files.3.md) 或
[io_uring_register_files_tags(3)](../man3/io_uring_register_files.3.md) 注册文件。
文件通过文件描述符数组描述：

```c
int fds[3];
fds[0] = open("file1", O_RDONLY);
fds[1] = open("file2", O_RDONLY);
fds[2] = open("file3", O_WRONLY | O_CREAT, 0644);

ret = io_uring_register_files(ring, fds, 3);
```

注册后，如果需要，可以关闭原始文件描述符。内核持有其对底层文件的引用。

### 使用已注册文件

要在 I/O 操作中使用已注册文件，请在 SQE 的 `flags` 字段中设置 `IOSQE_FIXED_FILE`，
并在 `fd` 字段中使用已注册文件数组的索引（而不是原始文件描述符）：

```c
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_read(sqe, 0, buf, len, offset);  /* 索引 0，而不是 fd */
io_uring_sqe_set_flags(sqe, IOSQE_FIXED_FILE);
```

索引从 0 开始，对应传给 [io_uring_register_files(3)](../man3/io_uring_register_files.3.md)
的数组。

### 稀疏文件注册

文件数组可以是稀疏的，即某些槽位可以为空。空的槽位通过将文件描述符设置为 -1 表示。
应用可以使用
[io_uring_register_files_sparse(3)](../man3/io_uring_register_files.3.md)
创建完全稀疏的表，之后再填入槽位：

```c
/* 创建含 100 个槽位的稀疏表 */
ret = io_uring_register_files_sparse(ring, 100);

/* 稍后填入槽位 5 */
int fd = open("file", O_RDONLY);
ret = io_uring_register_files_update(ring, 5, &fd, 1);
```

### 更新已注册文件

可使用 [io_uring_register_files_update(3)](../man3/io_uring_register_files.3.md) 或
[io_uring_register_files_update_tag(3)](../man3/io_uring_register_files.3.md) 更新已
注册文件。这些操作可以：

- 用新文件替换现有文件。
- 填充空槽位。
- 将描述符设置为 -1 来移除文件。

要跳过某些槽位并更新其他槽位，请使用特殊值 `IORING_REGISTER_FILES_SKIP`。

```c
int fds[3];
fds[0] = new_fd;                        /* 替换槽位 0 */
fds[1] = IORING_REGISTER_FILES_SKIP;    /* 保持槽位 1 不变 */
fds[2] = -1;                            /* 移除槽位 2 */

ret = io_uring_register_files_update(ring, 0, fds, 3);
```

在 5.13 及更高版本内核中，更新不要求环处于空闲状态。在较旧内核中，更新会等待在途操作
完成。

### 文件标签

使用 [io_uring_register_files_tags(3)](../man3/io_uring_register_files.3.md) 或
[io_uring_register_files_update_tag(3)](../man3/io_uring_register_files.3.md) 时，每个
文件都可以关联一个标签值。当文件被取消注册（显式取消或替换），并且不再有在途操作使用
该文件时，会发布一个完成队列项，其 `user_data` 设置为标签值，其他字段清零。

这种通知机制使应用能够知道何时可以安全执行与该文件关联的清理操作。

### 直接文件描述符

某些 io_uring 操作可以直接将文件描述符分配到已注册文件表，从而完全避开常规文件描述符
表。这可以通过
[io_uring_sqe_set_target_fixed_file(3)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_sqe_set_target_fixed_file.3)
将 SQE 的 `file_index` 字段设置为所需槽位，或者使用 `IORING_FILE_INDEX_ALLOC` 让
io_uring 分配下一个可用槽位。

支持直接描述符的操作包括：

- `IORING_OP_OPENAT` / `IORING_OP_OPENAT2`
- `IORING_OP_ACCEPT`
- `IORING_OP_SOCKET`
- `IORING_OP_PIPE`

使用 `IORING_FILE_INDEX_ALLOC` 时，应用应使用
[io_uring_register_file_alloc_range(3)](../man3/io_uring_register_file_alloc_range.3.md)
指定文件表中用于分配的“范围”。

```c
/* 预留槽位 50-99 用于动态分配 */
io_uring_register_file_alloc_range(ring, 50, 50);

/* 使用直接描述符分配执行 accept */
struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
io_uring_prep_accept_direct(sqe, listen_fd, NULL, NULL, 0,
                            IORING_FILE_INDEX_ALLOC);
```

成功时，分配的槽位索引会在 CQE 的 `res` 字段中返回。

### 关闭直接描述符

直接描述符（仅存在于已注册文件表中的文件）可以通过在 `IORING_OP_CLOSE` 中设置
`IOSQE_FIXED_FILE` 标志来关闭，也可以通过
[io_uring_register_files_update(3)](../man3/io_uring_register_files.3.md) 将槽位更新为
-1 来关闭。

### 取消注册文件

使用 [io_uring_unregister_files(3)](../man3/io_uring_unregister_files.3.md) 取消注册
文件。这会释放所有已注册文件。io_uring 实例销毁时也会自动取消注册文件。

应用在关闭环之前不需要显式取消注册文件。

## 注意事项

- 对于对同一文件执行大量操作的应用，尤其是多线程应用，已注册文件收益最大。
- 直接描述符（仅存在于已注册表中的文件）对 io_uring 之外的操作（如
  [read(2)](https://man7.org/linux/man-pages/man2/read.2.html) 或
  [write(2)](https://man7.org/linux/man-pages/man2/write.2.html)）不可见。
- 使用已注册文件索引时必须设置 `IOSQE_FIXED_FILE` 标志；否则 `fd` 字段会被解释为
  普通文件描述符。
- 将 `IOSQE_FIXED_FILE` 与不对应任何已注册文件的索引一起使用是错误的。

## 参见

- [io_uring(7)](io_uring.7.md)
- [io_uring_registered_buffers(7)](io_uring_registered_buffers.7.md)
- [io_uring_register_files(3)](../man3/io_uring_register_files.3.md)
- [io_uring_register_files_tags(3)](../man3/io_uring_register_files.3.md)
- [io_uring_register_files_sparse(3)](../man3/io_uring_register_files.3.md)
- [io_uring_register_files_update(3)](../man3/io_uring_register_files.3.md)
- [io_uring_register_files_update_tag(3)](../man3/io_uring_register_files.3.md)
- [io_uring_unregister_files(3)](../man3/io_uring_unregister_files.3.md)
- [io_uring_register_file_alloc_range(3)](../man3/io_uring_register_file_alloc_range.3.md)
