# liburing 中文文档

中文 man 页面按节号分类：

- [man2](man2/)：系统调用，目前对应 3 个上游页面
- [man3](man3/)：liburing 库函数，目前对应 154 个上游页面
- [man7](man7/)：io_uring 用法与机制概览，目前对应 9 个上游页面

各分类中的文件名与上游 `man/` 目录一致，并添加 `.md` 后缀。例如
`man/io_uring_setup.2` 对应的中文页面路径为 `man2/io_uring_setup.2.md`。

运行 `make catalog` 查看完整页码、翻译状态和上游别名关系。
