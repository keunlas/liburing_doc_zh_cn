# 术语表

本表用于保持整批手册的术语一致。表中“保留英文”表示正文也使用英文原名。新增术语
前先检查是否已有近义项。

| 英文 | 中文 | 说明 |
| --- | --- | --- |
| asynchronous I/O | 异步 I/O | 不译为“非同步 I/O” |
| buffer group (buf_group) | 缓冲区组（buf_group） | 指为缓冲区选择注册的组 |
| bundle | 捆绑（bundle） | 指一次请求连续使用多个提供的缓冲区 |
| completion queue (CQ) | 完成队列（CQ） | 首次出现保留缩写展开 |
| completion queue entry (CQE) | 完成队列项（CQE） | 可简称“完成事件” |
| context switch | 上下文切换 | |
| direct descriptor | 直接描述符 | io_uring 私有文件描述符 |
| file descriptor | 文件描述符 | |
| fixed buffer | 固定缓冲区 | 指通过注册固定下来的缓冲区 |
| in-flight request | 在途请求 | |
| io_uring ring | io_uring 环 | 也可简称“环”，保留 `ring` 数据结构含义 |
| kernel | 内核 | |
| linked requests | 链接请求 | |
| multishot | 多轮触发 | 不使用“多射” |
| notification CQE | 通知 CQE | 零拷贝发送中用于报告内存可复用的完成事件 |
| opcode | 操作码 | |
| personality | 身份凭据（personality） | 注册到环中的调用方凭据集合 |
| poll / polling | 轮询 | busy-wait 译为“忙等待” |
| probe | 探测（probe） | 查询 io_uring 操作码支持情况的信息 |
| provided buffers | 提供的缓冲区 | |
| reap CQEs | 获取并处理 CQE | 避免生硬直译为“收割” |
| registered buffer | 已注册缓冲区 | |
| request | 请求 | |
| short read | 短读 | 指未读取完整请求字节数的读取 |
| single-shot | 单次触发 | 与 multishot（多轮触发）相对 |
| submission queue (SQ) | 提交队列（SQ） | 首次出现保留缩写展开 |
| submission queue entry (SQE) | 提交队列项（SQE） | |
| system call | 系统调用 | |
| userspace | 用户空间 | |
| vectored I/O | 向量 I/O | 指 `readv`/`writev` 风格的 I/O |
| zero-copy | 零拷贝 | |

## 保留英文

以下名称在正文中保持原样：

```text
io_uring
liburing
Linux
SQ
CQ
SQE
CQE
```

所有 C 标识符、操作码、标志位、`errno` 常量、结构体和字段名都视为代码，不进入
中文化范围。
