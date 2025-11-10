#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取内网IP地址
get_internal_ip() {
    local ip=""
    # 尝试多种方法获取内网IP
    if command -v hostname >/dev/null 2>&1; then
        ip=$(hostname -I | awk '{print $1}')
    elif command -v ip >/dev/null 2>&1; then
        ip=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)
    elif command -v ifconfig >/dev/null 2>&1; then
        ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
    fi
    echo "$ip"
}

# 根据IP确定默认菜单
get_default_menu() {
    local ip=$(get_internal_ip)
    case "$ip" in
        "10.10.10.254") echo "pve" ;;
        "10.10.10.251") echo "fnos" ;;
        "10.10.10.246") echo "debian" ;;
        *) echo "main" ;;
    esac
}

# 切换目录并进入子shell
change_directory() {
    local path="$1"
    local description="$2"
    
    if [ -d "$path" ]; then
        cd "$path"
        echo -e "${GREEN}成功切换到: $description${NC}"
        echo -e "${GREEN}当前目录: $(pwd)${NC}"
        echo -e "${YELLOW}现在您可以在此目录执行命令，输入 'exit' 返回菜单${NC}"
        echo "----------------------------------------"
        bash
    else
        echo -e "${RED}错误: 目录不存在 - $path${NC}"
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    fi
}

# PVE 系统目录菜单
show_pve_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "            PVE 系统目录"
        echo "========================================"
        echo -e "${NC}"
        echo -e "${YELLOW}当前目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要进入的目录：${NC}"
        echo -e "${CYAN}1. ISO 镜像目录${NC}"
        echo -e "${CYAN}2. 容器模板目录${NC}"
        echo -e "${CYAN}3. 虚拟机磁盘目录${NC}"
        echo -e "${CYAN}4. 虚拟机备份目录${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        read -p "请输入选择 [0-4]: " choice
        
        case $choice in
            1) change_directory "/var/lib/vz/template/iso" "PVE ISO 镜像目录" ;;
            2) change_directory "/var/lib/vz/template/cache" "PVE 容器模板目录" ;;
            3) change_directory "/var/lib/vz/images" "PVE 虚拟机磁盘目录" ;;
            4) change_directory "/var/lib/vz/dump" "PVE 虚拟机备份目录" ;;
            0) break ;;
            *) echo -e "${RED}无效的选择，请重新输入${NC}"; sleep 1 ;;
        esac
    done
}

# FnOS 系统目录菜单
show_fnos_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "            FnOS 系统目录"
        echo "========================================"
        echo -e "${NC}"
        echo -e "${YELLOW}当前目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要进入的目录：${NC}"
        echo -e "${CYAN}1. Compose 目录${NC}"
        echo -e "${CYAN}2. 影视目录${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        read -p "请输入选择 [0-2]: " choice
        
        case $choice in
            1) change_directory "/vol1/1000/compose" "FnOS Compose 目录" ;;
            2) change_directory "/vol2/1000/光影集" "FnOS 影视目录" ;;
            0) break ;;
            *) echo -e "${RED}无效的选择，请重新输入${NC}"; sleep 1 ;;
        esac
    done
}

# Debian 系统目录菜单
show_debian_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "            Debian 系统目录"
        echo "========================================"
        echo -e "${NC}"
        echo -e "${YELLOW}当前目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要进入的目录：${NC}"
        echo -e "${CYAN}1. Compose 目录${NC}"
        echo -e "${CYAN}2. Nginx 主目录${NC}"
        echo -e "${CYAN}3. Nginx 配置文件目录${NC}"
        echo -e "${CYAN}4. Nginx 站点根目录${NC}"
        echo -e "${CYAN}5. Nginx 日志目录${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        read -p "请输入选择 [0-5]: " choice
        
        case $choice in
            1) change_directory "/mnt/compose" "Debian Compose 目录" ;;
            2) change_directory "/etc/nginx" "Nginx 主目录" ;;
            3) change_directory "/etc/nginx/conf.d" "Nginx 配置文件目录" ;;
            4) change_directory "/etc/nginx/html" "Nginx 站点根目录" ;;
            5) change_directory "/etc/nginx/log/mobufan.eu.org" "Nginx 日志目录" ;;
            0) break ;;
            *) echo -e "${RED}无效的选择，请重新输入${NC}"; sleep 1 ;;
        esac
    done
}

