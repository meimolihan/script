#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 检查是否Git仓库
check_git_repo() {
    if [ ! -d .git ] && ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}错误：当前目录不是Git仓库！${NC}"
        return 1
    fi
    return 0
}

# 显示菜单
show_menu() {
    clear
    echo -e "${GREEN}Git 仓库管理工具${NC}"
    echo -e "${BLUE}=================================${NC}"
    echo -e "1. 检查Git仓库状态"
    echo -e "2. 本地更新并推送"
    echo -e "3. 拉取远程更新"
    echo -e "0. 退出"
    echo -e "${BLUE}=================================${NC}"
    echo -n "请选择操作 [0-3]: "
}

# 检查仓库状态
show_status() {
    check_git_repo || return
    echo -e "\n${YELLOW}=== 仓库状态 ===${NC}"
    git status
    echo -e "\n${YELLOW}=== 当前分支 ===${NC}"
    git branch --show-current
    echo -e "\n${YELLOW}=== 远程仓库信息 ===${NC}"
    git remote -v
    echo -e "\n${YELLOW}=== 最后3次提交记录 ===${NC}"
    git log -3 --oneline
}

# 本地更新并推送
push_changes() {
    check_git_repo || return
    echo -e "\n${YELLOW}=== 检查本地更改 ===${NC}"
    
    # 显示未提交的更改
    changes=$(git status --porcelain)
    if [ -z "$changes" ]; then
        echo -e "${GREEN}没有需要提交的更改${NC}"
        return
    else
        echo -e "检测到以下更改："
        git status -s
    fi
    
    # 设置默认提交信息
    default_msg="update"
    echo -e "\n${YELLOW}=== 提交更改 ===${NC}"
    echo -e "请输入提交信息(直接回车使用默认值 '${BLUE}${default_msg}${NC}', 输入q返回菜单): "
    read -p "> " commit_msg
    
    if [ "$commit_msg" == "q" ]; then
        return
    fi
    
    # 使用默认信息如果用户直接回车
    if [ -z "$commit_msg" ]; then
        commit_msg="$default_msg"
        echo -e "使用默认提交信息: ${BLUE}${commit_msg}${NC}"
    fi
    
    echo -e "\n${YELLOW}=== 添加并提交更改 ===${NC}"
    git add .
    git commit -m "$commit_msg"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}提交失败！${NC}"
        return
    fi
    
    echo -e "\n${YELLOW}=== 推送到远程仓库 ===${NC}"
    current_branch=$(git branch --show-current)
    echo -e "正在推送分支: ${GREEN}$current_branch${NC} 到远程仓库..."
    git push origin "$current_branch"
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}推送成功！${NC}"
        echo -e "您可以通过以下命令查看远程状态:"
        echo -e "git remote show origin"
    else
        echo -e "\n${RED}推送失败！${NC}"
        echo -e "可能原因："
        echo -e "1. 没有网络连接"
        echo -e "2. 没有推送权限"
        echo -e "3. 远程仓库有更新未拉取"
        echo -e "建议先执行'拉取远程更新'操作后再尝试推送"
    fi
}

# 拉取远程更新
pull_updates() {
    check_git_repo || return
    echo -e "\n${YELLOW}=== 拉取远程更新 ===${NC}"
    current_branch=$(git branch --show-current)
    echo -e "正在从远程拉取分支: ${GREEN}$current_branch${NC} 的更新..."
    git pull origin "$current_branch"
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}拉取成功！${NC}"
        echo -e "建议检查仓库状态确认更新内容:"
        echo -e "git status"
    else
        echo -e "\n${RED}拉取失败！${NC}"
        echo -e "可能原因："
        echo -e "1. 没有网络连接"
        echo -e "2. 本地有未提交的更改导致冲突"
        echo -e "3. 远程仓库不存在该分支"
        echo -e "建议先提交或储藏本地更改后再尝试拉取"
    fi
}

# 主循环
while true; do
    show_menu
    read choice
    case $choice in
        1) 
            show_status 
            ;;
        2) 
            push_changes 
            ;;
        3) 
            pull_updates 
            ;;
        0) 
            echo -e "${GREEN}感谢使用Git仓库管理工具，再见！${NC}"
            exit 0 
            ;;
        *) 
            echo -e "${RED}无效选择，请重新输入！${NC}" 
            ;;
    esac
    echo -e "\n按任意键继续..."
    read -n 1 -s
done