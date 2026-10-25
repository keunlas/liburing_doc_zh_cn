---
title: io_uring_enter
section: 2
source_path: man/io_uring_enter.2
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: a21d24b9aa05a72647e6b4ba3d39d617b8dffa4ba4d595d8a3a6a1c6e4a80189
source_copyright: "Copyright (C) 2019 Jens Axboe <axboe@kernel.dk>; Copyright (C) 2019 Red Hat, Inc."
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_enter(2)

## 名称

io_uring_enter - 发起和/或完成异步 I/O

## 概要

```c
#include <liburing.h>

int io_uring_enter(unsigned int fd, unsigned int to_submit,
                   unsigned int min_complete, unsigned int flags,
                   sigset_t *sig);

int io_uring_enter2(unsigned int fd, unsigned int to_submit,
                    unsigned int min_complete, unsigned int flags,
                    void *arg, size_t sz);
```

## 描述

[io_uring_enter(2)](io_uring_enter.2.md) 使用
[io_uring_setup(2)](io_uring_setup.2.md) 创建的共享提交队列和完成队列发起并完成
I/O。一次调用既可提交新 I/O，也可等待本次或先前调用发起的 I/O 完成。

`fd` 是 setup 返回的文件描述符；`to_submit` 指定从提交队列提交的 I/O 数量。`flags`
可以是：

- `IORING_ENTER_GETEVENTS`：返回前等待 `min_complete` 个事件。可与 `to_submit`
  结合。若设置了 `IORING_SETUP_DEFER_TASKRUN`，调用线程必须是最初创建环的线程，或通过
  `io_uring_register(2)`/`io_uring_enable_rings(3)` 启用由
  `IORING_SETUP_R_DISABLED` 创建的环的线程。
- `IORING_ENTER_SQ_WAKEUP`：对设置了 `IORING_SETUP_SQPOLL` 的环唤醒 SQ 内核线程来提交
  I/O。
- `IORING_ENTER_SQ_WAIT`：等待 SQ 环至少有一个空闲项，适用于
  `IORING_SETUP_SQPOLL` 环。
- `IORING_ENTER_EXT_ARG`：自 5.11 起，`arg` 不再指向 `sigset_t`，而指向
  `struct io_uring_getevents_arg`，`argsz` 为结构大小：

```c
struct io_uring_getevents_arg {
        __u64   sigmask;
        __u32   sigmask_sz;
        __u32   pad;
        __u64   ts;
};
```

  `ts` 是 `struct __kernel_timespec` 超时指针；应用可借此限时等待。
- `IORING_ENTER_REGISTERED_RING`：通过 `IORING_REGISTER_RING_FDS` 注册环后，表示
  `ring_fd` 是注册偏移而非普通 fd。
- `IORING_ENTER_ABS_TIMER`：自 6.12 起，将扩展参数中的超时解释为已注册时钟
  （参见 `IORING_REGISTER_CLOCK`）的绝对时间。
- `IORING_ENTER_EXT_ARG_REG`：自 6.13 起，`arg` 是先前通过
  `IORING_REGISTER_MEM_REGION` 注册的等待区域偏移，而不是指针。
- `IORING_ENTER_NO_IOWAIT`：自 6.15 起，不把有在途请求的休眠等待任务标记为 iowait；
  要求 `IORING_FEAT_NO_IOWAIT`。

对 `IORING_SETUP_IOPOLL` 环，`min_complete=0` 表示不阻塞地返回已经完成的事件；非零时
若有完成事件也立即返回，否则忙轮询到一个或多个完成或进程耗尽调度时间片。未使用
`IORING_SETUP_IOPOLL` 的应用可完全不进入内核而直接检查 CQ。

系统调用报告已消费并提交一定数量 SQE 后，应用即可复用这些 SQE 项，即使实际 I/O 被交给
异步上下文且尚未提交；内核会在需要时保留私有副本。

`sig` 是信号掩码指针。若非 NULL，系统调用先以其替换当前掩码、等待完成队列事件，再恢复
原掩码，等价于原子执行：

