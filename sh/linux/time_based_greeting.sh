#!/bin/bash
# 根据计算机当前时间返回问候语，并自动配置为开机启动
# 00-12点为早晨，12-18点为下午，18-24点为晚上

# 确定当前使用的 shell
current_shell=$(basename "$SHELL")

# 根据 shell 类型选择配置文件
if [ "$current_shell" = "bash" ]; then
    config_file="$HOME/.bashrc"
elif [ "$current_shell" = "zsh" ]; then
    config_file="$HOME/.zshrc"
else
    config_file=""  # 不支持的 shell，跳过自动配置
fi

# 检查是否已配置开机启动
if [ -n "$config_file" ] && ! grep -q "script.meimolihan.eu.org/sh/linux/time_based_greeting.sh" "$config_file"; then
    # 未配置，则自动添加到配置文件
    echo 'bash <(curl -sL script.meimolihan.eu.org/sh/linux/time_based_greeting.sh)' >> "$config_file"
    echo -e "\033[32m已自动配置开机启动！下次打开终端时将显示问候信息。\033[0m"
fi

# 主功能：显示基于时间的问候语
tm=$(date +%H)
if [ $tm -le 12 ]; then
    msg="早上好，$USER"
elif [ $tm -gt 12 -a $tm -le 18 ]; then
    msg="下午好，$USER"
else
    msg="晚上好，$USER"
fi
echo "当前时间是：$(date +"%Y年%m月%d日 %H时%M分%S秒")"
echo -e "\033[34m$msg\033[0m"