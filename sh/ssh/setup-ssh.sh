#!/bin/bash
# ==============================================
# 通用 Linux SSH 服务配置脚本
# 支持 Debian, Ubuntu, CentOS, RHEL, Fedora,
# Proxmox VE, FnOS, OpenSUSE, Arch Linux 等主流发行版
# ==============================================
# 版本: v2.5.2
# 更新日期: 2025-10-25
# 作者: 墨不凡
# 仓库: https://github.com/yourrepo/ssh-setup 
# ==============================================
set -e

# ---------------- 颜色定义 ----------------
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# ---------------- 日志函数 ----------------
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# -------------- 无效的输入 --------------
handle_invalid_input() {
    echo -ne "\r${gl_hong}无效的输入,请重新输入! ${gl_zi} 2 ${gl_hong} 秒后返回"
    sleep 1
    echo -ne "\r${gl_huang}无效的输入,请重新输入! ${gl_zi} 1 ${gl_huang} 秒后返回"
    sleep 1
    echo -e "\r${gl_lv}无效的输入,请重新输入! ${gl_zi}0${gl_lv} 秒后返回"
    sleep 0.5
    return 2
}

# -------------- 按任意键继续 --------------
break_end() {
    echo -e "${gl_lv}操作完成${gl_bai}"
    echo -e "${gl_bai}按任意键继续${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai} \c"
    read -r -n 1 -s -r -p ""
    echo ""
    clear
}

# -------------- 退出脚本 --------------
exit_script() {
    clear
    echo -ne "\r${gl_hong}感谢使用，再见！ ${gl_zi}2${gl_hong} 秒后自动退出${gl_bai}"
    sleep 1
    echo -ne "\r${gl_huang}感谢使用，再见！ ${gl_zi}1${gl_huang} 秒后自动退出${gl_bai}"
    sleep 1
    echo -e "\r${gl_lv}感谢使用，再见！ ${gl_zi}0${gl_lv} 秒后自动退出${gl_bai}"
    sleep 0.5
    clear
    exit 0
}

# -------------- 欢迎信息 --------------
show_welcome() {
    clear
    echo -e ""
    echo -e "${gl_zi}>>> 配置 SSH 服务${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    log_info "脚本功能:"
    echo "  • 自动检测 Linux 发行版并安装 SSH 服务"
    echo "  • 配置 SSH 基本参数和优化设置"
    echo "  • 配置防火墙允许 SSH 连接"
    echo "  • 启动并启用 SSH 服务"
    echo ""
    log_info "支持的系统:"
    echo "  • Debian 及其衍生版 (Ubuntu, Proxmox VE, FnOS)"
    echo "  • Red Hat 系 (CentOS, RHEL, Fedora, Rocky Linux)"
    echo "  • SUSE 系 (OpenSUSE, SUSE Linux Enterprise)"
    echo "  • Arch Linux 及其衍生版"
    echo ""
    log_warn "注意:"
    echo "  • 此脚本需要 root 权限运行"
    echo "  • 脚本会修改 SSH 配置并开放防火墙"
    echo "  • 默认配置允许 root 登录，建议后续修改为更安全的设置"
    echo ""
    log_warn "安全建议:"
    echo "  • 更改默认 SSH 端口"
    echo "  • 禁用 root 登录并使用普通用户"
    echo "  • 使用密钥认证替代密码认证"
    echo "  • 限制可登录的用户和IP范围"
    echo "  • 考虑安装 Fail2Ban 防止暴力破解"
    echo -e "${gl_bufan}=============================================="
    break_end
}


# -------------- 交互输入端口 --------------
ask_ssh_port() {
    clear
    echo ""
    echo -e "${gl_huang}>>> 配置 SSH 端口${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"

    local port_input
    while true; do
        read -r -e -p "$(echo -e "${gl_bai}请输入 SSH 端口 (回车默认 ${gl_huang}22${gl_bai}): ")" port_input
        echo ""

        # 默认
        [[ -z "$port_input" ]] && { SSH_PORT=22; break; }

        # 校验
        if [[ "$port_input" =~ ^[1-9][0-9]{0,4}$ ]] && (( port_input <= 65535 )); then
            SSH_PORT=$port_input
            break
        else
            log_error "端口格式非法，请重新输入！"
        fi
    done
    log_info "使用 SSH 端口: $SSH_PORT"
}

