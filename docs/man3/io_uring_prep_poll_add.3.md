---
title: io_uring_prep_poll_add
section: 3
source_path: man/io_uring_prep_poll_add.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: e54aa55f4847fbc78c43a8de54da4839ef8e210cbfaa159192422c1b083272eb
source_copyright: "Copyright (C) 2022 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_prep_poll_add(3)

## 名称

io_uring_prep_poll_add - 准备一个 poll 请求

## 概要

```c
#include <poll.h>
#include <liburing.h>

void io_uring_prep_poll_add(struct io_uring_sqe *sqe,
                            int fd,
                            unsigned poll_mask);

void io_uring_prep_poll_multishot(struct io_uring_sqe *sqe,
                                  int fd,
                                  unsigned poll_mask);
```

## 描述

[io_uring_prep_poll_add(3)](io_uring_prep_poll_add.3.md) 函数准备一个 poll 请求。
提交队列项 `sqe` 会被设置为轮询文件描述符 `fd`，所需事件由 `poll_mask` 参数指定。

默认行为是单次触发 poll 请求。指定事件触发后，会发布一个完成 CQE，该 poll 请求不会
再生成更多事件。[io_uring_prep_poll_multishot(3)](io_uring_prep_poll_add.3.md) 在事件
方面行为相同，但它会跨多次通知持续存在，并对同一注册反复发布通知。多轮触发 poll
请求发布的 CQE 会在 CQE 的 `flags` 成员中设置 `IORING_CQE_F_MORE`，表示应用应预期
该请求还会产生更多完成事件。如果多轮触发 poll 请求被终止或遇到错误，则 CQE 中不会
设置该标志。如果发生这种情况，应用不应再预期原请求产生更多 CQE；如果仍希望获取该
文件描述符上的通知，就必须重新发出一个新请求。

## 返回值

无。

## 错误

CQE 的 `res` 字段会包含操作结果，即已通知事件的位掩码。详情请参见
[poll(2)](https://man7.org/linux/man-pages/man2/poll.2.html) 手册页。请注意，同步
系统调用失败时会返回 `-1`，并将 `errno` 设置为实际错误值；io_uring 从不使用
`errno`，而是直接在 CQE 的 `res` 字段中返回取负后的 `errno`。

## 参见

- [io_uring_get_sqe(3)](io_uring_get_sqe.3.md)
- [io_uring_submit(3)](io_uring_submit.3.md)
- [poll(2)](https://man7.org/linux/man-pages/man2/poll.2.html)
- [epoll_ctl(3)](https://man7.org/linux/man-pages/man2/epoll_ctl.2.html)
