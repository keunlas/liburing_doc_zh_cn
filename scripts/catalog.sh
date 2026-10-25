#!/usr/bin/env bash

# 根据锁定版本的上游 man 目录生成 Markdown 翻译目录。
# 输出按 man 节号分组，并显示规范页面、别名关系和当前译文状态。
set -euo pipefail

# 统一从项目根目录读取配置和文档，不依赖调用者当前所在目录。
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$project_root/upstream.lock"

source_root="$project_root/.cache/liburing/$upstream_commit/man"

# 目录脚本不自动联网；先要求运行 make sync，确保哈希和路径对应固定提交。
if [[ ! -d "$source_root" ]]; then
    printf '未找到上游源码，请先运行 make sync。\n' >&2
    exit 1
fi

# 计数同时覆盖规范页面、已审校译文和上游别名。
canonical_count=0
alias_count=0
translated_count=0

printf '# liburing man 中文翻译目录\n\n'
printf '上游提交：`%s`（%s）\n\n' "$upstream_commit" "$upstream_commit_date"

# 从上游文件扩展名提取节号并排序，使目录自动按 man2、man3、man7 分组。
for section in $(find "$source_root" -maxdepth 1 -type f -printf '%f\n' |
    awk -F. '{print $NF}' | sort -n -u); do
    printf '## man%s\n\n' "$section"
    printf '| 上游页面 | 中文文档 | 状态 |\n'
    printf '| --- | --- | --- |\n'

    # 每个规范页面映射到 docs/man<节号>/<上游文件名>.md。
    while IFS= read -r source_file; do
        source_name="$(basename "$source_file")"
        target_file="$project_root/docs/man$section/$source_name.md"
        relative_target="${target_file#"$project_root"/}"
        status="待翻译"

        # 只读取 front matter 中的状态字段，并把内部状态转换为中文展示。
        if [[ -f "$target_file" ]]; then
            value="$(
                awk -F: '
                    /^translation_status:[[:space:]]*/ {
                        sub(/^[^:]*:[[:space:]]*/, "")
                        sub(/[[:space:]]+$/, "")
                        print
                        exit
                    }
                ' "$target_file"
            )"
            case "$value" in
                draft) status="草稿" ;;
                reviewed) status="已审校" ;;
                stale) status="待复核" ;;
                *) status="状态无效" ;;
            esac
        fi

        printf '| `%s` | `%s` | %s |\n' "$source_name" "$relative_target" "$status"
        canonical_count=$((canonical_count + 1))
        if [[ "$status" == "已审校" ]]; then
            translated_count=$((translated_count + 1))
        fi
    done < <(find "$source_root" -maxdepth 1 -type f -name "*.$section" -print | sort)

    # 上游的符号链接是别名页面，不复制译文正文，只列出其规范目标。
    if find "$source_root" -maxdepth 1 -type l -name "*.$section" -print -quit |
        grep -q .; then
        printf '\n别名：\n\n'
        printf '| 别名 | 指向的规范页面 |\n'
        printf '| --- | --- |\n'
        while IFS= read -r alias_file; do
            printf '| `%s` | `%s` |\n' \
                "$(basename "$alias_file")" "$(readlink "$alias_file")"
            alias_count=$((alias_count + 1))
        done < <(find "$source_root" -maxdepth 1 -type l -name "*.$section" -print | sort)
    fi

    printf '\n'
done

# 输出总数，便于快速判断翻译覆盖率和基线是否发生变化。
printf '\n合计：%d 个规范页面，%d 个已审校，%d 个别名。\n' \
    "$canonical_count" "$translated_count" "$alias_count"
