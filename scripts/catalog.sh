#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$project_root/upstream.lock"

source_root="$project_root/.cache/liburing/$upstream_commit/man"

if [[ ! -d "$source_root" ]]; then
    printf '未找到上游源码，请先运行 make sync。\n' >&2
    exit 1
fi

canonical_count=0
alias_count=0
translated_count=0

printf '# liburing man 中文翻译目录\n\n'
printf '上游提交：`%s`（%s）\n\n' "$upstream_commit" "$upstream_commit_date"

for section in $(find "$source_root" -maxdepth 1 -type f -printf '%f\n' |
    awk -F. '{print $NF}' | sort -n -u); do
    printf '## man%s\n\n' "$section"
    printf '| 上游页面 | 中文文档 | 状态 |\n'
    printf '| --- | --- | --- |\n'

    while IFS= read -r source_file; do
        source_name="$(basename "$source_file")"
        target_file="$project_root/docs/man$section/$source_name.md"
        relative_target="${target_file#"$project_root"/}"
        status="待翻译"

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

printf '\n合计：%d 个规范页面，%d 个已审校，%d 个别名。\n' \
    "$canonical_count" "$translated_count" "$alias_count"
