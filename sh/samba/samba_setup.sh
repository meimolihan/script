#!/bin/bash

# 设置错误处理，遇到错误立即退出
set -e

echo "====================================="
# 显示欢迎信息
show_welcome() {
    echo "           Samba 共享配置脚本"
    echo "====================================="
    echo "欢迎使用 Samba 共享自动配置脚本!"
    echo
    echo "本脚本将帮助您:"
    echo "  ✓ 自动安装 Samba 服务"
    echo "  ✓ 创建并配置共享目录"
    echo "  ✓ 设置 Samba 用户和密码"
    echo "  ✓ 配置 Samba 共享权限"
    echo "  ✓ 重启 Samba 服务并显示连接信息"
    echo
    echo "支持的系统: Ubuntu, Debian, CentOS, RHEL, Fedora"
    echo "====================================="
}
show_welcome

# 安装Samba的函数
install_samba() {
    echo "正在安装 Samba 服务..."
    
    if command -v apt &> /dev/null; then
        apt update >/dev/null 2>&1 && apt install samba -y >/dev/null 2>&1
    elif command -v yum &> /dev/null; then
        yum install samba -y >/dev/null 2>&1
    elif command -v dnf &> /dev/null; then
        dnf install samba -y >/dev/null 2>&1
    else
        echo "✗ 错误: 不支持的包管理器"
        exit 1
    fi
    
    if [ $? -eq 0 ]; then
        echo "✓ Samba 安装成功"
    else
        echo "✗ Samba 安装失败"
        exit 1
    fi
}

# 验证目录路径的函数
validate_directory() {
    local dir="$1"
    if [[ "$dir" =~ ^/.* ]]; then
        return 0
    else
        echo "✗ 错误: 目录路径必须以/开头"
        return 1
    fi
}

# 验证用户名的函数
validate_username() {
    local user="$1"
    if [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        return 0
    else
        echo "✗ 错误: 用户名只能包含小写字母、数字、下划线和连字符，且必须以字母或下划线开头"
        return 1
    fi
}

# 主脚本开始
echo "Samba 共享配置脚本开始执行"
echo "====================================="
# 安装Samba
install_samba
echo "====================================="

# 获取配置信息
echo "   配置共享设置"
# 获取共享目录
share_dir=$(read -e -p "请输入Samba共享目录路径（默认为/mnt）: " input; echo "${input:-/mnt}")
validate_directory "$share_dir" || exit 1

# 创建共享目录并设置权限
mkdir -p "$share_dir"
chmod 777 "$share_dir"
echo "✓ 共享目录创建成功: $share_dir"
echo "====================================="

# 获取Samba用户名
samba_user=$(read -e -p "请输入Samba用户名（默认为root）: " input; echo "${input:-root}")
validate_username "$samba_user" || exit 1

# 如果用户不存在则创建
user_created=false
if ! id "$samba_user" &>/dev/null; then
    useradd "$samba_user"
    echo "✓ 系统用户创建成功: $samba_user"
    user_created=true
else
    echo "✓ 使用已有系统用户: $samba_user"
fi
echo "====================================="

# 设置Samba密码
if [ "$user_created" = true ]; then
    # 新用户必须设置密码
    while true; do
        read -s -p "请输入 Samba 密码: " samba_pass
        echo
        read -s -p "请确认 Samba 密码: " samba_pass_confirm
        echo
        
        if [ "$samba_pass" = "$samba_pass_confirm" ]; then
            if [ -n "$samba_pass" ]; then
                break
            else
                echo "✗ 密码不能为空，请重新输入!"
            fi
        else
            echo "✗ 密码不匹配，请重新输入!"
        fi
    done
    
    # 设置Samba用户密码
    echo -e "$samba_pass\n$samba_pass" | smbpasswd -a -s "$samba_user"
    echo "✓ Samba 用户密码设置成功"
else
    # 已有用户询问是否修改密码
    while true; do
        read -p "是否要为用户 '$samba_user' 设置/修改 Samba 密码? (y/n) [不区分大小写]: " change_pass
        change_pass_lower=$(echo "$change_pass" | tr '[:upper:]' '[:lower:]')
        
        if [ "$change_pass_lower" = "y" ] || [ "$change_pass_lower" = "yes" ]; then
            while true; do
                read -s -p "请输入新的 Samba 密码: " samba_pass
                echo
                read -s -p "请确认新的 Samba 密码: " samba_pass_confirm
                echo
                
                if [ "$samba_pass" = "$samba_pass_confirm" ]; then
                    if [ -n "$samba_pass" ]; then
                        # 设置Samba用户密码
                        echo -e "$samba_pass\n$samba_pass" | smbpasswd -s "$samba_user"
                        echo "✓ Samba 用户密码修改成功"
                        break 2
                    else
                        echo "✗ 密码不能为空，请重新输入!"
                    fi
                else
                    echo "✗ 密码不匹配，请重新输入!"
                fi
            done
        elif [ "$change_pass_lower" = "n" ] || [ "$change_pass_lower" = "no" ]; then
            echo "✓ 保持原有 Samba 密码不变"
            break
        else
            echo "✗ 无效输入，请输入 y 或 n"
        fi
    done
fi
echo "====================================="

# 配置 Samba
echo "   配置 Samba 服务"
# 备份原配置文件
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak 2>/dev/null || true

# 确定共享名
share_name=$(basename "$share_dir")
if [ -z "$share_name" ] || [ "$share_name" = "/" ]; then
    share_name="share"
fi

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

echo "✓ Samba 配置已更新"
echo "====================================="

# 重启Samba服务
echo "   重启 Samba 服务"
restart_samba() {
    if command -v systemctl &> /dev/null; then
        if systemctl restart smbd &>/dev/null; then
            echo "✓ Samba 服务重启成功"
            return 0
        elif systemctl restart smb &>/dev/null; then
            echo "✓ Samba 服务重启成功"
            return 0
        fi
    fi
    
    if command -v service &> /dev/null; then
        if service smbd restart &>/dev/null; then
            echo "✓ Samba 服务重启成功"
            return 0
        elif service smb restart &>/dev/null; then
            echo "✓ Samba 服务重启成功"
            return 0
        fi
    fi
    
    echo "⚠ 无法自动重启Samba服务，请手动重启"
    return 1
}

restart_samba
echo "====================================="

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

echo "   Samba 配置信息"
echo "====================================="
echo "✓ Samba 配置已完成!"
echo "主机IP地址: ${ip_address:-无法获取IP地址}"
echo "共享目录: $share_dir"
echo "Samba共享名: $share_name"
echo "Samba用户名: $samba_user"
echo "Win11 访问方式: \\\\${ip_address:-服务器IP}\\$share_name"
echo "Linux 测试连接: smbclient //${ip_address:-服务器IP}/$share_name -U $samba_user"
echo "====================================="
echo "配置已完成，感谢使用!"