#!/bin/bash
# Samba 共享配置脚本 v1.1（规范化版）
# 设置错误处理，遇到错误立即退出
set -e

# 颜色变量
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# 日志函数
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# 公共函数
handle_invalid_input() {
    echo -ne "\r${gl_hong}无效的输入,请重新输入! ${gl_zi} 2 ${gl_hong} 秒后返回"
    sleep 1
    echo -ne "\r${gl_huang}无效的输入,请重新输入! ${gl_zi} 1 ${gl_huang} 秒后返回"
    sleep 1
    echo -e "\r${gl_lv}无效的输入,请重新输入! ${gl_zi}0${gl_lv} 秒后返回"
    sleep 0.5
    return 2
}

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

# 显示欢迎信息
show_welcome() {
    echo -e "${gl_zi}>>> Samba 共享配置脚本 v1.1${gl_bai}"
    echo -e "${gl_bufan}------------------------------------${gl_bai}"
    log_info "欢迎使用 Samba 共享自动配置脚本!"
    echo
    log_info "本脚本将帮助您:"
    echo "  ✓ 自动安装 Samba 服务"
    echo "  ✓ 创建并配置共享目录"
    echo "  ✓ 设置 Samba 用户和密码"
    echo "  ✓ 设置 Samba 共享名"
    echo "  ✓ 配置 Samba 共享权限"
    echo "  ✓ 重启 Samba 服务并显示连接信息"
    echo
    log_info "支持的系统: Ubuntu, Debian, CentOS, RHEL, Fedora"
    echo -e "${gl_bufan}------------------------------------${gl_bai}"
}

# 安装Samba的函数
install_samba() {
    log_info "正在安装 Samba 服务..."
    
    if command -v apt &> /dev/null; then
        apt update >/dev/null 2>&1 && apt install samba -y >/dev/null 2>&1
    elif command -v yum &> /dev/null; then
        yum install samba -y >/dev/null 2>&1
    elif command -v dnf &> /dev/null; then
        dnf install samba -y >/dev/null 2>&1
    else
        log_error "不支持的包管理器"
        exit 1
    fi
    
    if [ $? -eq 0 ]; then
        log_ok "Samba 安装成功"
    else
        log_error "Samba 安装失败"
        exit 1
    fi
}

# 验证目录路径的函数
validate_directory() {
    local dir="$1"
    if [[ "$dir" =~ ^/.* ]]; then
        return 0
    else
        log_error "目录路径必须以/开头"
        return 1
    fi
}

# 验证用户名的函数
validate_username() {
    local user="$1"
    if [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        return 0
    else
        log_error "用户名只能包含小写字母、数字、下划线和连字符，且必须以字母或下划线开头"
        return 1
    fi
}

# 主脚本开始
show_welcome
echo -e "${gl_bufan}------------------------------------${gl_bai}"

# 安装Samba
install_samba
echo -e "${gl_bufan}------------------------------------${gl_bai}"

# 获取配置信息
log_info "配置共享设置"
# 获取共享目录
read -r -e -p "$(echo -e "${gl_bai}请输入Samba共享目录路径（默认为/mnt）: ")" input
share_dir="${input:-/mnt}"
validate_directory "$share_dir" || exit 1

# 创建共享目录并设置权限
mkdir -p "$share_dir"
chmod 777 "$share_dir"
log_ok "共享目录创建成功: $share_dir"
echo -e "${gl_bufan}------------------------------------${gl_bai}"

# 获取Samba用户名
read -r -e -p "$(echo -e "${gl_bai}请输入Samba用户名（默认为root）: ")" input
samba_user="${input:-root}"
validate_username "$samba_user" || exit 1

# 如果用户不存在则创建
user_created=false
if ! id "$samba_user" &>/dev/null; then
    useradd "$samba_user"
    log_ok "系统用户创建成功: $samba_user"
    user_created=true
else
    log_ok "使用已有系统用户: $samba_user"
fi
echo -e "${gl_bufan}------------------------------------${gl_bai}"

# 设置Samba密码
if [ "$user_created" = true ]; then
    # 新用户必须设置密码
    while true; do
        read -r -s -p "$(echo -e "${gl_bai}请输入 Samba 密码: ")" samba_pass
        echo
        read -r -s -p "$(echo -e "${gl_bai}请确认 Samba 密码: ")" samba_pass_confirm
        echo
        
        if [ "$samba_pass" = "$samba_pass_confirm" ]; then
            if [ -n "$samba_pass" ]; then
                break
            else
                log_error "密码不能为空，请重新输入!"
            fi
        else
            log_error "密码不匹配，请重新输入!"
        fi
    done
    
    # 设置Samba用户密码
    echo -e "$samba_pass\n$samba_pass" | smbpasswd -a -s "$samba_user"
    log_ok "Samba 用户密码设置成功"
else
    # 已有用户询问是否修改密码
    while true; do
        read -r -p "$(echo -e "${gl_bai}是否要为用户 '$samba_user' 设置/修改 Samba 密码? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" change_pass
        change_pass_lower=$(echo "$change_pass" | tr '[:upper:]' '[:lower:]')
        
        if [ "$change_pass_lower" = "y" ] || [ "$change_pass_lower" = "yes" ]; then
            while true; do
                read -r -s -p "$(echo -e "${gl_bai}请输入新的 Samba 密码: ")" samba_pass
                echo
                read -r -s -p "$(echo -e "${gl_bai}请确认新的 Samba 密码: ")" samba_pass_confirm
                echo
                
                if [ "$samba_pass" = "$samba_pass_confirm" ]; then
                    if [ -n "$samba_pass" ]; then
                        # 设置Samba用户密码
                        echo -e "$samba_pass\n$samba_pass" | smbpasswd -s "$samba_user"
                        log_ok "Samba 用户密码修改成功"
                        break 2
                    else
                        log_error "密码不能为空，请重新输入!"
                    fi
                else
                    log_error "密码不匹配，请重新输入!"
                fi
            done
        elif [ "$change_pass_lower" = "n" ] || [ "$change_pass_lower" = "no" ]; then
            log_ok "保持原有 Samba 密码不变"
            break
        else
            handle_invalid_input
        fi
    done
fi
echo -e "${gl_bufan}------------------------------------${gl_bai}"

# ------------------------------------------------------------------
# 手动设置共享名
# ------------------------------------------------------------------
# 先计算默认共享名
default_share_name=$(basename "$share_dir")
[ -z "$default_share_name" ] || [ "$default_share_name" = "/" ] && default_share_name="share"

while true; do
    echo -e "${gl_bufan}------------------------------------${gl_bai}"
    log_info "当前计算出的默认共享名为：$default_share_name"
    read -r -p "$(echo -e "${gl_bai}是否修改共享名？ 回车或输入 ${gl_huang}n${gl_bai}  使用默认，输入 ${gl_huang}y${gl_bai} 自定义，输入 ${gl_huang}q${gl_bai} 退出脚本: ")" ans
    ans=${ans,,}          # 统一转小写

    case "$ans" in
        ""|n|no)
            share_name="$default_share_name"
            log_ok "使用默认共享名：$share_name"
            break
            ;;
        y|yes)
            read -r -p "$(echo -e "${gl_bai}请输入新的共享名: ")" custom_name
            if [ -z "$custom_name" ]; then
                log_error "共享名不能为空，请重新输入！"
                continue
            fi
            share_name="$custom_name"
            log_ok "已设置自定义共享名：$share_name"
            break
            ;;
        q|quit)
            log_info "用户主动退出脚本。"
            exit 0
            ;;
        *)
            handle_invalid_input
            ;;
    esac
