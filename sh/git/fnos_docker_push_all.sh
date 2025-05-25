#!/bin/bash

# 脚本名称：Win11执行FnOS_docker推送.sh
# 功能：自动登录FnOS服务器并执行Git仓库推送命令

# 定义颜色输出
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

# 显示分隔线函数
function print_separator() {
    echo -e "${BLUE}=================================================================${NC}"
}

# 按任意键继续函数
function press_any_key() {
    echo -e "\n${YELLOW}按任意键退出...${NC}"
    read -n 1 -s
}

# 显示脚本开始信息
print_separator
echo -e "${GREEN}===== FnOS服务器Git仓库推送工具 ====${NC}"
print_separator
echo -e "${YELLOW}此脚本将登录FnOS服务器并执行以下Git仓库推送命令：${NC}"
echo -e "${YELLOW}cd /vol1/1000/home && bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push_all.sh)${NC}"
echo -e "${RED}警告：此命令会将本地仓库的所有更改推送到远程仓库！${NC}"
print_separator

# 开始连接到FnOS服务器...
echo -e "${GREEN}开始连接到FnOS服务器...${NC}"
print_separator

# 连接到FnOS服务器并执行Git仓库推送命令
ssh fnos "cd /vol1/1000/home && bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push_all.sh)"

# 检查命令执行结果
print_separator
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Git仓库推送完成！${NC}"
else
  echo -e "${RED}Git仓库推送过程中出现错误，请检查日志。${NC}"
fi

print_separator
press_any_key
echo
