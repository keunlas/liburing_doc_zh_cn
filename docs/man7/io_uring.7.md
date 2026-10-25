---
title: io_uring
section: 7
source_path: man/io_uring.7
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a7bc666d6993e58c561c7e9cdc968ee3554e5e25cc1268d4167c8861ab83fd3d
source_copyright: "Copyright (C) 2020 Shuveb Hussain <shuveb@gmail.com>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring(7)

## 名称

io_uring - 异步 I/O 设施

## 概要

```c
#include <linux/io_uring.h>
```

## 描述

io_uring 是 Linux 专用的异步 I/O API。它允许用户提交一个或多个 I/O 请求，并在不阻塞
调用进程的情况下异步处理。io_uring 因用户空间与内核空间共享的环形缓冲区而得名。
这种安排可实现高效 I/O，同时尽可能避免在两者之间复制缓冲区的开销。

io_uring 与其他 UNIX I/O API 不同：它不仅使用系统调用在用户空间和内核之间通信，还
将环形缓冲区作为主要通信方式。本手册页将共享缓冲区、共享环形缓冲区和队列视为同义词。

通用编程模型如下：

- 使用 [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
  和 mmap 设置共享缓冲区，将提交队列（SQ）和完成队列（CQ）映射到用户空间。应用将 I/O
  请求放入 SQ，内核将结果放入 CQ。
- 对每个 I/O 请求（读取文件、写入文件、接受套接字连接等），创建提交队列项（SQE），
  描述操作并添加到 SQ 尾部。每个 I/O 操作原则上等价于不使用 io_uring 时原本会执行的
  系统调用。例如，`opcode` 设置为 `IORING_OP_READ` 的 SQE 请求执行类似于
  [read(2)](https://man7.org/linux/man-pages/man2/read.2.html) 的读取。所有支持的操作码
  及属性请参见
  [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)。
- 添加一个或多个 SQE 后，调用 `io_uring_enter(2)` 通知内核从 SQ 取出请求并处理。
- 每个 SQE 处理后，内核会在 CQ 尾部放置一个完成队列事件（CQE）。正常配置下，每个 SQE
  恰好对应一个 CQE。取得 CQE 后，至少应检查 `res`，它对应直接使用等价系统调用时的
  返回值。由于 io_uring 是异步接口，永不使用 `errno` 返回错误：成功时 `res` 包含等价
  系统调用的返回值，出错时包含 `-errno`。
- `io_uring_enter(2)` 还可等待指定数量的请求处理完成。
- I/O 请求可以任意顺序完成。使用环接口时请求按放入顺序尝试，但不表示执行或完成顺序。
  当多个请求在途时，无法确定哪个先执行或完成。取出 CQE 时应始终检查它对应哪个请求；
  最常用方法是 `user_data` 字段，它会在完成端原样返回。
- 对于需要严格顺序的操作（例如面向流的 TCP 套接字发送和接收），通常不宜同时在同一个
  套接字上保留多个发送或多个接收（两个方向相互独立），因为内核在设置 poll 或其他后台
  活动时可能重排执行。单批提交时可用 `IOSQE_IO_LINK` 强制执行顺序；其他情况下可使用
  多轮触发和发送/接收捆绑等高级特性，但仍须确保同一文件上的发送或接收不重叠。

队列操作：

- 应用将 SQE 添加到 SQ 尾部，内核从 SQ 头部读取。
- 内核将 CQE 添加到 CQ 尾部，应用从 CQ 头部读取。

根据配置，行为可能偏离上述模型。例如，`IOSQE_CQE_SKIP_SUCCESS` 可让成功的 SQE 不
发布 CQE；多轮触发操作可为单个 SQE 发布多个 CQE；使用提交队列轮询时仍可能需要
`io_uring_enter(2)` 让内核开始处理新 SQE。

### 提交队列轮询

io_uring 支持轮询模式，以避免调用 `io_uring_enter(2)` 通知内核有新 SQE。启用 SQ Polling
后，内核线程会轮询提交队列并处理应用添加的 SQE，从而避免系统调用开销。

### 设置 io_uring

设置 io_uring 的主要步骤是通过 mmap 映射共享缓冲区。本例中的 `app_setup_uring()`
使用 `QUEUE_DEPTH` 深度的提交队列。注意两个 mmap 调用分别设置共享 SQ 和 CQ；内核低于
5.4 时需要三个 mmap 调用。

### 提交 I/O 请求

提交请求时，用 `io_uring_sqe` 描述操作及其等价系统调用参数。由于 Linux 支持多种 I/O
操作，该结构体有多个字段，部分字段通过联合体节省空间。常用字段如下：

```c
struct io_uring_sqe {
        __u8    opcode;         /* type of operation for this sqe */
        __s32   fd;             /* file descriptor to do IO on */
        __u64   off;            /* offset into file */
        __u64   addr;           /* pointer to buffer or iovecs */
        __u32   len;            /* buffer size or number of iovecs */
        __u64   user_data;      /* data to be passed back at completion time */
        __u8    flags;          /* IOSQE_ flags */
        ...
};
```

完整结构体如下：

```c
struct io_uring_sqe {
	__u8	opcode;
	__u8	flags;
	__u16	ioprio;
	__s32	fd;
	union {
		__u64	off;
		__u64	addr2;
		struct {
			__u32	cmd_op;
			__u32	__pad1;
		};
	};
	union {
		__u64	addr;
		__u64	splice_off_in;
		struct {
			__u32	level;
			__u32	optname;
		};
	};
	__u32	len;
	union {
		__kernel_rwf_t	rw_flags;
		__u32		fsync_flags;
		__u16		poll_events;
		__u32		poll32_events;
		__u32		sync_range_flags;
		__u32		msg_flags;
		__u32		timeout_flags;
		__u32		accept_flags;
		__u32		cancel_flags;
		__u32		open_flags;
		__u32		statx_flags;
		__u32		fadvise_advice;
		__u32		splice_flags;
		__u32		rename_flags;
		__u32		unlink_flags;
		__u32		hardlink_flags;
		__u32		xattr_flags;
		__u32		msg_ring_flags;
		__u32		uring_cmd_flags;
		__u32		waitid_flags;
		__u32		futex_flags;
		__u32		install_fd_flags;
		__u32		nop_flags;
	};
	__u64	user_data;
	union {
		__u16	buf_index;
		__u16	buf_group;
	} __attribute__((packed));
	__u16	personality;
	union {
		__s32	splice_fd_in;
		__u32	file_index;
		__u32	optlen;
		struct {
			__u16	addr_len;
			__u16	__pad3[1];
		};
	};
	union {
		struct {
			__u64	addr3;
			__u64	__pad2[1];
		};
		__u64	optval;
		__u8	cmd[0];
	};
};
```

要提交请求，从 SQ 获取 SQE、填写操作详情并调用 `io_uring_enter(2)`。`io_uring_prep_X`
形式的辅助函数可正确设置 SQE。要避免 `io_uring_enter(2)`，可使用提交队列轮询。

SQE 添加到 SQ 尾部，内核从头部取得。获取下一 SQE 并更新尾部的算法如下：

```c
struct io_uring_sqe *sqe;
unsigned tail, index;
tail = *sqring->tail;
index = tail & (*sqring->ring_mask);
sqe = &sqring->sqes[index];
describe_io(sqe);
sqring->array[index] = index;
tail++;
atomic_store_explicit(sqring->tail, tail, memory_order_release);
```

应用必须用环大小掩码对当前尾部索引取掩码。SQ 和 CQ 均如此。提交侧在 SQ 环与 SQE
数组之间还有一层间接索引数组。

例如，等价于
[preadv2(2)](https://man7.org/linux/man-pages/man2/preadv2.2.html)
的读取可这样填写：

```c
struct iovec iovecs[16];
 ...
sqe->opcode = IORING_OP_READV;
sqe->fd = fd;
sqe->addr = (unsigned long) iovecs;
sqe->len = 16;
sqe->off = offset;
sqe->flags = 0;
```

**内存顺序**：现代编译器和 CPU 可重排读写。io_uring 缓冲区同时可被内核和用户空间
修改，因此头尾更新必须在两侧一致可见。内存屏障保证这种一致性，细节超出本手册页范围。

**通知内核提交**：添加 SQE 后调用 `io_uring_enter(2)`，该调用还可等待指定数量的事件。

### SQE 指针生命周期与数据稳定性

由于 SQE 大小固定，一些操作数据通过指针而不是值传入。在后续
`io_uring_enter(2)` 调用完成后即可释放该内存，因为操作仅在提交时需要它。

未启用 `IORING_SETUP_SQPOLL` 时，这一步在调用 `io_uring_submit(3)` 时完成。启用
`IORING_SETUP_SQPOLL` 时，必须确保所有提供的指针保持有效直到完成。5.4 及更早的早期
内核无论何种情况都要求状态保持到完成；应用可检查 `IORING_FEAT_SUBMIT_STABLE`。

例如，`IORING_OP_TIMEOUT` 接收 `__kernel_timespec` 指针，内核在提交时读取；之后即可
释放。此规则不适用于操作在途期间读写的缓冲区，例如 `IORING_OP_WRITE` 或
`IORING_OP_READ` 的缓冲区必须保持有效直到完成。

### 读取完成事件

CQ 同样是内核和用户空间共享的缓冲区。内核将 CQE 放在尾部，应用从头部读取。完成结构
比提交结构简单：

```c
struct io_uring_cqe {
	__u64	user_data;  /* sqe->data submission passed back */
	__s32	res;        /* result code for this event */
	__u32	flags;
};
```

`user_data` 从提交原样传到完成，可用于关联提交与完成。`res` 是等价系统调用的返回值。
`flags` 携带请求特定信息。截至 6.12 内核，定义了以下标志：

- `IORING_CQE_F_BUFFER`：flags 高 16 位携带所选缓冲区 ID。请求必须设置
  `IOSQE_BUFFER_SELECT`，且使用支持缓冲区选择的类型；缓冲区必须事先通过
  `IORING_OP_PROVIDE_BUFFERS` 或 `IORING_REGISTER_PBUF_RING` 提供。
- `IORING_CQE_F_MORE`：应用应预期该请求还会产生更多完成事件，例如多轮触发接收或
  accept。
- `IORING_CQE_F_SOCK_NONEMPTY`：本次从套接字接收数据后，完成时套接字仍有数据。
- `IORING_CQE_F_NOTIF`：通知 CQE，出现在零拷贝网络发送和接收支持中。
- `IORING_CQE_F_BUF_MORE`：完成中使用的缓冲区还会有更多完成，表示缓冲区已部分消费。
  仅当提供的缓冲区环使用 `IOU_PBUF_RING_INC` 时出现。
- `IORING_CQE_F_SKIP`：在 `IORING_SETUP_CQE_MIXED` 环中，为放置 32 字节 CQE 而发布的
  填充 CQE；应用应直接跳过并忽略。
- `IORING_CQE_F_32`：在混合 CQE 环中表示当前 CQE 为 32 字节，下一 CQE 需要多推进一个
  槽位。

读取 CQ 的一般序列：

```c
unsigned head;
head = *cqring->head;
if (head != atomic_load_acquire(cqring->tail)) {
    struct io_uring_cqe *cqe;
    unsigned index;
    index = head & (cqring->mask);
    cqe = &cqring->cqes[index];
    process_cqe(cqe);
    head++;
}
atomic_store_explicit(cqring->head, head, memory_order_release);
```

内核向 CQ 尾部添加 CQE，应用从头部取出。必须对头索引取掩码，并在消费后更新头部；同时
注意读写屏障。

### io_uring 性能

由于内核和用户空间共享环形缓冲区，io_uring 可实现零拷贝：通信通过共享缓冲区完成，
避免大量数据传输系统调用的复制开销。io_uring 还可将多个请求批量放入多个 SQE，一次
`io_uring_enter(2)` 提交。提交队列轮询又能进一步消除提交系统调用。

## 标准

io_uring 是 Linux 专用接口。

## 示例

以下示例使用 io_uring 将标准输入复制到标准输出。它仅使用深度为 1 的队列，以便理解；
真实场景应增大队列深度以并行处理请求。

```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <sys/mman.h>
#include <sys/uio.h>
#include <linux/fs.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdatomic.h>
#include <errno.h>

#include <linux/io_uring.h>

#define QUEUE_DEPTH 1
#define BLOCK_SZ    1024

/* io_uring 所需屏障宏 */
#define io_uring_smp_store_release(p, v)            \
    atomic_store_explicit((_Atomic typeof(*(p)) *)(p), (v), \
                  memory_order_release)
#define io_uring_smp_load_acquire(p)                \
    atomic_load_explicit((_Atomic typeof(*(p)) *)(p),   \
                 memory_order_acquire)

int ring_fd;
unsigned *sring_tail, *sring_mask, *sring_array,
            *cring_head, *cring_tail, *cring_mask;
struct io_uring_sqe *sqes;
struct io_uring_cqe *cqes;
char buff[BLOCK_SZ];
off_t offset;

/* 由于 glibc 尚未提供 io_uring 系统调用包装，提供以下包装函数 */
int io_uring_setup(unsigned entries, struct io_uring_params *p)
{
    int ret;
    ret = syscall(__NR_io_uring_setup, entries, p);
    return (ret < 0) ? -errno : ret;
}

int io_uring_enter(int ring_fd, unsigned int to_submit,
                   unsigned int min_complete, unsigned int flags)
{
    int ret;
    ret = syscall(__NR_io_uring_enter, ring_fd, to_submit,
                  min_complete, flags, NULL, 0);
    return (ret < 0) ? -errno : ret;
}

int app_setup_uring(void) {
    struct io_uring_params p;
    void *sq_ptr, *cq_ptr;

    memset(&p, 0, sizeof(p));
    ring_fd = io_uring_setup(QUEUE_DEPTH, &p);
    if (ring_fd < 0) {
        perror("io_uring_setup");
        return 1;
    }

    int sring_sz = p.sq_off.array + p.sq_entries * sizeof(unsigned);
    int cring_sz = p.cq_off.cqes + p.cq_entries * sizeof(struct io_uring_cqe);

    if (p.features & IORING_FEAT_SINGLE_MMAP) {
        if (cring_sz > sring_sz)
            sring_sz = cring_sz;
        cring_sz = sring_sz;
    }

    sq_ptr = mmap(0, sring_sz, PROT_READ | PROT_WRITE,
                  MAP_SHARED | MAP_POPULATE,
                  ring_fd, IORING_OFF_SQ_RING);
    if (sq_ptr == MAP_FAILED) {
        perror("mmap");
        return 1;
    }

    if (p.features & IORING_FEAT_SINGLE_MMAP) {
        cq_ptr = sq_ptr;
    } else {
        cq_ptr = mmap(0, cring_sz, PROT_READ | PROT_WRITE,
                      MAP_SHARED | MAP_POPULATE,
                      ring_fd, IORING_OFF_CQ_RING);
        if (cq_ptr == MAP_FAILED) {
            perror("mmap");
            return 1;
        }
    }
    sring_tail = sq_ptr + p.sq_off.tail;
    sring_mask = sq_ptr + p.sq_off.ring_mask;
    sring_array = sq_ptr + p.sq_off.array;

    sqes = mmap(0, p.sq_entries * sizeof(struct io_uring_sqe),
                   PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE,
                   ring_fd, IORING_OFF_SQES);
    if (sqes == MAP_FAILED) {
        perror("mmap");
        return 1;
    }

    cring_head = cq_ptr + p.cq_off.head;
    cring_tail = cq_ptr + p.cq_off.tail;
    cring_mask = cq_ptr + p.cq_off.ring_mask;
    cqes = cq_ptr + p.cq_off.cqes;

    return 0;
}

int read_from_cq() {
    struct io_uring_cqe *cqe;
    unsigned head;

    head = io_uring_smp_load_acquire(cring_head);
    if (head == *cring_tail)
        return -1;

    cqe = &cqes[head & (*cring_mask)];
    if (cqe->res < 0)
        fprintf(stderr, "Error: %s\n", strerror(abs(cqe->res)));

    head++;
    io_uring_smp_store_release(cring_head, head);

    return cqe->res;
}

int submit_to_sq(int fd, int op) {
    unsigned index, tail;

    tail = *sring_tail;
    index = tail & *sring_mask;
    struct io_uring_sqe *sqe = &sqes[index];
    sqe->opcode = op;
    sqe->fd = fd;
    sqe->addr = (unsigned long) buff;
    if (op == IORING_OP_READ) {
        memset(buff, 0, sizeof(buff));
        sqe->len = BLOCK_SZ;
    }
    else {
        sqe->len = strlen(buff);
    }
    sqe->off = offset;

    sring_array[index] = index;
    tail++;
    io_uring_smp_store_release(sring_tail, tail);

    int ret = io_uring_enter(ring_fd, 1, 1,
                             IORING_ENTER_GETEVENTS);
    if(ret < 0) {
        perror("io_uring_enter");
        return -1;
    }

    return ret;
}

int main(int argc, char *argv[]) {
    int res;

    if(app_setup_uring()) {
        fprintf(stderr, "Unable to setup uring!\n");
        return 1;
    }

    while (1) {
        submit_to_sq(STDIN_FILENO, IORING_OP_READ);
        res = read_from_cq();
        if (res > 0) {
            submit_to_sq(STDOUT_FILENO, IORING_OP_WRITE);
            read_from_cq();
        } else if (res == 0) {
            break;
        }
        else if (res < 0) {
            fprintf(stderr, "Error: %s\n", strerror(abs(res)));
            break;
        }
        offset += res;
    }

    return 0;
}
```

## 参见

- [io_uring_enter(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_enter.2)
- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
