#!/bin/bash

# 防止重复执行（仅在交互式登录Shell显示一次）
if [ -n "$LINUX_CHECK_SHOWN" ] || [ -z "$PS1" ]; then
    return 0
fi
export LINUX_CHECK_SHOWN=1

# 获取IP更稳健的方式（兼容多网卡）
get_local_ip() {
    local ip
    ip=$(ip -o -4 addr show scope global | awk '{print $4}' | cut -d'/' -f1 | head -n1)
    [ -z "$ip" ] && ip="N/A"
    echo "$ip"
}

# 获取CPU占用（兼容不同top版本）
get_cpu_usage() {
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *$$[0-9.]*$$%* id.*/\1/" | awk '{printf "%.2f%%", 100 - $1}')
    [ -z "$cpu_usage" ] && cpu_usage="N/A"
    echo "$cpu_usage"
}

# 信息输出
echo -e "\e[1;32m-----------系统信息----------\e[0m"
echo -e "\e[1;34m主机名称 : \e[1;31m$(hostname)\e[0m"
echo -e "\e[1;34m内核版本 : \e[1;31m$(uname -r)\e[0m"

echo -e "\e[1;32m-----------CPU 信息----------\e[0m"
echo -e "\e[1;34mCPU 架构 : \e[1;31m$(uname -m)\e[0m"
echo -e "\e[1;34mCPU 占用 : \e[1;31m`top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -c 1-2 | awk '{printf("%.2f%%\n", $1/100*100)}'`\e[0m"

echo -e "\e[1;32m-----------网络信息----------\e[0m"
echo -e "\e[1;34mIPV4内网 : \e[1;31m$(get_local_ip)\e[0m"
echo -e "\e[1;34m默认网关 : \e[1;31m$(ip route show default 2>/dev/null | awk '/default/ {print $3}' || echo "N/A")\e[0m"

echo -e "\e[1;32m-----------磁盘信息----------\e[0m"
echo -e "\e[1;34m磁盘占用 : \e[1;31m$(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}')\e[0m"

echo -e "\e[1;34m运行时间 : \e[1;31m$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')\e[0m"

echo -e "\e[1;32m-----------------------------\e[0m"