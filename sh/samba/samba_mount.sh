#!/bin/bash

echo "=============================================="
echo "        Samba共享挂载脚本"
echo "=============================================="
echo "功能:"
echo "1. 自动检测并安装必要的CIFS工具"
echo "2. 扫描网络中的Samba共享"
echo "3. 提供交互式选择共享功能"
echo "4. 支持认证和匿名访问"
echo "5. 可配置本地挂载点"
echo "6. 可选开机自动挂载"
echo "=============================================="

# 检查必要的工具是否安装
if ! command -v mount.cifs &> /dev/null || ! command -v smbclient &> /dev/null; then
    echo "正在安装必要的CIFS工具..."
    if command -v apt &> /dev/null; then
        apt update && apt install cifs-utils smbclient -y
    elif command -v yum &> /dev/null; then
        yum install cifs-utils samba-client -y
    elif command -v dnf &> /dev/null; then
        dnf install cifs-utils samba-client -y
    else
        echo "不支持的包管理器，请手动安装cifs-utils和smbclient"
        exit 1
    fi
fi

# 提示输入服务器IP
read -e -p "请输入Samba服务器IP地址: " server_ip

# 测试网络连通性
echo "测试网络连通性..."
if ping -c 1 -W 1 "$server_ip" &> /dev/null; then
    echo "网络连通性正常"
else
    echo "警告: 无法ping通服务器 $server_ip"
    read -e -p "是否继续? (y/N): " continue_anyway
    if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 首先使用smbclient查看服务器信息
echo "=============================================="
echo "正在查看Samba服务器信息..."
echo "执行命令: smbclient -L //$server_ip -N"
echo "=============================================="
smbclient -L //$server_ip -N

echo "=============================================="
echo "请查看上面的服务器信息，确认共享名称"
echo "=============================================="

# 尝试获取服务器上的Samba共享信息
echo "正在尝试获取服务器上的Samba共享信息..."
shares=$(smbclient -L //$server_ip -N 2>/dev/null | grep -E '^[[:space:]]*[^[:space:]]+[[:space:]]*$' | grep -vE '^(IPC|Workgroup|Server|Domain)' | awk '{$1=$1};1')

if [ -z "$shares" ]; then
    echo "无法自动获取服务器上的Samba共享信息，请手动输入共享名称"
    read -e -p "请输入Samba共享名称: " share_name
else
    echo "检测到的共享:"
    # 使用数组存储共享列表
    share_list=()
    while IFS= read -r line; do
        share_list+=("$line")
    done <<< "$shares"
    
    # 显示共享列表供选择
    for i in "${!share_list[@]}"; do
        echo "$((i+1)). ${share_list[$i]}"
    done
    echo "0. 手动输入共享名称"
    
    # 获取用户选择
    while true; do
        read -e -p "请选择共享 (输入数字): " choice
        if [[ $choice == "0" ]]; then
            read -e -p "请输入Samba共享名称: " share_name
            break
        elif [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le ${#share_list[@]} ]; then
            share_name="${share_list[$((choice-1))]}"
            break
        else
            echo "无效选择，请重新输入"
        fi
    done
fi

# 确认共享名称
echo "您选择的共享名称是: $share_name"
read -e -p "确认继续? (Y/n): " confirm
if [[ $confirm == "n" || $confirm == "N" ]]; then
    echo "操作已取消"
    exit 0
fi

# 提示输入Samba用户名
read -e -p "请输入Samba用户名 (留空使用匿名访问): " samba_user

# 提示输入Samba密码
if [ -n "$samba_user" ]; then
    read -s -p "请输入Samba密码: " samba_pass
    echo
fi

# 提示输入本地挂载目录
read -e -p "请输入本地挂载目录路径 (默认为/mnt/${share_name}): " mount_dir
mount_dir=${mount_dir:-/mnt/${share_name}}

# 创建挂载目录
echo "创建挂载目录: $mount_dir"
mkdir -p "$mount_dir"
chmod 755 "$mount_dir"

# 尝试使用smbclient测试连接
echo "测试Samba连接..."
if [ -n "$samba_user" ]; then
    test_result=$(echo "exit" | smbclient "//$server_ip/$share_name" -U "$samba_user" "$samba_pass" -c "ls" 2>&1)
else
    test_result=$(echo "exit" | smbclient "//$server_ip/$share_name" -N -c "ls" 2>&1)
fi

if echo "$test_result" | grep -q "NT_STATUS_ACCESS_DENIED"; then
    echo "连接测试失败: 访问被拒绝"
    echo "可能是用户名或密码错误，或者该共享需要认证"
    read -e -p "是否继续尝试挂载? (y/N): " continue_mount
    if [[ ! $continue_mount =~ ^[Yy]$ ]]; then
        exit 1
    fi
elif echo "$test_result" | grep -q "NT_STATUS_BAD_NETWORK_NAME"; then
    echo "连接测试失败: 共享名称错误"
    echo "请确认共享名称是否正确"
    exit 1
elif echo "$test_result" | grep -q "session setup failed"; then
    echo "连接测试失败: 会话建立失败"
    echo "请检查用户名和密码"
    exit 1
else
    echo "连接测试成功"
fi

# 挂载Samba共享
echo "正在挂载Samba共享..."
if [ -n "$samba_user" ]; then
    # 创建凭据文件（临时）
    cred_file=$(mktemp)
    echo "username=$samba_user" > "$cred_file"
    echo "password=$samba_pass" >> "$cred_file"
    chmod 600 "$cred_file"
    
    # 使用凭据文件挂载
    mount -t cifs "//$server_ip/$share_name" "$mount_dir" -o credentials="$cred_file",uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,vers=3.0
    
    # 删除临时凭据文件
    rm -f "$cred_file"
else
    # 匿名访问
    mount -t cifs "//$server_ip/$share_name" "$mount_dir" -o guest,uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,vers=3.0
fi

# 检查挂载是否成功
if mountpoint -q "$mount_dir"; then
    echo "=============================================="
    echo "Samba共享挂载成功!"
    echo "服务器: //$server_ip/$share_name"
    echo "挂载点: $mount_dir"
    echo "用户名: ${samba_user:-匿名}"
    echo "=============================================="
    
    # 显示挂载信息
    df -h | grep "$mount_dir"
else
    echo "挂载失败，请检查以下可能的原因:"
    echo "1. 用户名或密码错误"
    echo "2. 服务器上的共享配置问题"
    echo "3. 防火墙或网络问题"
    echo "4. 服务器上的Samba服务未运行"
    echo ""
    echo "错误详情:"
    dmesg | tail -10
    exit 1
fi

# 询问是否添加到fstab实现开机自动挂载
read -e -p "是否添加到/etc/fstab实现开机自动挂载? (y/N): " add_fstab
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
            echo "该挂载项已存在于/etc/fstab中"
        else
            echo "$fstab_entry" >> /etc/fstab
            echo "已添加到/etc/fstab，凭据文件保存在: $cred_file"
        fi
    else
        # 匿名访问添加到fstab
        fstab_entry="//$server_ip/$share_name $mount_dir cifs guest,uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755,vers=3.0 0 0"
        if grep -q "$fstab_entry" /etc/fstab; then
            echo "该挂载项已存在于/etc/fstab中"
        else
            echo "$fstab_entry" >> /etc/fstab
            echo "已添加到/etc/fstab"
        fi
    fi
fi