```c
pthread_sigmask(SIG_SETMASK, &sig, &orig);
ret = io_uring_enter(fd, 0, 1, IORING_ENTER_GETEVENTS, NULL);
pthread_sigmask(SIG_SETMASK, &orig, NULL);
```

提交队列项结构如下：

```c
struct io_uring_sqe {
	__u8	opcode;		/* type of operation for this sqe */
	__u8	flags;		/* IOSQE_ flags */
	__u16	ioprio;		/* ioprio for the request */
	__s32	fd;		/* file descriptor to do IO on */
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
		/* 使用 IORING_SETUP_SQE128 时，此处可存放 80 字节命令数据 */
		__u8	cmd[0];
	};
};
```

支持的 `opcode` 如下：

- `IORING_OP_NOP`：不执行 I/O，用于测试 io_uring 自身性能。
- `IORING_OP_READV` / `IORING_OP_WRITEV`：向量读写，类似 preadv2/pwritev2；不可寻址文件
  的 `off` 必须为 0 或 -1。
- `IORING_OP_READ_FIXED` / `IORING_OP_WRITE_FIXED`：对预先映射的固定缓冲区读写。
- `IORING_OP_FSYNC`：文件同步；`off`/`len` 可选择同步范围。I/O 发起顺序不等于完成
  顺序，因此同批中的 fsync 不保证覆盖先前写；需要顺序时应使用链接 SQE、
  `IOSQE_IO_DRAIN` 或先等待先前 CQE。
- `IORING_OP_POLL_ADD`：轮询 `fd` 的 `poll_events`。默认单次触发；若 `len` 设置
  `IORING_POLL_ADD_MULTI`，则多轮触发，CQE 设置 `IORING_CQE_F_MORE` 表示继续。首次
  完成是水平触发，之后为边沿触发；自 5.13 起支持多轮触发。结果 `res` 是事件掩码。
- `IORING_OP_POLL_REMOVE`：删除或更新轮询。找到时 `res=0`，否则 `-ENOENT`，正在完成
  则 `-EALREADY`。`len` 中 `IORING_POLL_UPDATE_EVENTS` 按原 SQE 的 `user_data`（在
  `addr` 传入）更新事件；`IORING_POLL_UPDATE_USER_DATA` 按 `off` 更新 user_data。
  自 5.13 起支持更新。
- `IORING_OP_EPOLL_CTL`：自 5.6 起，等价于 epoll_ctl；`fd` 为 epoll 实例，`off` 为
  目标 fd，`len` 为 ADD/DEL/MOD，`addr` 指向 `epoll_event`。
- `IORING_OP_SYNC_FILE_RANGE`：自 5.2 起，等价于 sync_file_range；`fd`、`off`、`len`
  和 `sync_range_flags` 对应参数。
- `IORING_OP_SENDMSG`：自 5.3 起，等价于 sendmsg；`addr` 指向 `msghdr`，
  `msg_flags` 为标志。`ioprio` 支持 `IORING_RECVSEND_POLL_FIRST`，假定套接字已满并先
  设置轮询。
- `IORING_OP_RECVMSG`：自 5.3 起，等价于 recvmsg；参数同上，`IORING_RECVSEND_POLL_FIRST`
  假定套接字为空并先设置轮询。
- `IORING_OP_SEND` / `IORING_OP_RECV`：自 5.6 起，分别等价于 send/recv；`fd`、`addr`、
  `len`、`msg_flags` 对应参数，并支持 `IORING_RECVSEND_POLL_FIRST`。
- `IORING_OP_TIMEOUT`：自 5.4 起。`addr` 指向 timespec，`len=1`，`off` 为完成事件数，
  `timeout_flags` 支持 `IORING_TIMEOUT_ABS`；到期或事件数满足时唤醒，`off=0` 则只计时。
  默认 `CLOCK_MONOTONIC`。到期返回 `-ETIME`，因事件数完成返回 0，取消返回
  `-ECANCELED`。5.15 起支持 `IORING_TIMEOUT_BOOTTIME`、
  `IORING_TIMEOUT_REALTIME`；5.16 起支持 `IORING_TIMEOUT_ETIME_SUCCESS`；6.4 起支持
  `IORING_TIMEOUT_MULTISHOT`（不得与 ABS 并用）；7.1 起
  `IORING_TIMEOUT_IMMEDIATE_ARG` 将 `addr` 直接解释为纳秒值。
