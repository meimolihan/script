#!/bin/bash

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

echo -e "${gl_bufan}==============================================${gl_bai}"
echo -e "${gl_zi}        Samba 共享挂载脚本${gl_bai}"
echo -e "${gl_bufan}==============================================${gl_bai}"
log_info "功能:"
echo "1. 自动检测并安装必要的CIFS工具"
echo "2. 扫描网络中的Samba共享"
echo "3. 提供交互式选择共享功能"
echo "4. 支持认证和匿名访问"
echo "5. 可配置本地挂载点"
echo "6. 可选开机自动挂载"
echo -e "${gl_bufan}==============================================${gl_bai}"

# 检查必要的工具是否安装
if ! command -v mount.cifs &> /dev/null || ! command -v smbclient &> /dev/null; then
    log_info "正在安装必要的CIFS工具..."
    if command -v apt &> /dev/null; then
        if apt update && apt install cifs-utils smbclient -y; then
            log_ok "CIFS工具安装成功"
        else
            log_error "CIFS工具安装失败，请检查网络连接或手动安装"
            exit 1
        fi
    elif command -v yum &> /dev/null; then
        if yum install cifs-utils samba-client -y; then
            log_ok "CIFS工具安装成功"
        else
            log_error "CIFS工具安装失败，请检查网络连接或手动安装"
            exit 1
        fi
    elif command -v dnf &> /dev/null; then
        if dnf install cifs-utils samba-client -y; then
            log_ok "CIFS工具安装成功"
        else
            log_error "CIFS工具安装失败，请检查网络连接或手动安装"
            exit 1
        fi
    else
        log_error "不支持的包管理器，请手动安装cifs-utils和smbclient"
        exit 1
    fi
else
    log_ok "必要的CIFS工具已安装"
fi

# 提示输入服务器IP
log_info "IP 地址示例：10.10.10.254"
read -r -e -p "$(echo -e "${gl_bai}请输入Samba 服务器 IP 地址: ")" server_ip

# 测试网络连通性
log_info "测试网络连通性..."
if ping -c 1 -W 1 "$server_ip" &> /dev/null; then
    log_ok "网络连通性正常"
else
    log_warn "无法ping通服务器 $server_ip"
    read -r -e -p "$(echo -e "${gl_bai}是否继续? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" continue_anyway
    if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 首先使用smbclient查看服务器信息
echo -e "${gl_bufan}==============================================${gl_bai}"
log_info "正在查看Samba服务器信息..."
shares_list=$(smbclient -L "//$server_ip" -N 2>/dev/null | grep -E "^\s*[^[:space:]]+\s+Disk\s+" | awk '{print $1}')
log_info "可用共享列表:"
echo "$shares_list" | while read -r share; do
    echo "     - $share"
done
echo -e "${gl_bufan}==============================================${gl_bai}"

# 获取共享名称并验证
while true; do
    read -r -e -p "$(echo -e "${gl_bai}请输入Samba共享名称 (输入 '${gl_huang}quit${gl_bai}' 退出): ")" share_name
    
    # 检查用户是否想退出
    if [ "$share_name" = "quit" ]; then
        log_info "操作已取消"
        exit 0
    fi
    
    # 检查共享名称是否在可用列表中
    if echo "$shares_list" | grep -q "^$share_name$"; then
        log_ok "共享名称验证成功"
        break
    else
        log_error "共享名称 '$share_name' 不存在于可用共享列表中，请重新输入。"
    fi
done

# 提示输入Samba用户名
read -r -e -p "$(echo -e "${gl_bai}请输入Samba用户名 (留空使用匿名访问): ")" samba_user

# 提示输入Samba密码
if [ -n "$samba_user" ]; then
    read -r -s -p "$(echo -e "${gl_bai}请输入Samba密码: ")" samba_pass
    echo
fi

# 提示输入本地挂载目录
read -r -e -p "$(echo -e "${gl_bai}请输入本地挂载目录路径 (默认为/mnt/${share_name}): ")" mount_dir
mount_dir=${mount_dir:-/mnt/${share_name}}

# 创建挂载目录
log_info "创建挂载目录: $mount_dir"
mkdir -p "$mount_dir"
chmod 755 "$mount_dir"

# 尝试使用smbclient测试连接
log_info "测试Samba连接..."
if [ -n "$samba_user" ]; then
    test_result=$(echo "exit" | smbclient "//$server_ip/$share_name" -U "$samba_user" "$samba_pass" -c "ls" 2>&1)
