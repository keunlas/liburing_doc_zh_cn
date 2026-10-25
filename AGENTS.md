# liburing 中文文档项目约定

## 项目目标

将 [axboe/liburing](https://github.com/axboe/liburing) 仓库中的 man 手册翻译为中文
Markdown。翻译应准确、可维护，并保留上游的 API 名称、代码示例和许可证信息。

这是一个非官方中文翻译项目。上游文档始终是技术内容的最终依据；不得为了行文流畅而
改变接口行为、约束条件或错误语义。

## 上游基准

仓库地址：

```text
https://github.com/axboe/liburing.git
```

当前翻译基准固定在 `upstream.lock` 中。不要自行改用上游 `master` 的最新提交；升级
基准必须是一次独立、可审查的变更，并记录新的提交哈希和日期。

当前基准提交：

```text
236c1525ff1b2ea5870ecada04951eb2d053275e
```

该提交包含 166 个上游 man 页面和 62 个别名链接。翻译状态按 166 个规范页面统计，
别名页面通过上游规范的 `.so` 指向关系解析。

## 目录结构

```text
docs/man2/                第 2 节系统调用中文 Markdown
docs/man3/                第 3 节库函数中文 Markdown
docs/man7/                第 7 节概览文档中文 Markdown
templates/man-page.md     新翻译页面的模板
scripts/sync-upstream.sh  获取并检出锁定版本的上游源码
scripts/catalog.sh        输出翻译目录和进度
scripts/check-docs.sh     校验元数据、映射关系和源文件哈希
TRANSLATION.md            翻译与审校规范
GLOSSARY.md               统一术语表
upstream.lock             上游仓库、提交和同步日期
```

上游源码缓存在 `.cache/liburing/<commit>/`，该目录不提交到 Git。

## 翻译工作流

1. 先运行 `make sync`，确保 `.cache` 中存在锁定版本的上游 man 页面。
2. 运行 `make catalog`，从“待翻译”列表中选择规范页面。
3. 根据上游文件的扩展名选择分类目录，并以 `templates/man-page.md` 为起点创建同名
   `.md` 文件。例如：
   - `man/io_uring_setup.2` 对应 `docs/man2/io_uring_setup.2.md`
   - `man/io_uring_get_sqe.3` 对应 `docs/man3/io_uring_get_sqe.3.md`
   - `man/io_uring_provided_buffers.7` 对应
     `docs/man7/io_uring_provided_buffers.7.md`
4. 完整对照上游原文翻译，不删减限制条件、版本信息、错误说明和交叉引用。
5. 更新术语表或在译文中遵守既有术语，再运行 `make check`。
6. 提交前人工复核一次代码块、标识符、返回值、错误码和 `SEE ALSO` 链接。

不要把未完成的机器翻译放入任何分类目录。尚未开始或无法准确判断的内容应保持为
“待翻译”。

## 页面元数据

每个 `docs/man2/*.md`、`docs/man3/*.md` 或 `docs/man7/*.md` 必须以 YAML front
matter 开头，并包含以下字段：

```yaml
---
title: io_uring_get_sqe
section: 3
source_path: man/io_uring_get_sqe.3
source_commit: 236c1525ff1b2ea5870ecada04951eb2d053275e
source_sha256: <上游源文件的 sha256>
source_copyright: "<上游页面中的版权行，多条用分号分隔>"
translation_status: draft
translated_at: 2026-10-25
license: LGPL-2.0-or-later
---
```

`translation_status` 只能是 `draft`、`reviewed` 或 `stale`。只有经过人工完整校对后
才可设为 `reviewed`；上游基准升级后，尚未复核的旧译文应设为 `stale`。

`source_sha256` 用于确认译文对应的确切原文。源文件变化时不能只更新哈希，必须同时
复核译文中的相关段落。

`source_copyright` 必须摘录上游页面开头的全部版权行，不能只写项目名或作者名。

## 翻译规则

- 首行使用上游手册标题，例如 `# io_uring_get_sqe(3)`。
- 章节标题使用固定中文映射：NAME 为“名称”，SYNOPSIS 为“概要”，DESCRIPTION 为
  “描述”，RETURN VALUE 为“返回值”，ERRORS 为“错误”，VERSIONS 为“版本”，
  STANDARDS 为“标准”，HISTORY 为“历史”，NOTES 为“注意事项”，EXAMPLE 或
  EXAMPLES 为“示例”，SEE ALSO 为“参见”。
- 保留 C 代码、函数签名、宏、常量、`errno` 名称、结构体字段和命令行参数的原样拼写。
- 技术名词首次出现时采用“中文（英文）”形式，之后按术语表统一使用，例如
  “提交队列（submission queue，SQ）”。
- 使用中文标点；中文与英文单词、数字、行内代码之间保留一个半角空格。
- 保留段落和章节的上游顺序。可以拆分长句，但不得合并掉不同条件、例外或警告。
- 代码块默认保持上游内容不变，包括注释；只在不会改变代码的前提下翻译代码注释。
- man 宏产生的交叉引用转为 Markdown 链接。目标页面尚未翻译时，链接到锁定提交下
  的上游页面，避免制造失效链接。
- 不翻译 `io_uring`、`liburing`、Linux 系统调用名称、操作码、特性标志和 API 名称。
- 不使用“显然”“只需”“总是”等原文没有的绝对化措辞。
- 不以“比原文更好”为由增补行为说明。需要补充背景时，放在明确的“译者注”中。

完整规范见 `TRANSLATION.md`，统一术语见 `GLOSSARY.md`。

## 别名与交叉引用

上游使用相对符号链接指向规范页面。中文仓库不复制同一篇译文来制造别名页面；别名
关系由 `scripts/catalog.sh` 展示。交叉引用优先指向规范页面。

如果确实需要为常用别名提供 Markdown 入口，文件内容应只有简短说明和指向规范译文的
链接，并在 front matter 的 `source_path` 中记录对应的上游别名。

## 验证

完成任何翻译或结构调整后运行：

```sh
make check
```

还要人工确认：

- front matter 中的标题、节号和源路径匹配文件名；
- 文件位于与其节号一致的 `docs/man<节号>/` 目录；
- 源哈希对应锁定提交中的文件；
- 上游版权行和 SPDX 许可证已保留；
- 所有代码块闭合，语言标记正确；
- 函数、常量、结构体字段和错误码没有被误译；
- 相对链接指向真实文件；
- 译文没有遗漏多个段落粘连造成的语义变化。

提交前检查 `git diff --check` 和 `git status --short`。不要提交 `.cache/`。

## 许可证

上游 man 页面使用 `LGPL-2.0-or-later`。译文是原文的衍生作品，必须保留每个页面的
版权和许可证信息，并继续遵守对应上游页面的许可证。上游仓库根目录的 MIT
`LICENSE` 只覆盖其适用的软件部分，不能替代 man 页面的许可证声明。