- `IORING_OP_TIMEOUT_REMOVE`：自 5.5 起。`timeout_flags=0` 时按 `addr` 中的 user_data
  删除超时：成功 0，正在到期 `-EBUSY`，未找到 `-ENOENT`。若设置
  `IORING_TIMEOUT_UPDATE`（5.11 起），`addr2` 指向新 timespec，并可带 ABS。
- `IORING_OP_ACCEPT`：自 5.5 起，等价于 accept4；`fd` 为套接字，`addr` 为 sockaddr，
  `addr2` 为 addrlen，`accept_flags` 为标志。正数 `file_index` 安装到固定文件表索引
  `file_index - 1`，成功返回 0；已占用槽位会像 FILES_UPDATE 一样替换；使用前应通过
  `IORING_REGISTER_FILES` 注册文件表。
- `IORING_OP_ASYNC_CANCEL`：自 5.5 起，按 `addr` 中的 user_data 取消请求。找到并发出
  取消时 `res=0`；未找到 `-ENOENT`；正在取消 `-EALREADY`。套接字等可中断 I/O 通常能
  取消，已开始的磁盘 I/O 不能。
- `IORING_OP_LINK_TIMEOUT`：自 5.5 起，必须通过 `IOSQE_IO_LINK` 链接到请求。作用于
  被链接请求而非 CQ；没有完成计数。到期返回 `-ETIME`，因被链接请求完成而取消返回
  `-ECANCELED`；默认 `CLOCK_MONOTONIC`。
- `IORING_OP_CONNECT`：自 5.5 起，等价于 connect；`fd` 为套接字，`addr` 为 sockaddr，
  `off` 为 addrlen。
- `IORING_OP_FALLOCATE`：自 5.6 起，等价于 fallocate；`len` 为 mode，`off` 为偏移，
  `addr` 为长度。
- `IORING_OP_FADVISE`：自 5.6 起，等价于 posix_fadvise；`fd`、`off`、`len`、
  `fadvise_advice` 对应参数。
- `IORING_OP_MADVISE`：自 5.6 起，等价于 madvise；`addr`、`len`、
  `fadvise_advice` 对应参数。
- `IORING_OP_OPENAT`: 自 5.6 起，等价于 openat；`fd`=dirfd，`addr`=pathname，
  `open_flags`，`len`=mode。正数 `file_index` 将文件放入固定表索引 `file_index-1`。
- `IORING_OP_OPENAT2`：自 5.6 起，等价于 openat2；`fd`=dirfd，`addr`=pathname，
  `len`=open_how 大小，`off`=open_how 地址；直接描述符规则同 OPENAT。
- `IORING_OP_CLOSE`：自 5.6 起，等价于 close；正数 `file_index` 可关闭由 open/accept
  创建的固定描述符，两个描述符字段只能设置一个；直接关闭自 5.15 起可用。
- `IORING_OP_STATX`：自 5.6 起，等价于 statx；`fd`=dirfd，`addr`=path，
  `statx_flags`、`len`=mask、`off`=statxbuf。
- `IORING_OP_READ` / `IORING_OP_WRITE`：自 5.6 起，等价于 pread/pwrite；`fd`、`addr`、
  `len`、`off` 对应参数。`off=-1` 使用并推进当前文件位置；不可寻址文件的 `off` 必须为
  0 或 -1。
- `IORING_OP_SPLICE`：自 5.7 起，等价于 splice；`splice_fd_in`、`splice_off_in`、
  `fd`、`off`、`len`、`splice_flags` 对应参数，偏移 NULL 用 -1 表示；至少一端为管道。
- `IORING_OP_TEE`：自 5.8 起，等价于 tee；`splice_fd_in`、`fd`、`len`、
  `splice_flags`；两端都必须是管道。
- `IORING_OP_FILES_UPDATE`：自 5.6 起，异步等价于
  `IORING_REGISTER_FILES_UPDATE`；`addr` 为 fd 数组，`len` 为数量，`off` 为偏移；数组
  在完成前必须有效。