# 主菜单
show_main_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "          Linux目录切换工具"
        echo "========================================"
        echo -e "${NC}"
        echo -e "${YELLOW}当前目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要进入的系统目录：${NC}"
        echo -e "${CYAN}1. PVE 系统目录${NC}"
        echo -e "${CYAN}2. FnOS 系统目录${NC}"
        echo -e "${CYAN}3. Debian 系统目录${NC}"
        echo -e "${RED}0. 退出脚本${NC}"
        echo "========================================"
        read -p "请输入选择 [0-3]: " choice
        
        case $choice in
            1) show_pve_menu ;;
            2) show_fnos_menu ;;
            3) show_debian_menu ;;
            0) 
                echo -e "${GREEN}感谢使用，再见！${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}无效的选择，请重新输入${NC}"
                sleep 1
                ;;
        esac
    done
}

# 主程序
main() {
    # 获取默认菜单
    local default_menu=$(get_default_menu)
    local ip=$(get_internal_ip)
    
    # 显示欢迎信息
    clear
    echo -e "${GREEN}"
    echo "========================================"
    echo "          Linux目录切换工具"
    echo "========================================"
    echo -e "${NC}"
    echo -e "${BLUE}检测到内网IP: ${ip}${NC}"
    
    case "$default_menu" in
        "pve") 
            echo -e "${YELLOW}根据IP地址，自动进入 PVE 系统目录${NC}"
            echo "----------------------------------------"
            echo -e "${CYAN}2秒后自动进入 PVE 菜单...${NC}"
            echo -e "${CYAN}按任意键跳过等待并选择菜单${NC}"
            echo "========================================"
            
            # 等待2秒，如果用户按键则进入主菜单
            if read -t 2 -n 1; then
                echo -e "\n${YELLOW}跳过自动选择，进入主菜单${NC}"
                sleep 1
                show_main_menu
            else
                show_pve_menu
            fi
            ;;
        "fnos")
            echo -e "${YELLOW}根据IP地址，自动进入 FnOS 系统目录${NC}"
            echo "----------------------------------------"
            echo -e "${CYAN}2秒后自动进入 FnOS 菜单...${NC}"
            echo -e "${CYAN}按任意键跳过等待并选择菜单${NC}"
            echo "========================================"
            
            # 等待2秒，如果用户按键则进入主菜单
            if read -t 2 -n 1; then
                echo -e "\n${YELLOW}跳过自动选择，进入主菜单${NC}"
                sleep 1
                show_main_menu
            else
                show_fnos_menu
            fi
            ;;
        "debian")
            echo -e "${YELLOW}根据IP地址，自动进入 Debian 系统目录${NC}"
            echo "----------------------------------------"
            echo -e "${CYAN}2秒后自动进入 Debian 菜单...${NC}"
            echo -e "${CYAN}按任意键跳过等待并选择菜单${NC}"
            echo "========================================"
            
            # 等待2秒，如果用户按键则进入主菜单
            if read -t 2 -n 1; then
                echo -e "\n${YELLOW}跳过自动选择，进入主菜单${NC}"
                sleep 1
                show_main_menu
            else
                show_debian_menu
            fi
            ;;
        *)
            echo -e "${YELLOW}未识别到特定系统，进入主菜单${NC}"
            echo "========================================"
            show_main_menu
            ;;
    esac
    
    # 如果从子菜单返回，则显示主菜单
    show_main_menu
}

# 运行主程序
main