done
# ------------------------------------------------------------------

echo -e "${gl_bufan}------------------------------------${gl_bai}"

# 配置 Samba
log_info "配置 Samba 服务"
# 备份原配置文件
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak 2>/dev/null || true

# 追加共享配置
cat >> /etc/samba/smb.conf <<EOF

[$share_name]
    comment = Samba Share
    path = $share_dir
    guest ok = no
    read only = no
    writable = yes
    available = yes
    browseable = yes
    force user = root
    force group = root
    create mask = 0777
    directory mask = 0777
    fruit:encoding = native
    fruit:metadata = stream
    fruit:veto_appledouble = no
    password required = yes
    vfs objects = catia fruit streams_xattr
    force user = $samba_user
    force group = $samba_user
    valid users = root, $samba_user
EOF

log_ok "Samba 配置已更新"
echo -e "${gl_bufan}------------------------------------${gl_bai}"

# 重启Samba服务
log_info "重启 Samba 服务"
restart_samba() {
    if command -v systemctl &> /dev/null; then
        if systemctl restart smbd &>/dev/null; then
            log_ok "Samba 服务重启成功"
            return 0
        elif systemctl restart smb &>/dev/null; then
            log_ok "Samba 服务重启成功"
            return 0
        fi
    fi
    
    if command -v service &> /dev/null; then
        if service smbd restart &>/dev/null; then
            log_ok "Samba 服务重启成功"
            return 0
        elif service smb restart &>/dev/null; then
            log_ok "Samba 服务重启成功"
            return 0
        fi
    fi
    
    log_warn "无法自动重启Samba服务，请手动重启"
    return 1
}

restart_samba
echo -e "${gl_bufan}------------------------------------${gl_bai}"

# 获取IP地址
get_ip() {
    local ip
    ip=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)
    [ -z "$ip" ] && ip=$(hostname -I | awk '{print $1}' 2>/dev/null)
    [ -z "$ip" ] && ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
    echo "$ip"
}

ip_address=$(get_ip)

# 打印配置信息
log_info "Samba 配置信息"
echo -e "${gl_bufan}------------------------------------${gl_bai}"
log_ok "Samba 配置已完成!"
echo -e "${gl_bai}主机IP地址: ${gl_huang}${ip_address:-无法获取IP地址}"
echo -e "${gl_bai}共享目录: ${gl_huang}$share_dir"
echo -e "${gl_bai}Samba共享名: ${gl_huang}$share_name"
echo -e "${gl_bai}Samba用户名: ${gl_huang}$samba_user"
echo -e "${gl_bai}Win11 访问方式: ${gl_huang}\\\\${ip_address:-服务器IP}\\$share_name"
echo -e "${gl_bai}Linux 测试连接: ${gl_huang}smbclient //${ip_address:-服务器IP}/$share_name -U $samba_user"
echo -e "${gl_bai}配置文件路径: ${gl_huang}/etc/samba/smb.conf"
echo -e "${gl_bufan}------------------------------------${gl_bai}"
log_ok "配置已完成，感谢使用!"