#!/bin/bash

# 定义显示系统信息的函数
show_system_info() {
    # 🌈 颜色定义
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    BLUE='\033[1;34m'
    NC='\033[0m' # No Color

    # 📊 获取系统信息函数
    get_local_ip() {
        ip -o -4 addr show scope global 2>/dev/null | awk '{print $4}' | cut -d'/' -f1 | head -n1 || echo "N/A"
    }

    get_cpu_usage() {
        top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{printf "%.2f%%", 100 - $8}' || echo "N/A"
    }

    get_uptime() {
        # 获取系统运行时间（秒）
        uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
        if [ -n "$uptime_seconds" ]; then
            # 计算小时和分钟
            hours=$((uptime_seconds / 3600))
            minutes=$(( (uptime_seconds % 3600) / 60 ))
            echo "${hours}时 ${minutes}分"
        else
            echo "N/A"
        fi
    }

    # 🎨 显示系统信息
    echo -e "${GREEN}-----------系统信息-----------${NC}"
    echo -e "${BLUE}主机名称 : ${RED}$(cat /proc/sys/kernel/hostname 2>/dev/null || echo "Unknown")${NC}"
    echo -e "${BLUE}内核版本 : ${RED}$(uname -r)${NC}"
    
    echo -e "${GREEN}-----------CPU 信息-----------${NC}"
    echo -e "${BLUE}CPU 架构 : ${RED}$(uname -m)${NC}"
    echo -e "${BLUE}CPU 占用 : ${RED}$(get_cpu_usage)${NC}"
    
    echo -e "${GREEN}-----------网络信息-----------${NC}"
    echo -e "${BLUE}IPV4内网 : ${RED}$(get_local_ip)${NC}"
    echo -e "${BLUE}默认网关 : ${RED}$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -n1 || echo "N/A")${NC}"
    
    echo -e "${GREEN}-----------磁盘信息-----------${NC}"
    echo -e "${BLUE}磁盘占用 : ${RED}$(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}' 2>/dev/null || echo "N/A")${NC}"
    echo -e "${BLUE}运行时间 : ${RED}$(get_uptime)${NC}"
    
    echo -e "${GREEN}-----------------------------${NC}"
}

# 检查是否在交互式 shell 中执行
if [[ $- == *i* ]]; then
    # 🛡️ 防止重复执行（仅在交互式登录Shell显示一次）
    if [ -z "$LINUX_CHECK_SHOWN" ]; then
        show_system_info
        export LINUX_CHECK_SHOWN=1
    fi
else
    # 非交互式 shell（直接执行脚本时）
    show_system_info
fi
