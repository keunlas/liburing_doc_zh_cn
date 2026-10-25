#!/usr/bin/env bash

# 校验中文 man 页面与锁定上游版本的对应关系。
# 检查范围包括分类路径、front matter、源哈希、许可证、状态和必要章节。
set -euo pipefail

# 从项目根目录定位锁定配置和文档目录，确保脚本可从 Makefile 或手动调用。
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$project_root/upstream.lock"

source_root="$project_root/.cache/liburing/$upstream_commit/man"
translation_root="$project_root/docs"
errors=0
checked=0

# 记录一个可汇总的错误；脚本会继续检查其余文件，最后统一返回失败状态。
fail() {
    printf '错误：%s\n' "$*" >&2
    errors=$((errors + 1))
}

# 从 YAML front matter 中提取标量字段。
# awk 在第二个 --- 处停止，避免误读正文中的同名文本。
frontmatter_value() {
    local file="$1"
    local key="$2"

    awk -v wanted="$key" '
        NR == 1 && $0 != "---" { exit }
        NR > 1 && $0 == "---" { exit }
        index($0, wanted ":") == 1 {
            sub(/^[^:]*:[[:space:]]*/, "")
            sub(/[[:space:]]+$/, "")
            print
            exit
        }
    ' "$file"
}

# 必须先同步上游，否则无法验证文件名、哈希和版权信息。
if [[ ! -d "$source_root" ]]; then
    printf '未找到上游源码，请先运行 make sync。\n' >&2
    exit 1
fi

# 没有 docs 目录时没有页面可检查，按空项目处理。
if [[ ! -d "$translation_root" ]]; then
    printf '未找到 docs，已跳过页面校验。\n'
    exit 0
fi

# 只扫描 docs/man<节号>/ 下一层的 Markdown 页面。
while IFS= read -r file; do
    name="$(basename "$file")"
    base="${name%.md}"

    # 中文文件名必须在完整的上游文件名后追加 .md。
    if [[ "$name" != *.md ]]; then
        fail "$file 不是 Markdown 文件"
        continue
    fi

    if [[ "$name" == "$base" ]]; then
        fail "$file 缺少 .md.md 后缀结构"
        continue
    fi

    # 每个中文页面都必须能追溯到锁定提交中的上游文件或符号链接。
    if [[ ! -f "$source_root/$base" && ! -L "$source_root/$base" ]]; then
        fail "$file 在上游锁定版本中没有对应的 $base"
        continue
    fi

    # front matter 是来源追踪和状态统计的必需部分。
    if [[ "$(head -n 1 "$file")" != "---" ]]; then
        fail "$file 缺少 YAML front matter"
        continue
    fi

    # 读取模板要求的全部元数据字段。
    title="$(frontmatter_value "$file" title)"
    section="$(frontmatter_value "$file" section)"
    source_path="$(frontmatter_value "$file" source_path)"
    source_commit="$(frontmatter_value "$file" source_commit)"
    source_sha256="$(frontmatter_value "$file" source_sha256)"
    source_copyright="$(frontmatter_value "$file" source_copyright)"
    status="$(frontmatter_value "$file" translation_status)"
    translated_at="$(frontmatter_value "$file" translated_at)"
    license="$(frontmatter_value "$file" license)"

    # 所有元数据字段都必须存在且非空。
    [[ -n "$title" ]] || fail "$file 缺少 title"
    [[ -n "$section" ]] || fail "$file 缺少 section"
    [[ -n "$source_path" ]] || fail "$file 缺少 source_path"
    [[ -n "$source_commit" ]] || fail "$file 缺少 source_commit"
    [[ -n "$source_sha256" ]] || fail "$file 缺少 source_sha256"
    [[ -n "$source_copyright" ]] || fail "$file 缺少 source_copyright"
    [[ -n "$status" ]] || fail "$file 缺少 translation_status"
    [[ -n "$translated_at" ]] || fail "$file 缺少 translated_at"
    [[ -n "$license" ]] || fail "$file 缺少 license"

    # source_path 和 source_commit 必须分别对应文件名和 upstream.lock。
    [[ "$source_path" == "man/$base" ]] ||
        fail "$file 的 source_path 应为 man/$base"
    [[ "$source_commit" == "$upstream_commit" ]] ||
        fail "$file 的 source_commit 与 upstream.lock 不一致"

    # section、文件名扩展名和实际目录三者必须一致。
    source_section="${base##*.}"
    [[ "$section" == "$source_section" ]] ||
        fail "$file 的 section 应为 $source_section"
    actual_directory="$(basename "$(dirname "$file")")"
    [[ "$actual_directory" == "man$source_section" ]] ||
        fail "$file 应位于 docs/man$source_section/"

    # 翻译状态只允许以下三个阶段。
    case "$status" in
        draft | reviewed | stale) ;;
        *) fail "$file 的 translation_status 无效：$status" ;;
    esac

    # 日期采用 YYYY-MM-DD；当前上游 man 页面统一使用 LGPL-2.0-or-later。
    [[ "$translated_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] ||
        fail "$file 的 translated_at 应为 YYYY-MM-DD"
    [[ "$license" == "LGPL-2.0-or-later" ]] ||
        fail "$file 的 license 与上游 man 页面声明不一致"

    # 哈希必须对应锁定提交中的源文件，防止译文悄然偏离翻译基准。
    if [[ "$source_sha256" == REPLACE_WITH_SOURCE_SHA256 ]]; then
        fail "$file 尚未填写 source_sha256"
    else
        actual_sha256="$(sha256sum "$source_root/$base" | awk '{print $1}')"
        [[ "$source_sha256" == "$actual_sha256" ]] ||
            fail "$file 的 source_sha256 与锁定版本源文件不一致"
    fi

    # 防止模板中的版权占位符被直接提交。
    if [[ "$source_copyright" == REPLACE_WITH_UPSTREAM_COPYRIGHT_LINES ]]; then
        fail "$file 尚未填写 source_copyright"
    fi

    # 所有 man 页面都必须保留上游的 NAME 和 SYNOPSIS 两个核心章节。
    if ! grep -q '^## 名称[[:space:]]*$' "$file"; then
        fail "$file 缺少“## 名称”章节"
    fi
    if ! grep -q '^## 概要[[:space:]]*$' "$file"; then
        fail "$file 缺少“## 概要”章节"
    fi

    checked=$((checked + 1))
done < <(find "$translation_root" -mindepth 2 -maxdepth 2 -type f -name '*.md' -print | sort)

# 汇总所有错误；只要有一项失败，就让 make check 返回非零状态。
if ((errors > 0)); then
    printf '校验失败：%d 个问题，检查了 %d 个文件。\n' "$errors" "$checked" >&2
    exit 1
fi

printf '校验通过：检查了 %d 个已翻译页面。\n' "$checked"