- `IORING_OP_PROVIDE_BUFFERS`：自 5.7 起，提供读取/接收缓冲区组。`fd` 为缓冲区数量，
  `addr` 为起始地址，`len` 为每个大小，`buf_group` 为组 ID，`off` 为起始 buffer ID；
  应用须提供 `len * fd` 字节。选择时设置 `IOSQE_BUFFER_SELECT` 和组 ID。
- `IORING_OP_REMOVE_BUFFERS`：自 5.7 起，移除先前提供的缓冲区；`fd` 为数量，
  `buf_group` 为组 ID。
- `IORING_OP_SHUTDOWN`：自 5.11 起，等价于 shutdown；`fd` 为套接字，`len` 为 `how`，
  其他字段不得设置。
- `IORING_OP_RENAMEAT`：自 5.11 起，等价于 renameat2；`fd`=olddirfd，`addr`=oldpath，
  `len`=newdirfd，`addr2`=newpath，`rename_flags`=flags。
- `IORING_OP_UNLINKAT`：自 5.11 起；`fd`=dirfd，`addr`=pathname，
  `unlink_flags`=flags。
- `IORING_OP_MKDIRAT`：自 5.15 起；`fd`=dirfd，`addr`=pathname，`len`=mode。
- `IORING_OP_SYMLINKAT`：自 5.15 起；`fd`=newdirfd，`addr`=target，
  `addr2`=linkpath。
- `IORING_OP_LINKAT`：自 5.15 起；`fd`=olddirfd，`addr`=oldpath，`len`=newdirfd，
  `addr2`=newpath，`hardlink_flags`=flags。
- `IORING_OP_MSG_RING`：自 5.18 起。向有权访问的目标环发送消息；`fd` 为目标环，
  `len` 为 32 位结果，`off` 为 64 位 user_data。目标发布相应 CQE，可用于唤醒或传递消息。
- `IORING_OP_SOCKET`：自 5.19 起，等价于 socket；`fd`=domain，`off`=type，`len`=protocol，
  `rw_flags` 必须为 0。直接描述符规则同 OPENAT。
- `IORING_OP_URING_CMD`：自 5.19 起，面向单个文件的异步私有操作，类似 ioctl；详见其专用页。
- `IORING_OP_SEND_ZC`：自 6.0 起，零拷贝 send，失败可回退复制；不支持时返回
  `-EOPNOTSUPP`。通常产生两个 CQE：第一个遵循 send 规则，若设置
  `IORING_CQE_F_MORE` 则第二个为通知，`res=0` 且 flags 为 `IORING_CQE_F_NOTIF`。
  通知前不得修改数据缓冲区；通知只表示缓冲区生命周期，不代表数据已送达。`addr2` 非零
  时转换为 sendto；支持 `IORING_RECVSEND_POLL_FIRST` 和 `FIXED_BUF`。
- `IORING_OP_SENDMSG_ZC`：自 6.1 起，零拷贝 sendmsg；同 SENDMSG，并支持
  `IORING_RECVSEND_FIXED_BUF`。
- `IORING_OP_WAITID`：自 6.5 起，等价于 waitid；`len`=idtype，`fd`=id，
  `file_index`=options，`addr2`=siginfo_t。
- `IORING_OP_SETXATTR` / `IORING_OP_GETXATTR` / `IORING_OP_FSETXATTR` /
  `IORING_OP_FGETXATTR`：自 5.19 起；`addr`=属性名，`addr2`=最大 `len` 的值缓冲区，
  `xattr_flags`=flags；非 f 变体的 `addr3` 为文件路径，f 变体用 `fd`。
- `IORING_OP_BIND`：自 6.11 起，等价于 bind；`fd`、`addr`、`addr2`（地址长度）对应参数。
- `IORING_OP_LISTEN`：自 6.11 起；`fd` 为套接字，`len` 为 backlog。
- `IORING_OP_FTRUNCATE`：自 6.9 起；`fd` 为文件，`off` 为目标长度。
- `IORING_OP_READ_MULTISHOT`：自 6.7 起；单 SQE 在有更多数据时重复读取并发布 CQE；
  仅限可轮询文件，文件不支持 `NOWAIT` 时退回单次；检查 `IORING_CQE_F_MORE`。
