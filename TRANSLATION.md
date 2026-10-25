# 翻译规范

## 基本原则

译文要优先保证技术语义、约束条件和可执行示例正确，其次才是中文表达。遇到无法同时
满足“简洁”和“准确”的情况时，保留完整信息。

每一页都应对照 `upstream.lock` 锁定的上游原文完成，不接受未经核对的二手摘要。
上游 roff 注释中的版权行必须摘录到 front matter 的 `source_copyright` 字段，并在
同一次提交中保留许可证标识。

## 文件与标题

文件名与上游完全一致，仅在末尾添加 `.md`：

```text
man/io_uring_setup.2              -> docs/man2/io_uring_setup.2.md
man/io_uring_queue_init.3         -> docs/man3/io_uring_queue_init.3.md
man/io_uring_provided_buffers.7   -> docs/man7/io_uring_provided_buffers.7.md
```

目录名 `man<节号>` 必须与源文件扩展名一致。跨节分类由文件扩展名决定，而不是由 API
名称或主题决定。

正文第一行使用一级标题并保留节号，例如 `# io_uring_setup(2)`。`NAME` 中的命令、
函数和宏名称保留英文；简短说明翻译为中文。

## 章节映射

| 上游节标题 | 中文标题 |
| --- | --- |
| NAME | 名称 |
| SYNOPSIS | 概要 |
| DESCRIPTION | 描述 |
| RETURN VALUE | 返回值 |
| ERRORS | 错误 |
| VERSIONS | 版本 |
| STANDARDS | 标准 |
| HISTORY | 历史 |
| NOTES | 注意事项 |
| EXAMPLE / EXAMPLES | 示例 |
| BUGS | 缺陷 |
| SEE ALSO | 参见 |

只保留上游实际存在的章节，不为了形式统一而增加空章节。`.SS` 子标题按其技术含义
翻译，并保持层级。

## 文本转换

- `.BR io_uring_enter (2)` 转换为 `io_uring_enter(2)`；已有中文页面时添加相对链接。
- `.B IORING_SETUP_SQPOLL`、`.I entries` 等标识符使用行内代码，例如
  `IORING_SETUP_SQPOLL`、`entries`。
- `.EX`/`.EE` 中的内容转换到带语言标记的围栏代码块。C 代码使用 `c`，纯命令行使用
  `sh`，无法确定时留空。
- 上游手写换行不应机械保留到 Markdown。按完整段落和列表项重新排版，但不得改变
  原文的段落边界、条件分支或列表归属。
- 英文缩写首次出现时展开并保留缩写，例如“提交队列（submission queue，SQ）”。

## 术语与语气

采用技术文档的陈述语气，避免营销化表达。使用 GLOSSARY.md 中的译法；需要新增或修改
术语时，在同一改动中更新术语表。

以下内容不翻译：

- API、函数、变量、类型、字段、宏和常量名称；
- 操作码、标志位、`errno` 名称和结构体字段；
- 协议名、设备名、文件格式和命令行工具名；
- 代码和可复制的错误输出。

`ring` 在 io_uring 语境中统一译为“环”，首次出现可写作“环（ring）”；“submission
queue”译为“提交队列”，“completion queue”译为“完成队列”。

## 代码和示例

代码优先逐字保留。若只翻译注释，先确认注释不参与宏拼接、测试匹配或危险操作说明。
示例中的变量名、错误处理顺序和系统调用参数不得改动。

如果为解释代码而添加注释，应明确标记为译者补充：

```c
/* 译者注：这里展示的是调用顺序，不是可直接编译的完整示例。 */
```

## 链接

已翻译的页面使用相对 Markdown 链接，例如：

```markdown
[io_uring_setup(2)](io_uring_setup.2.md)
```

尚未翻译的目标页链接到锁定提交下的上游 man 页面，避免链接到会变化的 `master`。

## 审校清单

1. 对照上游逐节检查，确认没有漏段、并段或改变条件范围。
2. 检查所有 API、宏、常量、结构体字段和错误码的拼写。
3. 检查负返回值、`errno`、内核版本和功能标志是否与原文一致。
4. 对比代码块与上游，确认没有意外改动。
5. 检查术语、章节名和交叉链接。
6. 运行 `make check`，再检查 Markdown 渲染结果。
7. 完整审校后将 `translation_status` 设为 `reviewed`。
