#!/bin/bash
# ***************************************************************
#  File: auto_keypush.sh
#  Desc: 免交互生成 SSH 密钥并批量分发到多台主机
#  使用方法:
#       chmod +x auto_keypush.sh
#       ./auto_keypush.sh 251 252
# ***************************************************************

############################  用户可调变量  ############################
USER="root"                                  # 远程登录用户
PASS="yifan0719"                        # 远程登录密码
NET="10.10.10"                            # 网段前三段
KEY_PATH="/root/.ssh/id_rsa"  # 本机密钥保存路径
########################################################################

# 0. 欢迎语与用法提示
cat << EOF
╔══════════════════════════════════════════════════════════════╗
║                欢迎使用 SSH 密钥批量分发工具                 ║
╠══════════════════════════════════════════════════════════════╣
║  作用：一键生成本地密钥并自动分发到多台远程主机              ║
║  用法：./auto_keypush.sh <主机号> [主机号] ...               ║
║  示例：./auto_keypush.sh 251 252                             ║
╚══════════════════════════════════════════════════════════════╝
EOF

[ $# -eq 0 ] && { echo "【ERROR】未提供任何主机号，脚本终止。"; exit 1; }

# 1. 生成本机密钥（如已存在则跳过）
[ -f "$KEY_PATH" ] || {
    echo "【INFO】正在生成本地密钥 ..."
    mkdir -pm 700 "$(dirname "$KEY_PATH")"
    ssh-keygen -f "$KEY_PATH" -N '' -q
}

# 2. 自动安装 sshpass（按系统类型）
if ! command -v sshpass &>/dev/null; then
    echo "【INFO】未检测到 sshpass，正在自动安装 ..."
    if [ -f /etc/redhat-release ]; then
        yum makecache -y && yum install -y sshpass
    elif [ -f /etc/debian_version ]; then
        apt update -y && apt install -y sshpass
    elif [ -f /etc/alpine-release ]; then
        apk add --no-cache sshpass
    else
        echo "【ERROR】无法识别系统，请手动安装 sshpass 后再执行脚本"
        exit 1
    fi
fi

# 3. 循环推送公钥 + 动态打印测试命令
for SUFFIX in "$@"; do
    HOST="${NET}.${SUFFIX}"
    echo "【INFO】正在推送公钥到 ${USER}@${HOST} ..."
    if sshpass -p"$PASS" ssh-copy-id -o StrictHostKeyChecking=no \
               -i "${KEY_PATH}.pub" "${USER}@${HOST}" &>/dev/null; then
        echo "【OK  】${HOST} 完成"
        # ---- 动态打印测试命令（含分割线） ----
        printf "\033[36m%s\033[0m\n" "------------------------------------------------"
        echo -e "\033[32m【TEST】验证命令： ssh ${USER}@${HOST}\033[0m"
        printf "\033[36m%s\033[0m\n" "------------------------------------------------"
    else
        echo "【FAIL】${HOST} 失败，请检查密码或网络"
    fi
done

echo "【DONE】全部任务结束"