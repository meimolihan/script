#!/bin/bash

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 获取当前目录
CURRENT_DIR=$(pwd)
echo -e "${GREEN}开始扫描目录: $CURRENT_DIR${NC}"

# 查找所有.git目录
find "$CURRENT_DIR" -type d -name ".git" | while read -r GIT_DIR; do
    REPO_DIR=$(dirname "$GIT_DIR")
    echo -e "\n${YELLOW}=======================================${NC}"
    echo -e "${GREEN}处理仓库: $REPO_DIR${NC}"
    
    # 进入仓库目录
    cd "$REPO_DIR" || {
        echo -e "${RED}无法进入目录，跳过${NC}"
        continue
    }

    # 检查Git配置
    if ! git config user.name &>/dev/null || ! git config user.email &>/dev/null; then
        echo -e "${YELLOW}警告: 未配置Git用户信息，跳过${NC}"
        continue
    fi

    # 检查远程仓库是否存在
    if ! git remote get-url origin &>/dev/null; then
        echo -e "${YELLOW}警告: 未配置远程仓库origin，跳过${NC}"
        continue
    fi

    # 检查工作区/暂存区变更
    CHANGES=$(git status --porcelain)
    if [ -z "$CHANGES" ]; then
        echo -e "${GREEN}没有检测到变更${NC}"
    else
        # 处理变更
        echo -e "${YELLOW}检测到变更:${NC}"
        git status --short

        # 添加所有变更（包括未跟踪文件）
        echo -e "${YELLOW}添加所有变更到暂存区...${NC}"
        git add --all || {
            echo -e "${RED}添加文件失败，跳过${NC}"
            continue
        }

        # 提交变更
        echo -e "${YELLOW}提交变更...${NC}"
        git commit -m "自动提交: $(date +'%Y-%m-%d %H:%M:%S')" || {
            echo -e "${RED}提交失败，跳过${NC}"
            continue
        }
    fi

    # 检查是否需要推送（本地有未推送的提交）
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})

    if [ "$LOCAL" = "$REMOTE" ]; then
        echo -e "${GREEN}本地分支与远程分支同步，无需推送${NC}"
    else
        # 推送到远程
        echo -e "${YELLOW}推送到远程仓库...${NC}"
        if git push; then
            echo -e "${GREEN}推送成功${NC}"
        else
            echo -e "${RED}推送失败${NC}"
            # 尝试使用git协议作为备用方案
            REMOTE_URL=$(git config --get remote.origin.url)
            if [[ "$REMOTE_URL" == https://* ]]; then
                echo -e "${YELLOW}尝试切换为git协议...${NC}"
                GIT_URL="${REMOTE_URL/https:\/\//git@}"
                GIT_URL="${GIT_URL/\//:}"
                git remote set-url origin "$GIT_URL"
                git push && echo -e "${GREEN}协议切换后推送成功${NC}" || echo -e "${RED}仍然失败，请手动检查${NC}"
            fi
        fi
    fi
done

echo -e "\n${YELLOW}=======================================${NC}"
echo -e "${GREEN}所有仓库处理完成${NC}"