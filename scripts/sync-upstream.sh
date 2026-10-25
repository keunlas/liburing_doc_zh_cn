#!/usr/bin/env bash

# 获取 upstream.lock 固定的 liburing 提交，并检出到被忽略的 .cache 目录。
# 每次 checkout 后都会核对 HEAD，防止译文的源文件基准与锁定提交不一致。
set -euo pipefail

# 从脚本位置推导项目根目录，确保从任意工作目录调用都能找到 upstream.lock。
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$project_root/upstream.lock"

# 每个提交使用独立缓存目录，避免升级上游基准时覆盖仍在使用的旧源码。
cache_root="$project_root/.cache/liburing"
checkout="$cache_root/$upstream_commit"

mkdir -p "$cache_root"

# 首次运行时创建不检出文件的浅克隆；只获取后续需要的锁定提交。
if [[ ! -d "$checkout/.git" ]]; then
    if [[ -e "$checkout" ]]; then
        printf '错误：%s 已存在但不是 Git 仓库，请检查该目录。\n' "$checkout" >&2
        exit 1
    fi

    printf '正在获取 %s 到 %s ...\n' "$upstream_repo" "$checkout"
    git clone --filter=blob:none --no-checkout "$upstream_repo" "$checkout"
fi

# 如果缓存仓库尚未包含目标提交，则从 origin 单独获取该提交。
if ! git -C "$checkout" cat-file -e "$upstream_commit^{commit}" 2>/dev/null; then
    printf '正在获取锁定提交 %s ...\n' "$upstream_commit"
    git -C "$checkout" fetch --quiet --depth=1 origin "$upstream_commit"
fi

# 使用分离 HEAD 检出固定提交，避免缓存仓库的本地分支改变翻译基准。
git -C "$checkout" checkout --quiet --detach "$upstream_commit"

# 校验实际检出的提交与 upstream.lock 完全一致。
actual_commit="$(git -C "$checkout" rev-parse HEAD)"
if [[ "$actual_commit" != "$upstream_commit" ]]; then
    printf '错误：检出提交 %s 与锁定提交 %s 不一致。\n' \
        "$actual_commit" "$upstream_commit" >&2
    exit 1
fi

printf '上游源码已就绪：%s\n' "$checkout"
