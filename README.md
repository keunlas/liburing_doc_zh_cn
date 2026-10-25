# liburing 中文文档

[liburing](https://github.com/axboe/liburing) man 手册的非官方中文翻译，使用
Markdown 维护。项目目标是提供准确、可搜索、便于审校的中文 io_uring API 文档。

> 上游英文手册是技术内容的最终依据。发现差异时，以锁定提交中的原文为准。

## 当前状态

- 上游基准：`236c1525ff1b2ea5870ecada04951eb2d053275e`
- 基准日期：2026-10-23
- 上游页面：166 个规范页面，另有 62 个别名
- 已审核译文：0

翻译进度可通过下面的命令查看：

```sh
make sync
make catalog
```

`make sync` 会把锁定版本的上游源码获取到 `.cache/`，该目录不会提交到 Git。

## 目录结构

```text
docs/man/                 中文 Markdown，与上游 man 页面逐项对应
templates/man-page.md     翻译页面模板
scripts/                  上游同步、目录生成和完整性校验
TRANSLATION.md            翻译与审校规范
GLOSSARY.md               中英文术语表
upstream.lock             锁定版本与来源
AGENTS.md                 仓库维护约定
```

例如，上游文件 `man/io_uring_get_sqe.3` 对应的中文文件是
`docs/man/io_uring_get_sqe.3.md`。

## 开始翻译

```sh
make sync
make catalog
```

复制模板并填写上游文件哈希：

```sh
cp templates/man-page.md docs/man/io_uring_get_sqe.3.md
sha256sum .cache/liburing/236c1525ff1b2ea5870ecada04951eb2d053275e/man/io_uring_get_sqe.3
```

完成翻译后运行：

```sh
make check
```

翻译必须保留 API 名称、C 代码、错误码和上游章节顺序。具体规则见
[TRANSLATION.md](TRANSLATION.md)，术语选择见 [GLOSSARY.md](GLOSSARY.md)。

## 上游基准

`upstream.lock` 固定仓库地址、提交和同步日期。升级基准时，需要单独更新该文件，并
复核受上游差异影响的已有译文。Man 页面中的 `.so` 别名按上游关系解析，不复制正文。

## 许可证

本项目翻译的上游 man 页面采用 `LGPL-2.0-or-later`。每篇译文及其源文件版权信息应
随文保留，并继续遵守对应页面的许可证。详见 [NOTICE.md](NOTICE.md) 和上游的
[`man/` 目录](https://github.com/axboe/liburing/tree/master/man)。

