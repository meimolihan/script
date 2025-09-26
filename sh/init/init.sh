#!/usr/bin/env bash
#==============================================================================
#  跨发行版 Linux 基础工具一键安装脚本
#  作者：you
#  日期：2025-09-25
#  许可证：MIT  -  自由使用，风险自负
#==============================================================================
#  支持列表：
#    Debian/Ubuntu/Kali/Raspbian  ...  apt
#    RHEL/CentOS 7/8、Fedora       ...  dnf(yum)
#    Arch Linux/Manjaro            ...  pacman
#    Alpine                        ...  apk
#
#  脚本行为：
#    1. 自动识别包管理器并更新索引
#    2. 安装下列工具（如已存在则跳过）：
#       nano git rsync bash zip openssh wget tree
#       samba nfs-utils unrar（名称已自动映射）
#    3. 全系统升级
#    4. 清理缓存与无用包
#  注意事项：
#    * 需 root 或 sudo 运行
#    * 会二次确认，防止误操作
#==============================================================================
set -euo pipefail

########################  中文彩色日志  ########################
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[信息]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[警告]${NC} $*"; }
log_error() { echo -e "${RED}[错误]${NC} $*"; }

########################  必须 root  ########################
[[ $EUID -eq 0 ]] || { log_error "请使用 root 或 sudo 运行"; exit 1; }

########################  识别发行版与包管理器  ########################
if   command -v apt-get      >/dev/null 2>&1; then PM="apt"
elif command -v dnf          >/dev/null 2>&1; then PM="dnf"
elif command -v yum          >/dev/null 2>&1; then PM="yum"
elif command -v pacman       >/dev/null 2>&1; then PM="pacman"
elif command -v apk          >/dev/null 2>&1; then PM="apk"
else
    log_error "未检测到支持的包管理器（apt/dnf/yum/pacman/apk）"
    exit 1
fi
log_info "检测到包管理器：$PM"

########################  按发行版定义软件包名  ########################
case "$PM" in
    apt)
        PKGS="nano git rsync bash zip openssh-server wget tree samba nfs-kernel-server nfs-common unrar-free"
        UPDATE="apt update"
        UPGRADE="apt -y full-upgrade"
        CLEAN="apt -y autoremove && apt clean"
        ;;
    dnf|yum)
        PKGS="nano git rsync bash zip openssh wget tree samba nfs-utils unrar"
        [[ "$PM" == "dnf" ]] && UPDATE="dnf makecache" || UPDATE="yum makecache"
        UPGRADE="$PM -y upgrade"
        CLEAN="$PM -y autoremove && $PM clean all"
        ;;
    pacman)
        PKGS="nano git rsync bash zip openssh wget tree samba nfs-utils unrar"
        UPDATE="pacman -Sy --noconfirm"
        UPGRADE="pacman -Su --noconfirm"
        CLEAN="pacman -Sc --noconfirm"
        ;;
    apk)
        PKGS="nano git rsync bash zip openssh wget tree samba nfs-utils unrar"
        UPDATE="apk update"
        UPGRADE="apk upgrade --no-cache"
        CLEAN="apk cache clean"
        ;;
esac

########################  欢迎语与二次确认  ########################
cat << EOF
+----------------------------------------------------------+
|                                                          |
|        Linux 基础工具一键安装脚本（跨发行版）            |
|                                                          |
|   即将在“${PM}”系系统上执行：                              |
|    * 更新软件源                                          |
|    * 安装：nano git rsync bash zip openssh wget tree     |
|             samba nfs-utils unrar（名称已自动映射）      |
|    * 全系统升级                                          |
|    * 清理缓存与无用包                                    |
|                                                          |
+----------------------------------------------------------+
EOF
read -rp "是否继续执行？ [y/N] " choice
[[ "$choice" =~ ^[Yy]$ ]] || { log_info "用户取消，脚本退出"; exit 0; }

########################  开始执行  ########################
echo "----------------------------------------------------------"
log_info "【1/5】更新软件源索引 ..."
eval "$UPDATE"

echo "----------------------------------------------------------"
log_info "【2/5】安装基础工具 ..."
case "$PM" in
    pacman) pacman -S --needed --noconfirm $PKGS ;;
    apk)    apk add --no-cache $PKGS ;;
    *)      $PM -y install $PKGS ;;
esac

echo "----------------------------------------------------------"
log_info "【3/5】全系统升级 ..."
eval "$UPGRADE"

echo "----------------------------------------------------------"
log_info "【4/5】清理无用包与缓存 ..."
eval "$CLEAN"

echo "----------------------------------------------------------"
########################  完成  ########################
log_info ">> 全部步骤执行完毕！系统已更新，所需工具亦安装完成。"
echo "=========================================================="