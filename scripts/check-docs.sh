#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$project_root/upstream.lock"

source_root="$project_root/.cache/liburing/$upstream_commit/man"
translation_root="$project_root/docs/man"
errors=0
checked=0

fail() {
    printf '错误：%s\n' "$*" >&2
    errors=$((errors + 1))
}

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

if [[ ! -d "$source_root" ]]; then
    printf '未找到上游源码，请先运行 make sync。\n' >&2
    exit 1
fi

if [[ ! -d "$translation_root" ]]; then
    printf '未找到 docs/man，已跳过页面校验。\n'
    exit 0
fi

while IFS= read -r file; do
    name="$(basename "$file")"
    base="${name%.md}"

    if [[ "$name" != *.md ]]; then
        fail "$file 不是 Markdown 文件"
        continue
    fi

    if [[ "$name" == "$base" ]]; then
        fail "$file 缺少 .md.md 后缀结构"
        continue
    fi

    if [[ ! -f "$source_root/$base" && ! -L "$source_root/$base" ]]; then
        fail "$file 在上游锁定版本中没有对应的 $base"
        continue
    fi

    if [[ "$(head -n 1 "$file")" != "---" ]]; then
        fail "$file 缺少 YAML front matter"
        continue
    fi

    title="$(frontmatter_value "$file" title)"
    section="$(frontmatter_value "$file" section)"
    source_path="$(frontmatter_value "$file" source_path)"
    source_commit="$(frontmatter_value "$file" source_commit)"
    source_sha256="$(frontmatter_value "$file" source_sha256)"
    source_copyright="$(frontmatter_value "$file" source_copyright)"
    status="$(frontmatter_value "$file" translation_status)"
    translated_at="$(frontmatter_value "$file" translated_at)"
    license="$(frontmatter_value "$file" license)"

    [[ -n "$title" ]] || fail "$file 缺少 title"
    [[ -n "$section" ]] || fail "$file 缺少 section"
    [[ -n "$source_path" ]] || fail "$file 缺少 source_path"
    [[ -n "$source_commit" ]] || fail "$file 缺少 source_commit"
    [[ -n "$source_sha256" ]] || fail "$file 缺少 source_sha256"
    [[ -n "$source_copyright" ]] || fail "$file 缺少 source_copyright"
    [[ -n "$status" ]] || fail "$file 缺少 translation_status"
    [[ -n "$translated_at" ]] || fail "$file 缺少 translated_at"
    [[ -n "$license" ]] || fail "$file 缺少 license"

    [[ "$source_path" == "man/$base" ]] ||
        fail "$file 的 source_path 应为 man/$base"
    [[ "$source_commit" == "$upstream_commit" ]] ||
        fail "$file 的 source_commit 与 upstream.lock 不一致"

    source_section="${base##*.}"
    [[ "$section" == "$source_section" ]] ||
        fail "$file 的 section 应为 $source_section"

    case "$status" in
        draft | reviewed | stale) ;;
        *) fail "$file 的 translation_status 无效：$status" ;;
    esac

    [[ "$translated_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] ||
        fail "$file 的 translated_at 应为 YYYY-MM-DD"
    [[ "$license" == "LGPL-2.0-or-later" ]] ||
        fail "$file 的 license 与上游 man 页面声明不一致"

    if [[ "$source_sha256" == REPLACE_WITH_SOURCE_SHA256 ]]; then
        fail "$file 尚未填写 source_sha256"
    else
        actual_sha256="$(sha256sum "$source_root/$base" | awk '{print $1}')"
        [[ "$source_sha256" == "$actual_sha256" ]] ||
            fail "$file 的 source_sha256 与锁定版本源文件不一致"
    fi

    if [[ "$source_copyright" == REPLACE_WITH_UPSTREAM_COPYRIGHT_LINES ]]; then
        fail "$file 尚未填写 source_copyright"
    fi

    if ! grep -q '^## 名称[[:space:]]*$' "$file"; then
        fail "$file 缺少“## 名称”章节"
    fi
    if ! grep -q '^## 概要[[:space:]]*$' "$file"; then
        fail "$file 缺少“## 概要”章节"
    fi

    checked=$((checked + 1))
done < <(find "$translation_root" -maxdepth 1 -type f -name '*.md' -print | sort)

if ((errors > 0)); then
    printf '校验失败：%d 个问题，检查了 %d 个文件。\n' "$errors" "$checked" >&2
    exit 1
fi

printf '校验通过：检查了 %d 个已翻译页面。\n' "$checked"
