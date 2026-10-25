---
title: io_uring_register_bpf_filter
section: 3
source_path: man/io_uring_register_bpf_filter.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: ca7fe127fbff539ba5a8c830d8dc265d981dcafc4be512beed34d61cfb851b31
source_copyright: "Copyright (C) 2025 Jens Axboe <axboe@kernel.dk>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---

# io_uring_register_bpf_filter(3)

## 名称

io_uring_register_bpf_filter、io_uring_register_bpf_filter_task - 为 io_uring 操作
注册经典 BPF 过滤器

## 概要

```c
#include <liburing.h>
#include <liburing/io_uring/bpf_filter.h>
#include <linux/filter.h>

int io_uring_register_bpf_filter(struct io_uring *ring,
                                 struct io_uring_bpf *bpf);

int io_uring_register_bpf_filter_task(struct io_uring_bpf *bpf);
```

## 描述

这些函数注册经典 BPF（cBPF）过滤器以限制 io_uring 操作。过滤器可根据操作参数允许或
拒绝特定操作，从而实施安全策略。

[io_uring_register_bpf_filter(3)](io_uring_register_bpf_filter.3.md) 在特定 `ring` 上
注册过滤器，只适用于通过该环提交的操作。

[io_uring_register_bpf_filter_task(3)](io_uring_register_bpf_filter.3.md) 在调用任务上
注册过滤器，适用于注册后该任务创建的所有 io_uring 环，并由通过
[fork(2)](https://man7.org/linux/man-pages/man2/fork.2.html) 创建的子进程继承。注册前
已创建的环不受影响。任务级过滤器不能移除，子进程不能放宽父进程设置的限制。

`bpf` 参数指向 `cmd_type` 设置为 `IO_URING_BPF_CMD_FILTER` 的
`struct io_uring_bpf`。内嵌的 `struct io_uring_bpf_filter` 描述要注册的过滤器：

```c
struct io_uring_bpf_filter {
    __u32   opcode;      /* 要过滤的 io_uring 操作码 */
    __u32   flags;       /* IO_URING_BPF_FILTER_* */
    __u32   filter_len;  /* BPF 指令数量 */
    __u8    pdu_size;    /* 操作码预期 pdu 大小 */
    __u8    resv[3];
    __u64   filter_ptr;  /* BPF 过滤器指针 */
    __u64   resv2[5];
};
```

`opcode` 指定过滤器适用的 io_uring 操作（例如 `IORING_OP_SOCKET`、
`IORING_OP_NOP`、`IORING_OP_READ`）。

`filter_ptr` 指向 `filter_len` 条 BPF 指令（`struct sock_filter`）组成的数组。匹配
操作执行过滤器；返回非零允许操作，返回零拒绝操作（应用收到 `-EACCES`）。

`pdu_size` 指定该操作码所需操作特定负载数据的预期字节数（例如
`struct io_uring_bpf_ctx` 内的 socket 或 open 结构）。无额外负载的操作码应为 0。
`IORING_OP_SOCKET` 应为 12（三个 4 字节成员），`IORING_OP_OPENAT` 和
`IORING_OP_OPENAT2` 应为 24（三个 8 字节成员）。

应用 `pdu_size` 与内核预期大小相同时注册成功。大小不同时的行为取决于 `flags` 中的
`IO_URING_BPF_FILTER_SZ_STRICT`：

- 设置严格标志时，大小不同会以 `-EMSGSIZE` 失败。
- 未设置严格标志时，应用大小小于内核大小时允许注册，使针对较旧、较小负载编译的应用
  仍可加载过滤器。
- 无论是否严格，应用大小大于内核大小都总是以 `-EMSGSIZE` 失败。

发生 `-EMSGSIZE` 时，内核会把预期 `pdu_size` 写回传入的
`struct io_uring_bpf_filter`，使应用可发现大小并调整重试。

`flags` 可以为 0，或者以下值的按位或：

- `IO_URING_BPF_FILTER_DENY_REST`：拒绝没有注册过滤器的操作码，从而建立允许列表。
- `IO_URING_BPF_FILTER_SZ_STRICT`：要求 `pdu_size` 与内核预期完全一致；否则
  `-EMSGSIZE`。未设置时允许应用大小小于或等于内核大小。

### 过滤器上下文

BPF 过滤器接收可用绝对寻址 `BPF_LD` 指令检查的上下文结构：

```c
struct io_uring_bpf_ctx {
    __u64   user_data;     /* 偏移 0：SQE 的 user_data */
    __u8    opcode;        /* 偏移 8：io_uring 操作码 */
    __u8    sqe_flags;     /* 偏移 9：SQE 标志 */
    __u8    pdu_size;      /* 偏移 10：过滤器的辅助数据大小 */
    __u8    pad[5];        /* 偏移 11-15：填充 */
    union {
        struct {
            __u32   family;    /* 偏移 16：套接字族 */
            __u32   type;      /* 偏移 20：套接字类型 */
            __u32   protocol;  /* 偏移 24：套接字协议 */
        } socket;
        struct {
            __u64   flags;     /* 偏移 16：打开标志 */
            __u64   mode;      /* 偏移 24：文件模式 */
            __u64   resolve;   /* 偏移 32：解析标志 */
        } open;
    };
};
```

`pdu_size` 字段表示联合体中操作特定数据的字节数。过滤器可检查它以确认收到预期负载，
并据此向前兼容未来内核新增字段。

对于 `IORING_OP_SOCKET`，会填充套接字族、类型和协议，`pdu_size` 为 12。

对于 `IORING_OP_OPENAT` 和 `IORING_OP_OPENAT2`，会填充打开标志、模式和解析字段。
`flags` 包含打开标志（如 `O_RDONLY`、`O_CREAT`）。`resolve` 仅对
`IORING_OP_OPENAT2` 有意义，包含解析标志（如 `RESOLVE_IN_ROOT`）。`pdu_size` 为 24。

### 过滤器叠加

同一操作码可以注册多个过滤器。多个过滤器按顺序评估，全部返回非零才允许操作。任务级
过滤器中，先评估子进程过滤器，再评估父进程过滤器。

## 返回值

成功时返回 0。失败时返回负错误码。

## 错误

- `-EINVAL`：过滤器、操作码或标志无效。
- `-EMSGSIZE`：`pdu_size` 与内核预期不符，原因包括严格匹配失败或应用大小大于内核大小。
- `-ENOMEM`：没有足够内存注册过滤器。
- `-EFAULT`：过滤器指针无效。
- `-EACCES`：调用方既没有 `CAP_SYS_ADMIN`，调用任务也未设置 `no_new_privs`。参见
  [prctl(2)](https://man7.org/linux/man-pages/man2/prctl.2.html) 的
  `PR_SET_NO_NEW_PRIVS`。

## 示例

### 拒绝所有 NOP 操作

```c
#include <sys/prctl.h>
#include <linux/filter.h>
#include <liburing.h>
#include <liburing/io_uring/bpf_filter.h>

struct sock_filter deny_filter[] = {
    BPF_STMT(BPF_RET | BPF_K, 0),  /* 返回 0（拒绝） */
};

struct io_uring_bpf bpf = {
    .cmd_type = IO_URING_BPF_CMD_FILTER,
    .filter = {
        .opcode = IORING_OP_NOP,
        .filter_len = 1,
        .filter_ptr = (unsigned long) deny_filter,
    },
};

/* 注册任务过滤器前必须设置 no_new_privs */
prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);

/* 在特定环上注册 */
io_uring_register_bpf_filter(&ring, &bpf);

/* 或在任务上注册 */
io_uring_register_bpf_filter_task(&bpf);
```

### 仅允许 AF_INET 套接字

```c
#include <sys/prctl.h>
#include <linux/filter.h>
#include <sys/socket.h>
#include <liburing.h>
#include <liburing/io_uring/bpf_filter.h>

#define CTX_OFF_SOCKET_FAMILY  16

struct sock_filter inet_only_filter[] = {
    /* 从上下文加载套接字族 */
    BPF_STMT(BPF_LD | BPF_W | BPF_ABS, CTX_OFF_SOCKET_FAMILY),
    /* family == AF_INET 时跳转以允许 */
    BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, AF_INET, 0, 1),
    /* 允许：返回 1 */
    BPF_STMT(BPF_RET | BPF_K, 1),
    /* 拒绝：返回 0 */
    BPF_STMT(BPF_RET | BPF_K, 0),
};

struct io_uring_bpf bpf = {
    .cmd_type = IO_URING_BPF_CMD_FILTER,
    .filter = {
        .opcode = IORING_OP_SOCKET,
        .filter_len = 4,
        .filter_ptr = (unsigned long) inet_only_filter,
        .pdu_size = 12,  /* 3x __u32：family、type、protocol */
    },
};

prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
io_uring_register_bpf_filter_task(&bpf);
```

### 仅允许 NOP，拒绝其他一切

```c
struct sock_filter allow_filter[] = {
    BPF_STMT(BPF_RET | BPF_K, 1),  /* 返回 1（允许） */
};

struct io_uring_bpf bpf = {
    .cmd_type = IO_URING_BPF_CMD_FILTER,
    .filter = {
        .opcode = IORING_OP_NOP,
        .flags = IO_URING_BPF_FILTER_DENY_REST,
        .filter_len = 1,
        .filter_ptr = (unsigned long) allow_filter,
    },
};

prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
io_uring_register_bpf_filter_task(&bpf);
```

### 查询操作码的内核 pdu_size

```c
struct sock_filter allow[] = {
    BPF_STMT(BPF_RET | BPF_K, 1),
};

struct io_uring_bpf bpf = {
    .cmd_type = IO_URING_BPF_CMD_FILTER,
    .filter = {
        .opcode = IORING_OP_SOCKET,
        .flags = IO_URING_BPF_FILTER_SZ_STRICT,
        .filter_len = 1,
        .filter_ptr = (unsigned long) allow,
        .pdu_size = 0,  /* 有意使用错误值 */
    },
};
int ret;

ret = io_uring_register_bpf_filter(&ring, &bpf);
if (ret == -EMSGSIZE) {
    /* 内核写回了预期大小 */
    printf("SOCKET 的内核 pdu_size：%u\n", bpf.filter.pdu_size);
    ret = io_uring_register_bpf_filter(&ring, &bpf);
}
```

## 注意事项

### 权限要求

与 [seccomp(2)](https://man7.org/linux/man-pages/man2/seccomp.2.html) 类似，注册 BPF
过滤器要求调用方具有 `CAP_SYS_ADMIN`，或者在调用任务上设置 `no_new_privs`。这可防止
非特权进程安装过滤器后执行 setuid 程序，否则该程序会以提升权限运行但受攻击者控制的
过滤器约束。

设置方式：

```c
prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
```

设置后 `no_new_privs` 无法取消，并在 fork 时继承、在
[execve(2)](https://man7.org/linux/man-pages/man2/execve.2.html) 后保留。

### 继承

任务级过滤器由子进程继承，父进程可建立适用于所有后代的安全限制。子进程可添加更多限制，
但不能移除或放宽祖先过滤器。环级过滤器只适用于特定环，且不会被继承。

## 参见

- [io_uring_register(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_register.2)
- [io_uring_setup(2)](https://github.com/axboe/liburing/blob/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_setup.2)
- [bpf(2)](https://man7.org/linux/man-pages/man2/bpf.2.html)
- [seccomp(2)](https://man7.org/linux/man-pages/man2/seccomp.2.html)
