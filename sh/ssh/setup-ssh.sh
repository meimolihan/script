#!/bin/bash

# ==============================================
# 通用 Linux SSH 服务配置脚本
# 支持 Debian, Ubuntu, CentOS, RHEL, Fedora, 
# Proxmox VE, FnOS, OpenSUSE, Arch Linux 等主流发行版
# ==============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色

# 显示欢迎信息
show_welcome() {
    echo -e "${CYAN}"
    echo "=============================================="
    echo "          通用 Linux SSH 服务配置脚本"
    echo "=============================================="
    echo -e "${NC}"
    echo -e "${GREEN}脚本功能:${NC}"
    echo "  • 自动检测 Linux 发行版并安装 SSH 服务"
    echo "  • 配置 SSH 基本参数和优化设置"
    echo "  • 配置防火墙允许 SSH 连接"
    echo "  • 启动并启用 SSH 服务"
    echo ""
    echo -e "${GREEN}支持的系统:${NC}"
    echo "  • Debian 及其衍生版 (Ubuntu, Proxmox VE, FnOS)"
    echo "  • Red Hat 系 (CentOS, RHEL, Fedora, Rocky Linux)"
    echo "  • SUSE 系 (OpenSUSE, SUSE Linux Enterprise)"
    echo "  • Arch Linux 及其衍生版"
    echo ""
    echo -e "${YELLOW}注意:${NC}"
    echo "  • 此脚本需要 root 权限运行"
    echo "  • 脚本会修改 SSH 配置并开放防火墙"
    echo "  • 默认配置允许 root 登录，建议后续修改为更安全的设置"
    echo ""
    echo -e "${CYAN}=============================================="
    echo -e "${NC}"
}

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 确认继续
confirm_continue() {
    echo -e "${YELLOW}"
    read -p "您是否要继续执行脚本？(y/N): " -n 1 -r
    echo -e "${NC}"
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消执行脚本。"
        exit 0
    fi
    echo ""
}

# 检测发行版
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
        OS_NAME="Debian $(cat /etc/debian_version)"
    elif [ -f /etc/redhat-release ]; then
        OS=$(cat /etc/redhat-release | cut -d' ' -f1 | tr '[:upper:]' '[:lower:]')
        OS_VERSION=$(cat /etc/redhat-release | cut -d' ' -f3)
        OS_NAME=$(cat /etc/redhat-release)
    else
        log_error "无法检测操作系统"
        exit 1
    fi
    
    log_info "检测到操作系统: $OS_NAME"
}

# 安装 SSH 服务
install_ssh() {
    log_info "开始安装 SSH 服务..."
    
    case $OS in
        debian|ubuntu|linuxmint)
            log_info "使用 apt 安装 SSH 服务..."
            apt-get update
            apt-get install -y openssh-server
            ;;
        centos|rhel|fedora|rocky|almalinux)
            log_info "使用 yum/dnf 安装 SSH 服务..."
            if command -v dnf >/dev/null 2>&1; then
                dnf install -y openssh-server
            else
                yum install -y openssh-server
            fi
            ;;
        opensuse*|suse*)
            log_info "使用 zypper 安装 SSH 服务..."
            zypper install -y openssh
            ;;
        arch|manjaro)
            log_info "使用 pacman 安装 SSH 服务..."
            pacman -Syu --noconfirm openssh
            ;;
        *)
            log_error "不支持的发行版: $OS"
            exit 1
            ;;
    esac
    
    log_info "SSH 服务安装完成"
}