else
    test_result=$(echo "exit" | smbclient "//$server_ip/$share_name" -N -c "ls" 2>&1)
fi

if echo "$test_result" | grep -q "NT_STATUS_ACCESS_DENIED"; then
    log_error "连接测试失败: 访问被拒绝"
    log_info "可能是用户名或密码错误，或者该共享需要认证"
    read -r -e -p "$(echo -e "${gl_bai}是否继续尝试挂载? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" continue_mount
    if [[ ! $continue_mount =~ ^[Yy]$ ]]; then
        exit 1
    fi
elif echo "$test_result" | grep -q "NT_STATUS_BAD_NETWORK_NAME"; then
    log_error "连接测试失败: 共享名称错误"
    log_info "请确认共享名称是否正确"
    exit 1
elif echo "$test_result" | grep -q "session setup failed"; then
    log_error "连接测试失败: 会话建立失败"
    log_info "请检查用户名和密码"
    exit 1
else
    log_ok "连接测试成功"
fi

# 挂载Samba共享
log_info "正在挂载Samba共享..."
if [ -n "$samba_user" ]; then
    # 创建凭据文件（临时）
    cred_file=$(mktemp)
    echo "username=$samba_user" > "$cred_file"
    echo "password=$samba_pass" >> "$cred_file"
    chmod 600 "$cred_file"
    
    # 使用凭据文件挂载
    if mount -t cifs "//$server_ip/$share_name" "$mount_dir" -o credentials="$cred_file",uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,vers=3.0; then
        log_ok "Samba共享挂载成功"
    else
        log_error "Samba共享挂载失败"
    fi
    
    # 删除临时凭据文件
    rm -f "$cred_file"
else
    # 匿名访问
    if mount -t cifs "//$server_ip/$share_name" "$mount_dir" -o guest,uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,vers=3.0; then
        log_ok "Samba共享挂载成功"
    else
        log_error "Samba共享挂载失败"
    fi
fi

# 检查挂载是否成功
if mountpoint -q "$mount_dir"; then
    echo -e "${gl_bufan}==============================================${gl_bai}"
    log_ok "Samba共享挂载成功!"
    echo -e "${gl_bai}服务器: //$server_ip/$share_name"
    echo -e "${gl_bai}挂载点: $mount_dir"
    echo -e "${gl_bai}用户名: ${samba_user:-匿名}"
    echo -e "${gl_bufan}==============================================${gl_bai}"
    
    # 显示挂载信息
    df -h | grep "$mount_dir"
else
    log_error "挂载失败，请检查以下可能的原因:"
    echo "1. 用户名或密码错误"
    echo "2. 服务器上的共享配置问题"
    echo "3. 防火墙或网络问题"
    echo "4. 服务器上的Samba服务未运行"
    echo ""
    log_info "错误详情:"
    dmesg | tail -10
    exit 1
fi

# 询问是否添加到fstab实现开机自动挂载
read -r -e -p "$(echo -e "${gl_bai}是否添加到/etc/fstab实现开机自动挂载? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" add_fstab
if [[ $add_fstab =~ ^[Yy]$ ]]; then
    if [ -n "$samba_user" ]; then
        # 创建永久凭据文件
        cred_dir="/etc/samba/credentials"
        mkdir -p "$cred_dir"
        cred_file="$cred_dir/${server_ip}_${share_name}"
        echo "username=$samba_user" > "$cred_file"
        echo "password=$samba_pass" >> "$cred_file"
        chmod 600 "$cred_file"
        
        # 添加到fstab
        fstab_entry="//$server_ip/$share_name $mount_dir cifs credentials=$cred_file,uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,vers=3.0 0 0"
        if grep -q "$fstab_entry" /etc/fstab; then
            log_info "该挂载项已存在于/etc/fstab中"
        else
            echo "$fstab_entry" >> /etc/fstab
            log_ok "已添加到/etc/fstab，凭据文件保存在: $cred_file"
        fi
    else
        # 匿名访问添加到fstab
        fstab_entry="//$server_ip/$share_name $mount_dir cifs guest,uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,vers=3.0 0 0"
        if grep -q "$fstab_entry" /etc/fstab; then
            log_info "该挂载项已存在于/etc/fstab中"
        else
            echo "$fstab_entry" >> /etc/fstab
            log_ok "已添加到/etc/fstab"
        fi
    fi
fi