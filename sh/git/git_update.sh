#!/bin/bash

# 检查当前目录是否为 Git 仓库
if [[ ! -d .git ]]; then
    echo "当前目录不是 Git 仓库，请进入正确的 Git 仓库目录后重试。"
    exit 1
fi

echo "正在检查远程更新..."

# 获取当前分支名称
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "无法获取当前分支信息，请确保你在某个分支上。"
    exit 1
fi

echo "当前分支：$CURRENT_BRANCH"

# 检查远程是否有更新
echo "正在拉取最新的远程信息..."
git fetch origin

# 比较本地分支和远程分支的差异
LOCAL_COMMIT=$(git rev-parse @ 2>/dev/null)
REMOTE_COMMIT=$(git rev-parse @{u} 2>/dev/null)
BASE_COMMIT=$(git merge-base @ @{u} 2>/dev/null)

if [[ $LOCAL_COMMIT == $REMOTE_COMMIT ]]; then
    echo "当前分支已经是最新版本，无需更新。"
elif [[ $LOCAL_COMMIT == $BASE_COMMIT ]]; then
    echo "检测到远程有更新，正在拉取最新代码..."
    git pull origin "$CURRENT_BRANCH"
    if [[ $? -eq 0 ]]; then
        echo "更新成功！"
    else
        echo "更新失败，请检查错误信息。"
        exit 1
    fi
else
    echo "警告：本地分支与远程分支存在分歧（可能有未推送的提交），请手动解决冲突后再更新。"
    exit 1
fi