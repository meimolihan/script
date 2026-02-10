#!/bin/bash

# 定义颜色变量
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

echo ""
echo -e "${gl_zi}>>> 拉取 Git 仓库更新${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
# 检查当前目录是否为 Git 仓库
if [[ ! -d .git ]]; then
    echo -e "${gl_huang}当前目录不是 Git 仓库，请进入正确的 Git 仓库目录后重试。${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    exit 1
fi

echo -e "${gl_bai}正在检查远程更新${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"

# 获取当前分支名称
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
if [[ -z "$CURRENT_BRANCH" ]]; then
    echo -e "${gl_huang}无法获取当前分支信息，请确保你在某个分支上。${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    exit 1
fi

echo -e "${gl_bai}当前分支：${gl_lv}$CURRENT_BRANCH${gl_bai}"

# 检查远程是否有更新
echo -e "${gl_bai}正在拉取最新的远程信息${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
git fetch origin

# 比较本地分支和远程分支的差异
LOCAL_COMMIT=$(git rev-parse @ 2>/dev/null)
REMOTE_COMMIT=$(git rev-parse @{u} 2>/dev/null)
BASE_COMMIT=$(git merge-base @ @{u} 2>/dev/null)

if [[ $LOCAL_COMMIT == $REMOTE_COMMIT ]]; then
    echo -e "${gl_lv}当前分支已经是最新版本，无需更新。${gl_bai}"
elif [[ $LOCAL_COMMIT == $BASE_COMMIT ]]; then
    echo -e "${gl_bai}检测到远程有更新，正在拉取最新代码${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
    git pull origin "$CURRENT_BRANCH"
    if [[ $? -eq 0 ]]; then
        echo -e "${gl_lv}更新成功！${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    else
        echo -e "${gl_hong}更新失败，请检查错误信息。${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        exit 1
    fi
else
    echo -e "${gl_huang}警告：本地分支与远程分支存在分歧（可能有未推送的提交），请手动解决冲突后再更新。${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    exit 1
fi
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"