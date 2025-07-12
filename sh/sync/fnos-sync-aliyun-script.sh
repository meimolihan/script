#!/bin/bash

# 脚本名称：fnos_sync.sh
# 功能：自动登录FnOS服务器并执行rsync同步命令

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
echo -e "${GREEN}===== FnOS服务器数据同步工具 ====${NC}"
print_separator
echo -e "${YELLOW}此脚本将登录FnOS服务器并执行以下同步命令：${NC}"
echo -e "${YELLOW}rsync -avhzp --progress --delete /vol2/1000/阿里云盘/ /vol2/1000/samba/win11-D/${NC}"
echo -e "${RED}警告：此命令会删除目标目录中源目录不存在的文件！${NC}"
print_separator

# 询问用户是否继续
read -p "是否继续执行同步操作？(y/n): " choice

case "$choice" in
  y|Y )
    echo -e "${GREEN}开始连接到FnOS服务器...${NC}"
    print_separator
    
    # 连接到FnOS服务器并执行rsync命令
    ssh fnos "rsync -avhz --progress --delete-delay /vol2/1000/阿里云盘/ /vol2/1000/samba/win11-D/"
    
    # 检查命令执行结果
    print_separator
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}同步完成！${NC}"
    else
      echo -e "${RED}同步过程中出现错误，请检查日志。${NC}"
    fi
    ;;
  n|N )
    echo -e "${YELLOW}操作已取消。${NC}"
    ;;
  * )
    echo -e "${RED}无效的选择，操作已取消。${NC}"
    ;;
esac

print_separator
press_any_key
echo