# 配置 SSH 服务
configure_ssh() {
    log_info "开始配置 SSH 服务..."
    
    # 备份原始配置文件
    if [ -f /etc/ssh/sshd_config ]; then
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)
        log_info "已备份原始配置文件: /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # 使用 sed 命令修改 SSH 配置
    sed -i.bak \
        -e 's/^#Port 22/Port 22/' \
        -e 's/^#PermitRootLogin.*/PermitRootLogin yes/' \
        -e 's/^#GSSAPIAuthentication.*/GSSAPIAuthentication no/' \
        -e 's/^#UseDNS.*/UseDNS no/' \
        -e 's/^#Compression.*/Compression yes/' \
        -e 's/^#TCPKeepAlive.*/TCPKeepAlive yes/' \
        -e 's/^#ClientAliveInterval.*/ClientAliveInterval 10/' \
        -e 's/^#ClientAliveCountMax.*/ClientAliveCountMax 999/' \
        /etc/ssh/sshd_config
    
    # 确保必要的配置项存在
    grep -q "^Port 22" /etc/ssh/sshd_config || echo "Port 22" >> /etc/ssh/sshd_config
    grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    grep -q "^GSSAPIAuthentication no" /etc/ssh/sshd_config || echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
    grep -q "^UseDNS no" /etc/ssh/sshd_config || echo "UseDNS no" >> /etc/ssh/sshd_config
    grep -q "^Compression yes" /etc/ssh/sshd_config || echo "Compression yes" >> /etc/ssh/sshd_config
    grep -q "^TCPKeepAlive yes" /etc/ssh/sshd_config || echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
    grep -q "^ClientAliveInterval 10" /etc/ssh/sshd_config || echo "ClientAliveInterval 10" >> /etc/ssh/sshd_config
    grep -q "^ClientAliveCountMax 999" /etc/ssh/sshd_config || echo "ClientAliveCountMax 999" >> /etc/ssh/sshd_config
    
    log_info "SSH 配置完成"
}

# 配置防火墙
configure_firewall() {
    log_info "开始配置防火墙..."
    
    # 检测防火墙工具
    if command -v ufw >/dev/null 2>&1; then
        log_info "使用 UFW 配置防火墙"
        ufw allow ssh
        ufw allow 22/tcp
        echo "y" | ufw enable
    elif command -v firewall-cmd >/dev/null 2>&1; then
        log_info "使用 firewalld 配置防火墙"
        systemctl enable firewalld
        systemctl start firewalld
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --reload
    elif command -v iptables >/dev/null 2>&1; then
        log_info "使用 iptables 配置防火墙"
        iptables -A INPUT -p tcp --dport 22 -j ACCEPT
        
        # 保存 iptables 规则
        if command -v iptables-save >/dev/null 2>&1; then
            # 确保目录存在
            mkdir -p /etc/iptables
            iptables-save > /etc/iptables/rules.v4
        fi
    else
        log_warn "未找到支持的防火墙工具，请手动配置防火墙"
    fi
    
    log_info "防火墙配置完成"
}

# 启动 SSH 服务
start_ssh_service() {
    log_info "启动 SSH 服务..."
    
    case $OS in
        debian|ubuntu|linuxmint|opensuse*|suse*|arch|manjaro)
            systemctl enable ssh
            systemctl start ssh
            systemctl status ssh --no-pager
            ;;
        centos|rhel|fedora|rocky|almalinux)
            systemctl enable sshd
            systemctl start sshd
            systemctl status sshd --no-pager
            ;;
        *)
            log_error "不支持的发行版: $OS"
            exit 1
            ;;
    esac
    
    log_info "SSH 服务已启动"
}

# 显示连接信息
show_connection_info() {
    local ip_address=$(hostname -I | awk '{print $1}')
    echo ""
    echo -e "${CYAN}=============================================="
    echo -e "           SSH 服务配置完成!"
    echo -e "=============================================="
    echo -e "${NC}"
    echo -e "${GREEN}连接信息:${NC}"
    echo -e "  服务器 IP: ${BLUE}$ip_address${NC}"
    echo -e "  SSH 端口: ${BLUE}22${NC}"
    echo -e "  连接命令: ${BLUE}ssh -p 22 root@$ip_address${NC}"
    echo ""
    echo -e "${YELLOW}安全建议:${NC}"
    echo -e "  • 更改默认 SSH 端口 (修改 /etc/ssh/sshd_config)"
    echo -e "  • 禁用 root 登录并使用普通用户"
    echo -e "  • 使用密钥认证替代密码认证"
    echo -e "  • 限制可登录的用户和IP范围"
    echo -e "  • 考虑安装 Fail2Ban 防止暴力破解"
    echo ""
    echo -e "${CYAN}=============================================="
    echo -e "${NC}"
}

# 主函数
main() {
    show_welcome
    confirm_continue
    
    log_info "开始配置 SSH 服务..."
    
    # 检查 root 权限
    if [ "$(id -u)" -ne 0 ]; then
        log_error "此脚本需要 root 权限运行"
        echo -e "请使用 ${BLUE}sudo ./$(basename "$0")${NC} 命令运行"
        exit 1
    fi
    
    detect_os
    install_ssh
    configure_ssh
    configure_firewall
    start_ssh_service
    show_connection_info
    
    log_info "SSH 服务配置完成!"
}

# 执行主函数
main "$@"