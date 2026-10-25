#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$project_root/upstream.lock"

cache_root="$project_root/.cache/liburing"
checkout="$cache_root/$upstream_commit"

mkdir -p "$cache_root"

if [[ ! -d "$checkout/.git" ]]; then
    if [[ -e "$checkout" ]]; then
        printf '错误：%s 已存在但不是 Git 仓库，请检查该目录。\n' "$checkout" >&2
        exit 1
    fi

    printf '正在获取 %s 到 %s ...\n' "$upstream_repo" "$checkout"
    git clone --filter=blob:none --no-checkout "$upstream_repo" "$checkout"
fi

if ! git -C "$checkout" cat-file -e "$upstream_commit^{commit}" 2>/dev/null; then
    printf '正在获取锁定提交 %s ...\n' "$upstream_commit"
    git -C "$checkout" fetch --quiet --depth=1 origin "$upstream_commit"
fi

git -C "$checkout" checkout --quiet --detach "$upstream_commit"

actual_commit="$(git -C "$checkout" rev-parse HEAD)"
if [[ "$actual_commit" != "$upstream_commit" ]]; then
    printf '错误：检出提交 %s 与锁定提交 %s 不一致。\n' \
        "$actual_commit" "$upstream_commit" >&2
    exit 1
fi

printf '上游源码已就绪：%s\n' "$checkout"

