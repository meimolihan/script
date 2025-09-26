#!/bin/bash

# 定义变量
SCRIPT_URL="https://gitee.com/meimolihan/script/raw/master/sh/ssl/check-ssl.sh"
TARGET_PATH="/etc/profile.d/check-ssl.sh"
LINK_PATH="/usr/local/bin/m"

# 下载脚本
echo "正在下载脚本..."
sudo curl -fsSL "$SCRIPT_URL" -o "$TARGET_PATH"

# 检查下载是否成功
if [[ ! -f "$TARGET_PATH" ]]; then
    echo "下载失败，请检查网络或 URL 是否有效。"
    exit 1
fi

# 赋予可执行权限
sudo chmod +x "$TARGET_PATH"

# 创建软链接
sudo ln -sf "$TARGET_PATH" "$LINK_PATH"

# 执行脚本
echo "正在执行脚本..."
bash "$TARGET_PATH"