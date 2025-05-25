#!/bin/bash

# 设置当前目录为搜索起点
SEARCH_DIR=$PWD

echo "开始检查目录 $SEARCH_DIR 下的所有 Git 仓库..."

# 查找当前目录及其子目录中的所有 .git 文件夹
find "$SEARCH_DIR" -type d -name ".git" -print0 | while IFS= read -r -d '' git_dir; do
    # 获取仓库目录（.git 的父目录）
    repo_dir=$(dirname "$git_dir")
    
    echo "--------------------------------------------------"
    echo "正在检查仓库：$repo_dir"
    
    # 进入仓库目录
    cd "$repo_dir" || continue
    
    # 获取当前分支名称
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -z "$CURRENT_BRANCH" ]]; then
        echo "  警告：无法获取当前分支信息，跳过此仓库"
        cd - >/dev/null || exit
        continue
    fi
    
    echo "  当前分支：$CURRENT_BRANCH"
    
    # 检查远程是否有更新
    echo "  正在拉取最新的远程信息..."
    git fetch origin
    
    # 比较本地分支和远程分支的差异
    LOCAL_COMMIT=$(git rev-parse @ 2>/dev/null)
    REMOTE_COMMIT=$(git rev-parse @{u} 2>/dev/null 2>/dev/null)
    BASE_COMMIT=$(git merge-base @ @{u} 2>/dev/null)
    
    if [[ -z "$REMOTE_COMMIT" ]]; then
        echo "  警告：此分支没有设置上游分支，跳过更新"
    elif [[ $LOCAL_COMMIT == $REMOTE_COMMIT ]]; then
        echo "  当前分支已经是最新版本，无需更新。"
    elif [[ $LOCAL_COMMIT == $BASE_COMMIT ]]; then
        echo "  检测到远程有更新，正在拉取最新代码..."
        git pull origin "$CURRENT_BRANCH"
        if [[ $? -eq 0 ]]; then
            echo "  更新成功！"
        else
            echo "  更新失败，请检查错误信息。"
        fi
    else
        echo "  警告：本地分支与远程分支存在分歧（可能有未推送的提交），请手动解决冲突后再更新。"
    fi
    
    # 返回原始目录
    cd - >/dev/null || exit
done

echo "--------------------------------------------------"
echo "所有 Git 仓库检查完成！"