# -------------- 检测发行版 --------------
detect_os() {
    log_info "检测操作系统..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        OS_NAME=$PRETTY_NAME
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        OS_VERSION=$(lsb_release -sr)
        OS_NAME=$(lsb_release -sd)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        OS_VERSION=$DISTRIB_RELEASE
        OS_NAME=$DISTRIB_DESCRIPTION
    elif [ -f /etc/debian_version ]; then
        OS=debian
        OS_VERSION=$(cat /etc/debian_version)
        OS_NAME="Debian $OS_VERSION"
    elif [ -f /etc/redhat-release ]; then
        OS=$(awk '{print tolower($1)}' /etc/redhat-release)
        OS_VERSION=$(awk '{print $3}' /etc/redhat-release)
        OS_NAME=$(cat /etc/redhat-release)
    else
        log_error "无法检测操作系统"; exit 1
    fi
    log_info "检测到操作系统: $OS_NAME"
}

# -------------- 安装 SSH --------------
install_ssh() {
    log_info "开始安装 SSH 服务..."
    case $OS in
        debian|ubuntu|linuxmint)
            apt-get update -qq
            apt-get install -y openssh-server
            ;;
        centos|rhel|fedora|rocky|almalinux)
            if command -v dnf >/dev/null 2>&1; then
                dnf install -y openssh-server
            else
                yum install -y openssh-server
            fi
            ;;
        opensuse*|suse*)
            zypper install -y openssh
            ;;
        arch|manjaro)
            pacman -Syu --noconfirm openssh
            ;;
        *)
            log_error "不支持的发行版: $OS"; exit 1
            ;;
    esac
    log_ok "SSH 服务安装完成"
}

# -------------- 关键配置缺省值表 --------------
# 先占位，等 ask_ssh_port 后再填值
declare -A SSH_DEF

# -------------- 配置 SSH（自动补写缺省值） --------------
configure_ssh() {
    log_info "开始配置 SSH 服务..."
    [ -f /etc/ssh/sshd_config ] && \
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

    # 确保 SSH_PORT 已赋值
    SSH_DEF=(
        ["Port"]="$SSH_PORT"
        ["PermitRootLogin"]="yes"
        ["GSSAPIAuthentication"]="no"
        ["PrintMotd"]="no"
        ["PrintLastLog"]="no"
        ["TCPKeepAlive"]="no"
        ["Compression"]="delayed"
        ["ClientAliveInterval"]="30"
        ["ClientAliveCountMax"]="120"
        ["UseDNS"]="no"
        ["X11Forwarding"]="no"
    )

    # 1. 备份（时间戳精确到秒，避免重复跑脚本时覆盖）
    cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%Y%m%d_%H%M%S)"

    # 2. 删除空行（包括只含空格/Tab 的空行）
    sed -i '/^[[:space:]]*$/d' /etc/ssh/sshd_config

    # 3. 删除纯注释行（# 可以出现在行首或在任意空白之后）
    sed -i '/^[[:space:]]*#/d' /etc/ssh/sshd_config

    # 1. 先删掉所有“相同关键词”的已注释/未注释行，防止重复
    for key in "${!SSH_DEF[@]}"; do
        sed -i "/^[[:space:]]*#*[[:space:]]*$key[[:space:]]/d" /etc/ssh/sshd_config
    done

    sed -i "/[[:space:]]*自动补写缺省值/d" /etc/ssh/sshd_config

    # 2. 追加缺省值
    echo "" >> /etc/ssh/sshd_config
    echo "# ==== 自动补写缺省值 $(date +%F' '%T) ====" >> /etc/ssh/sshd_config
    for key in "${!SSH_DEF[@]}"; do
        printf "%-25s %s\n" "$key" "${SSH_DEF[$key]}" >> /etc/ssh/sshd_config
    done

    log_ok "SSH 配置已更新/补全"
}

