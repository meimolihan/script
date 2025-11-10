#!/bin/bash

# 定义显示系统信息的函数
show_system_info() {
    # 🌈 颜色定义
    RED='\033[1;31m' # 红色 - 用于错误消息或重要警告
    GREEN='\033[1;32m' # 绿色 - 用于成功消息或通过状态
    BLUE='\033[1;34m' # 蓝色 - 用于信息消息或一般提示
    PURPLE='\033[1;35m' # 紫色 - 用于特殊提示或次要信息
    YELLOW='\033[1;33m' # 黄色 - 用于警告消息或注意事项
    NC='\033[0m' # 无色/重置 - 用于重置终端颜色到默认状态

    # ================== 欢迎语（仅此处显示一次）==================
    echo -e "${PURPLE}"
    cat <<'WELCOME'
                 _            __             
 _ __ ___   ___ | |__  _   _ / _| __ _ _ __  
| '_ ` _ \ / _ \| '_ \| | | | |_ / _` | '_ \ 
| | | | | | (_) | |_) | |_| |  _| (_| | | | |
|_| |_| |_|\___/|_.__/ \__,_|_|  \__,_|_| |_|

WELCOME
    echo -e "${NC}"
    # ============================================

    echo -e "${GREEN}命令行输入${YELLOW}g${GREEN}可快速启动脚本${NC}"
    echo -e "${GREEN}命令行输入${YELLOW}g up${GREEN}可强制更新脚本${NC}"

    # 📊 获取系统信息函数
    get_local_ip() {
        ip -o -4 addr show scope global 2>/dev/null | awk '{print $4}' | cut -d'/' -f1 | head -n1 || echo "N/A"
    }

    get_cpu_usage() {
        top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{printf "%.2f%%", 100 - $8}' || echo "N/A"
    }

    get_uptime() {
        uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
        if [ -n "$uptime_seconds" ]; then
            hours=$((uptime_seconds / 3600))
            minutes=$(( (uptime_seconds % 3600) / 60 ))
            echo "${hours}时 ${minutes}分"
        else
            echo "N/A"
        fi
    }

    # 🎨 显示系统信息
    echo -e "${GREEN}-----------系统信息-----------${NC}"
    echo -e "${BLUE}主机名称 : ${RED}$(hostname)${NC}"
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

# 更新脚本函数
update_script() {
    echo -e "\033[1;33m正在更新脚本...\033[0m"
    
    # 获取当前脚本的路径（如果是通过别名执行的）
    local update_url="https://gitee.com/meimolihan/script/raw/master/sh/install/check.sh"
    
    # 执行更新命令
    if bash <(curl -sL "$update_url"); then
        echo -e "\033[1;32m脚本更新成功！\033[0m"
        # 重新加载脚本（如果通过别名调用）
        if alias g >/dev/null 2>&1; then
            source ~/.bashrc 2>/dev/null || source ~/.bash_profile 2>/dev/null || source ~/.zshrc 2>/dev/null
        fi
    else
        echo -e "\033[1;31m脚本更新失败！请检查网络连接。\033[0m"
        return 1
    fi
}

# 主函数
main() {
    # 检查参数
    if [ "$1" = "up" ] || [ "$1" = "update" ]; then
        update_script
        return $?
    fi
    
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
}

# 执行主函数并传递所有参数
main "$@"