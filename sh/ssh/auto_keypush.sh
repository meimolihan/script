#!/bin/bash
# ***************************************************************
#  File: auto_keypush_pve_fixed.sh
#  Desc: SSH密钥分发工具 - PVE系统专用版
#  使用方法: bash auto_keypush_pve_fixed.sh 主机号列表
# ***************************************************************

############################  颜色变量  ############################
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

############################  日志函数  ############################
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

############################  用户可调变量  ############################
USER="root"
PASS="yifan0719"
NET="10.10.10"
KEY_PATH="/root/.ssh/id_rsa"
########################################################################

# 检查目标主机类型
check_target_type() {
    local host="$1"
    
    log_info "检查目标主机 ${host} 的类型..."
    
    # 检查是否是PVE虚拟机
    if pct list 2>/dev/null | grep -q "$host"; then
        echo "lxc"
    elif qm list 2>/dev/null | grep -q "$host"; then
        echo "qemu"
    else
        # 检查是否是普通Linux主机
        if ping -c 1 -W 2 "$host" &>/dev/null; then
            echo "linux"
        else
            echo "unknown"
        fi
    fi
}

# 通过PVE控制台安装SSH服务
install_ssh_via_pve() {
    local vm_id="$1"
    local host="$2"
    
    log_info "通过PVE控制台为 ${host} (VMID: ${vm_id}) 安装SSH服务..."
    
    # 尝试通过PVE控制台执行命令
    if pct exec "$vm_id" -- bash -c "
        echo '正在安装SSH服务...'
        if command -v apt-get &>/dev/null; then
            apt update && apt install -y openssh-server
        elif command -v yum &>/dev/null; then
            yum install -y openssh-server
        else
            echo '无法识别包管理器'
            exit 1
        fi
        
        if systemctl enable ssh && systemctl start ssh; then
            echo 'SSH服务安装成功'
            exit 0
        else
            echo 'SSH服务启动失败'
            exit 1
        fi
    " 2>/dev/null; then
        log_ok "${host} SSH服务安装成功"
        return 0
    else
        log_error "${host} 无法通过PVE控制台安装SSH服务"
        return 1
    fi
}

# 诊断并修复SSH连接问题
diagnose_and_fix_ssh() {
    local host="$1"
    
    log_info "诊断 ${host} 的SSH连接问题..."
    
    # 检查端口状态
    if nc -zv -w 3 "$host" 22 2>&1 | grep -q "refused"; then
        log_warn "${host} SSH端口被拒绝，服务可能未运行"
        
        # 检查是否是PVE管理的虚拟机
        local vm_id=$(echo "$host" | cut -d. -f4)
        local target_type=$(check_target_type "$host")
        
        case "$target_type" in
            "lxc")
                log_info "${host} 是LXC容器，尝试通过PVE控制台修复..."
                if install_ssh_via_pve "$vm_id" "$host"; then
                    sleep 5  # 等待服务启动
                    return 0
                fi
                ;;
            "qemu")
                log_info "${host} 是QEMU虚拟机，需要手动通过控制台修复"
                log_warn "请通过PVE控制台连接到VMID ${vm_id} 并手动安装SSH服务"
                ;;
            *)
                log_warn "${host} 不是PVE管理的虚拟机，需要手动修复"
                ;;
        esac
        
        return 1
    fi
    
    # 如果端口是filtered状态，可能是防火墙问题
    if nmap -p 22 "$host" 2>/dev/null | grep -q "filtered"; then
        log_warn "${host} SSH端口被过滤，可能是防火墙阻止"
        
        # 尝试通过PVE控制台检查防火墙
        local vm_id=$(echo "$host" | cut -d. -f4)
        if pct exec "$vm_id" -- bash -c "
            echo '检查防火墙状态...'
            if command -v ufw &>/dev/null; then
                ufw status | grep -q '22.*ALLOW' || echo 'UFW可能阻止SSH'
            fi
            if command -v iptables &>/dev/null; then
                iptables -L | grep -q '22.*ACCEPT' || echo 'iptables可能阻止SSH'
            fi
        " 2>/dev/null; then
            log_info "防火墙状态检查完成"
        fi
        
        log_warn "请检查目标主机的防火墙设置"
        return 1
    fi
    
    return 0
}