# -------------- 配置防火墙 --------------
configure_firewall() {
    log_info "开始配置防火墙..."
    if command -v ufw >/dev/null 2>&1; then
        ufw allow "$SSH_PORT"/tcp
        echo "y" | ufw enable
    elif command -v firewall-cmd >/dev/null 2>&1; then
        systemctl enable --now firewalld
        firewall-cmd --permanent --add-port="$SSH_PORT"/tcp
        firewall-cmd --reload
    elif command -v iptables >/dev/null 2>&1; then
        iptables -A INPUT -p tcp --dport "$SSH_PORT" -j ACCEPT
        mkdir -p /etc/iptables
        iptables-save > /etc/iptables/rules.v4
    else
        log_warn "未找到支持的防火墙工具，请手动配置"
    fi
    log_ok "防火墙配置完成"
}

# -------------- 修改 root 密码 --------------
ask_root_password() {
    echo ""
    echo -e "${gl_huang}>>> 修改 root 密码${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    read -r -e -p "$(echo -e "${gl_bai}修改 root 密码？(${gl_lv}Y${gl_hong}/${gl_huang}n${gl_bai} 回车跳过): ")" -re ans
    echo -e "${gl_bai}"
    case "${ans,,}" in
        y|yes)
            while true; do
                read -s -p "请输入新密码: " -re pw1; echo
                read -s -p "请再次输入新密码: " -re pw2; echo
                if [ "$pw1" = "$pw2" ]; then
                    echo "root:$pw1" | chpasswd 2>/dev/null && {
                        log_ok "root 密码已更新。"; break
                    } || log_warn "密码设置失败（可能过于简单），请重试。"
                else
                    log_warn "两次输入不一致，请重新输入！"
                fi
            done
            ;;
        *) log_info "已跳过 root 密码修改。" ;;
    esac
}

# -------------- 启动 SSH 服务 --------------
start_ssh_service() {
    log_info "启动/重启 SSH 服务..."
    case $OS in
        debian|ubuntu|linuxmint|opensuse*|suse*|arch|manjaro)
            systemctl enable ssh
            systemctl restart ssh
            systemctl status ssh --no-pager -l
            ;;
        centos|rhel|fedora|rocky|almalinux)
            systemctl enable sshd
            systemctl restart sshd
            systemctl status sshd --no-pager -l
            ;;
        *)
            log_error "不支持的发行版: $OS"; exit 1
            ;;
    esac
    log_ok "SSH 服务已重启并生效"
}

# -------------- 回显关键配置 --------------
show_ssh_changes() {
    echo ""
    echo -e "${gl_huang}>>> 本次脚本涉及的关键配置："
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    grep -E '^(Port|PermitRootLogin|GSSAPIAuthentication|UseDNS|Compression|ClientAliveInterval|ClientAliveCountMax|TCPKeepAlive|PrintMotd|PrintLastLog|X11Forwarding)[[:space:]]' /etc/ssh/sshd_config
}

# -------------- 连接信息 --------------
show_connection_info() {
    local ip=$(hostname -I | awk '{print $1}')
    echo ""
    echo -e "${gl_huang}>>> 连接信息："
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    echo -e "  配置文件: ${gl_lv}/etc/ssh/sshd_config${gl_bai}"
    echo -e "  服务器IP: ${gl_lv}$ip${gl_bai}"
    echo -e "  SSH 端口: ${gl_lv}$SSH_PORT${gl_bai}"
    echo -e "  连接命令: ${gl_lv}ssh -p $SSH_PORT root@$ip${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
}

# -------------- 主入口 --------------
main() {
    show_welcome
    [ "$(id -u)" -ne 0 ] && { log_error "请使用 root 运行本脚本"; exit 1; }

    ask_ssh_port
    detect_os
    install_ssh
    configure_ssh
    configure_firewall
    ask_root_password
    start_ssh_service
    show_ssh_changes
    show_connection_info
    log_ok "全部配置完成！"
}

main "$@"