- `IORING_OP_FUTEX_WAIT`：自 6.7 起；`addr`=futex，`addr2`=预期值，`addr3`=位掩码，
  `fd` 可含 futex2 标志；排队时值仍匹配才休眠。
- `IORING_OP_FUTEX_WAKE`：自 6.7 起；`addr`=futex，`addr2`=最大唤醒数，
  `addr3`=位掩码，`fd` 可含 futex2 标志。
- `IORING_OP_FUTEX_WAITV`：自 6.7 起；`addr`=futexv，`len`=长度，必须非 0 且小于
  `FUTEX_WAITV_MAX`（6.11 时为 128）。
- `IORING_OP_FIXED_FD_INSTALL`：自 6.8 起；将固定文件安装到普通文件表。`fd` 为文件索引，
  必须设置 `IOSQE_FIXED_FILE`；普通 fd 经 `cqe->res` 返回。`install_fd_flags` 支持
  `IORING_FIXED_FD_NO_CLOEXEC`。
- `IORING_OP_PIPE`：自 6.16 起。`addr` 指向两个整数，完成后 [0] 为读端、[1] 为写端；
  `pipe_flags` 支持 `O_CLOEXEC|O_NONBLOCK|O_DIRECT|O_NOTIFICATION_PIPE`。`file_index=0`
  使用普通 fd，`IORING_FILE_INDEX_ALLOC` 动态分配直接 fd，非零值指定直接索引及下一索引。
- `IORING_OP_RECV_ZC`：自 6.15 起，通过预注册 ZCRX 接口队列零拷贝接收；`fd` 为套接字，
  `zcrx_ifq_idx` 为接口队列索引，`len` 为最大数据量；`ioprio` 可含
  `IORING_RECVSEND_POLL_FIRST` 和 `IORING_RECV_MULTISHOT`，必须多轮触发。队列需先通过
  `IORING_REGISTER_ZCRX_IFQ` 注册。
- `IORING_OP_EPOLL_WAIT`：自 6.15 起，异步 epoll_wait；`fd` 为 epoll fd，`addr` 为
  `epoll_event` 数组，`len` 为最大事件数。
- `IORING_OP_READV_FIXED` / `IORING_OP_WRITEV_FIXED`：自 6.15 起，使用已注册缓冲区的
  向量读写；`buf_index` 指定注册表索引，iovec 指向已注册区域。
- `IORING_OP_NOP128`：自 6.19 起，类似 NOP，但显式使用 128 字节 SQE，适用于
  `IORING_SETUP_SQE_MIXED` 环。
- `IORING_OP_URING_CMD128`：自 6.19 起，类似 URING_CMD，但显式使用 128 字节 SQE，
  多出的 64 字节用于命令数据；适用于 `IORING_SETUP_SQE_MIXED` 环。

SQE `flags` 支持：

- `IOSQE_FIXED_FILE`（5.1）：`fd` 是已注册文件索引；不支持固定文件的操作会以 `-EBADF`
  失败。
- `IOSQE_IO_DRAIN`（5.2）：在先前 SQE 完成前不启动本 SQE，本 SQE 完成前不启动新 SQE。
- `IOSQE_IO_LINK`（5.3）：与下一个 SQE 建立软链接，下一项在上一项完成后启动；链不跨
  提交边界，任一项错误会取消未启动部分并返回 `-ECANCELED`，短读也算错误。
- `IOSQE_IO_HARDLINK`（5.5）：类似 LINK，但完成结果不论成功失败都不切断链；若父请求
  提交失败仍会切断。隐含 LINK。
- `IOSQE_ASYNC`（5.6）：从一开始异步执行，而非先尝试非阻塞。
- `IOSQE_BUFFER_SELECT`（5.7）：从提供缓冲区池选择缓冲区；所选 ID 位于 CQE flags 中
  高于 `IORING_CQE_BUFFER_SHIFT` 的位，并设置 `IORING_CQE_F_BUFFER`；无可用缓冲区返回
  `-ENOBUFS`。