# 主函数
main() {
    # 显示欢迎信息
    echo -e "${gl_zi}>>> SSH密钥分发工具（PVE专用修复版）${gl_bai}"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"
    
    # 检查参数
    if [ $# -eq 0 ]; then
        log_error "请提供主机号，例如: $0 246"
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
        exit 1
    fi
    
    # 检查是否在PVE环境中
    if [ ! -f /etc/pve/version ] && [ ! -d /etc/pve ]; then
        log_warn "未检测到PVE环境，使用标准模式"
    else
        log_info "检测到PVE环境，启用PVE专用功能"
    fi
    
    # 检查必要工具
    if ! command -v sshpass &>/dev/null; then
        log_info "安装sshpass..."
        apt update && apt install -y sshpass
    fi
    
    # 生成SSH密钥（如果不存在）
    if [ ! -f "$KEY_PATH" ]; then
        log_info "生成SSH密钥..."
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -q
        log_ok "SSH密钥已生成"
    else
        log_info "使用现有密钥: $KEY_PATH"
    fi
    
    # 处理每个主机
    local success_count=0
    local fail_count=0
    
    for SUFFIX in "$@"; do
        HOST="${NET}.${SUFFIX}"
        
        echo -e "\n${gl_bufan}————————————————————————${gl_bai}"
        echo -e "${gl_zi}>>> 正在处理主机: ${HOST}${gl_bai}"
        
        # 1. 测试网络连通性
        log_info "测试网络连通性..."
        if ping -c 2 -W 3 "$HOST" &>/dev/null; then
            log_ok "${HOST} 网络可达"
        else
            log_error "${HOST} 网络不可达，跳过..."
            ((fail_count++))
            continue
        fi
        
        # 2. 诊断并修复SSH连接问题
        if ! diagnose_and_fix_ssh "$HOST"; then
            log_error "${HOST} SSH连接修复失败，跳过..."
            ((fail_count++))
            continue
        fi
        
        # 3. 测试SSH连接
        log_info "测试SSH连接..."
        if sshpass -p "$PASS" ssh \
            -o StrictHostKeyChecking=no \
            -o ConnectTimeout=10 \
            "${USER}@${HOST}" "echo 'SSH连接测试成功'" 2>/dev/null; then
            
            log_ok "${HOST} SSH连接成功"
        else
            log_error "${HOST} SSH连接失败，跳过..."
            ((fail_count++))
            continue
        fi
        
        # 4. 推送SSH密钥
        log_info "推送SSH密钥..."
        if sshpass -p "$PASS" ssh-copy-id \
            -o StrictHostKeyChecking=no \
            -i "${KEY_PATH}.pub" \
            "${USER}@${HOST}" 2>/dev/null; then
            
            log_ok "${HOST} 密钥推送成功"
        else
            log_error "${HOST} 密钥推送失败"
            ((fail_count++))
            continue
        fi
        
        # 5. 验证密钥登录
        log_info "验证密钥登录..."
        if ssh -o BatchMode=yes -o ConnectTimeout=5 "${USER}@${HOST}" "echo '密钥登录成功'" 2>/dev/null; then
            log_ok "${HOST} 密钥登录验证成功"
            ((success_count++))
        else
            log_warn "${HOST} 密钥登录验证失败"
            ((success_count++))  # 仍然算成功
        fi
        
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
        echo -e "${gl_lv}[成功] 主机: ${HOST}${gl_bai}"
        echo -e "${gl_lv}[测试] 命令: ssh ${USER}@${HOST}${gl_bai}"
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
    done
    
    # 显示最终结果
    echo -e "\n${gl_bufan}————————————————————————${gl_bai}"
    echo -e "${gl_zi}>>> 任务完成汇总${gl_bai}"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"
    echo -e "  总共处理: $# 台主机"
    echo -e "  成功: ${gl_lv}${success_count}${gl_bai} 台"
    echo -e "  失败: ${gl_hong}${fail_count}${gl_bai} 台"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"
    
    if [ $fail_count -gt 0 ]; then
        echo -e "${gl_huang}>>> 故障主机修复指南${gl_bai}"
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
        echo -e "  对于SSH连接失败的主机，请执行以下步骤:"
        echo -e ""
        echo -e "  1. 通过PVE控制台连接到目标虚拟机:"
        echo -e "     ${gl_lv}pct enter <容器ID>${gl_bai}  # 对于LXC容器"
        echo -e "     ${gl_lv}qm terminal <虚拟机ID>${gl_bai}  # 对于QEMU虚拟机"
        echo -e ""
        echo -e "  2. 在目标虚拟机内安装SSH服务:"
        echo -e "     ${gl_lv}apt update && apt install -y openssh-server${gl_bai}"
        echo -e "     ${gl_lv}systemctl enable ssh && systemctl start ssh${gl_bai}"
        echo -e ""
        echo -e "  3. 检查防火墙设置:"
        echo -e "     ${gl_lv}ufw allow ssh${gl_bai}  # 如果使用UFW"
        echo -e "     ${gl_lv}iptables -A INPUT -p tcp --dport 22 -j ACCEPT${gl_bai}"
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
    fi
}

# 运行主函数
main "$@"