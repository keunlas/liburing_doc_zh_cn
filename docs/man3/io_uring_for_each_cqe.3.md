---
title: io_uring_for_each_cqe
section: 3
source_path: man/io_uring_for_each_cqe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: cfc5814052117d173bd3510452556254f774096aa31b4d6c2a1827bce6bb1dc2
source_copyright: "Copyright (C) 2023 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_for_each_cqe(3)

## 名称

io_uring_for_each_cqe - 遍历待处理的完成事件

## 概要

```c
#include <liburing.h>

io_uring_for_each_cqe(struct io_uring *ring,
                      unsigned head,
                      struct io_uring_cqe *cqe) { }
```

## 描述

[io_uring_for_each_cqe(3)](io_uring_for_each_cqe.3.md) 是一个宏辅助工具，它使用
`head` 作为临时迭代器遍历 `ring` 所属的完成事件，并在迭代时将 `cqe` 指向每个待处理
事件。

此辅助工具提供了一种高效遍历环中所有待处理事件的方式；遍历完成后，使用所消费的 CQ
环槽位数量调用
[io_uring_cq_advance(3)](io_uring_cq_advance.3.md) 来推进 CQ 环。该槽位数量是所见到
各 CQE 的
[io_uring_cqe_nr(3)](io_uring_cqe_nr.3.md) 之和，因为在使用
`IORING_SETUP_CQE_MIXED` 设置的环上，32 字节 CQE 会占用两个槽位。由于更新内核可见的
CQ 环状态涉及有序写入，因此对多个事件只执行一次该写入，比逐个处理每个完成事件并对
其调用 [io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md) 更高效。

## 示例

```c
void handle_cqes(struct io_uring *ring)
{
	struct io_uring_cqe *cqe;
	unsigned head;
	unsigned nr = 0;

	io_uring_for_each_cqe(ring, head, cqe) {
		/* 处理完成事件 */
		printf("cqe: %d\n", cqe->res);
		nr += io_uring_cqe_nr(cqe);
	}

	io_uring_cq_advance(ring, nr);
}
```

## 返回值

无。

## 参见

- [io_uring_wait_cqe_timeout(3)](io_uring_wait_cqe_timeout.3.md)
- [io_uring_wait_cqe(3)](io_uring_wait_cqe.3.md)
- [io_uring_wait_cqes(3)](io_uring_wait_cqes.3.md)
- [io_uring_cqe_seen(3)](io_uring_cqe_seen.3.md)
- [io_uring_cqe_nr(3)](io_uring_cqe_nr.3.md)
- [io_uring_buf_ring_cq_advance(3)](io_uring_buf_ring_cq_advance.3.md)