- `IOSQE_CQE_SKIP_SUCCESS`（5.17）：成功时不生成 CQE；失败照常发布，且无硬链接时后续
  链接请求 CQE 也会省略。与 `IOSQE_IO_DRAIN` 不兼容；混合使用为未定义行为，首个带此标志
  的请求之后，带 drain 的请求会在提交时失败。链接超时的 CQE 完全由自身此标志决定。

`ioprio` 为 I/O 优先级。`fd` 为操作目标文件描述符，特例见上。固定读写要求 `addr`/
`len` 落在 `buf_index` 缓冲区；READV/WRITEV 的 `addr` 指向 `len` 个 iovec。
`rw_flags` 为每次 I/O 标志；`fsync_flags` 为 0 或 `IORING_FSYNC_DATASYNC`；
`poll_events` 使用 `<poll.h>`；`user_data` 原样复制到 CQE；`buf_index` 为固定缓冲区
索引；`personality` 为凭据 ID，0 表示当前任务凭据。

初始化 SQE 后，将其索引放入 SQ 尾部；推进尾部后调用 `io_uring_enter(2)` 发起 I/O。

CQE 结构：

```c
struct io_uring_cqe {
    __u64    user_data; /* sqe->data submission passed back */
    __s32    res;       /* result code for this event */
    __u32    flags;
};
```

`user_data` 从 SQE 复制；`flags` 用于 POLL_ADD、BUFFER_SELECT、MSG_RING 等；`res` 为操作
结果，io_uring 特定错误也通过它返回。读写错误为 `-errno`，成功为传输字节数。

## 返回值

成功时返回成功消费的 I/O 数量；`to_submit=0` 或 SQ 为空时可为 0。SQPOLL 下通常等于
`to_submit`，因为提交发生在本系统调用之外。SQE 相关错误通过 CQE 返回；非 SQE 错误以
负错误码直接从系统调用返回。调用方不应依赖 `errno`。

## 错误

- `EAGAIN`：内核无法分配请求资源，应等待完成后再试。
- `EBADF`：`fd` 无效。
- `EBADFD`：fd 有效，但环未启用。
- `EBADR`：即使有 `IORING_FEAT_NODROP` 仍丢弃了至少一个 CQE，且无其他 CQE；表示内存
  严重不足。
- `EBUSY`：有溢出项且 GETEVENTS 无法全部刷新；或在无 NODROP 时请求/CQ 空间过度提交。
- `EEXIST`：提交线程无效，常见于 DEFER_TASKRUN 的 GETEVENTS 由非创建/启用线程调用。
- `EINVAL`：`flags` 中存在无效位。
- `EFAULT`：`sig` 地址无效。
- `ENXIO`：实例正在拆除。
- `EOPNOTSUPP`：`fd` 不是 io_uring 实例。
- `EINTR`：等待事件期间被信号中断。
- `EOWNERDEAD`：SQPOLL 内核线程已被杀死。

## CQE 错误

以下错误以负值返回到 CQE `res`：

- `EACCES`：注册限制禁止该 SQE 的标志或操作码。
- `EBADF`：SQE fd 无效，或设置了 `IOSQE_FIXED_FILE` 但没有注册文件。
- `EFAULT`：缓冲区不可访问，或固定读写范围不在 `buf_index` 对应缓冲区。
- `EINVAL`：SQE 标志、操作码、`buf_index`、`personality` 无效。
- `EINVAL`：READV/WRITEV 与已注册固定缓冲区冲突，或固定读写索引错误。
- `EINVAL`：READV/WRITEV/READ_FIXED/WRITE_FIXED/FSYNC 在 IOPOLL 环上字段无效。
- `EINVAL`：POLL_ADD/POLL_REMOVE 在 IOPOLL 环上或字段无效，或 POLL_ADD 的 `addr` 非零。
- `EOPNOTSUPP`：操作码有效但内核不支持，或操作码不支持缓冲区选择却设置了该标志。
- `EINVAL`：TIMEOUT 指定多个时钟源，或同时设置多轮触发与绝对超时。
