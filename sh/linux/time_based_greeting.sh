#!/bin/bash
# 根据计算机当前时间，返回问候语，并可自动配置为开机启动
# 00-12 点为早晨，12-18 点为下午，18-24 点为晚上
# 使用 date 命令获取时间后，if 判断时间的区间，确定问候语内容

# 自动配置开机启动功能
if [ "$1" = "--install" ]; then
    # 确定当前使用的 shell
    current_shell=$(basename "$SHELL")
    
    # 根据 shell 类型选择配置文件
    if [ "$current_shell" = "bash" ]; then
        config_file="$HOME/.bashrc"
    elif [ "$current_shell" = "zsh" ]; then
        config_file="$HOME/.zshrc"
    else
        echo "不支持的 shell: $current_shell"
        echo "请手动将以下命令添加到您的 shell 配置文件中:"
        echo "bash <(curl -sL script.meimolihan.eu.org/sh/linux/time_based_greeting.sh)"
        exit 1
    fi
    
    # 检查配置文件是否已包含该命令
    if grep -q "script.meimolihan.eu.org/sh/linux/time_based_greeting.sh" "$config_file"; then
        echo "开机启动已配置，无需重复添加"
    else
        # 添加命令到配置文件
        echo 'bash <(curl -sL script.meimolihan.eu.org/sh/linux/time_based_greeting.sh)' >> "$config_file"
        echo "已成功配置开机启动！下次打开终端时将显示问候信息。"
        echo "配置文件: $config_file"
    fi
    exit 0
fi

# 主功能：显示基于时间的问候语
tm=$(date +%H)
if [ $tm -le 12 ];then
    msg="早上好，$USER"
elif [ $tm -gt 12 -a $tm -le 18 ];then
    msg="下午好，$USER"
else
    msg="晚上好，$USER"
fi
echo "当前时间是：$(date +"%Y年%m月%d日 %H时%M分%S秒")"
echo -e "\033[34m$msg\033[0m"