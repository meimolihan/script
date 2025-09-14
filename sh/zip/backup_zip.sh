#!/bin/bash
# =================================================================================================
# 脚本名称：backup_zip.sh
# 作    用：备份指定源目录下的所有子目录到备份目录，每个子目录压缩为单独的ZIP文件
# 使用方法：
#   1. 将脚本保存为 backup_zip.sh
#   2. 赋予执行权限：chmod +x backup_zip.sh
#   3. 运行脚本：./backup_zip.sh
#   4. 按照提示输入源目录和备份目录
# =================================================================================================

# 设置退格键处理
stty erase ^H 2>/dev/null || stty erase ^? 2>/dev/null

clear
echo "=================================="
echo "         ZIP 备份工具 v2.0"
echo "=================================="
echo "功能描述："
echo "  1. 备份指定源目录下的所有子目录到备份目录"
echo "  2. 每个子目录将压缩成单独的 zip 文件"
echo "  3. 提供详细的错误处理和用户反馈"
echo "注意事项："
echo "  1. 确保运行脚本的用户对源目录有读权限，对备份目录有写权限"
echo "  2. 源目录下的隐藏文件夹（以 . 开头）不会被备份"
echo "  3. 备份文件名格式：文件夹名字-yyyy-mm-dd.zip"
echo "  4. 需要系统安装有 zip 工具"
echo "=================================="
echo

# 检查是否安装了 zip 工具
if ! command -v zip > /dev/null 2>&1; then
    echo "错误：系统未安装 zip 工具，请先安装 zip"
    echo "在 Ubuntu/Debian 系统上可以使用: sudo apt-get install zip"
    echo "在 CentOS/RHEL 系统上可以使用: sudo yum install zip"
    exit 1
fi

# 安全的读取输入函数
safe_read() {
    local prompt="$1"
    local var_name="$2"
    local default_value="$3"
    
    while true; do
        if [ -n "$default_value" ]; then
            read -e -p "$prompt (默认: $default_value): " -i "$default_value" input
        else
            read -e -p "$prompt: " input
        fi
        
        # 如果用户按Ctrl+C，退出脚本
        if [ $? -ne 0 ]; then
            echo
            echo "用户取消操作"
            exit 1
        fi
        
        # 如果用户没有输入但有默认值，使用默认值
        if [ -z "$input" ] && [ -n "$default_value" ]; then
            input="$default_value"
        fi
        
        # 去除前后空格
        input=$(echo "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # 如果输入为空，提示错误
        if [ -z "$input" ]; then
            echo "错误：输入不能为空！"
            continue
        fi
        
        eval "$var_name=\"$input\""
        break
    done
}

# 获取源目录
while true; do
    safe_read "请输入要备份的源目录路径" source_dir ""
    
    # 移除路径末尾可能存在的斜杠
    source_dir="${source_dir%/}"
    
    # 验证源目录是否存在
    if [ ! -d "$source_dir" ]; then
        echo "错误：源目录 '$source_dir' 不存在！"
        continue
    fi
    
    # 验证是否有读取源目录的权限
    if [ ! -r "$source_dir" ]; then
        echo "错误：没有读取源目录 '$source_dir' 的权限！"
        continue
    fi
    
    echo "√ 源目录验证通过：$source_dir"
    break
done

echo

# 获取备份目录
while true; do
    safe_read "请输入备份文件存放目录路径" backup_dir ""
    
    # 移除路径末尾可能存在的斜杠
    backup_dir="${backup_dir%/}"
    
    # 检查备份目录是否与源目录相同
    if [ "$source_dir" = "$backup_dir" ]; then
        echo "错误：备份目录不能与源目录相同！"
        continue
    fi
    
    # 检查备份目录是否是源目录的子目录
    if [[ "$backup_dir" == "$source_dir"* ]]; then
        echo "警告：备份目录是源目录的子目录，这可能导致递归备份问题！"
        read -p "是否继续？(y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            continue
        fi
    fi
    
    # 验证是否有写入备份目录父目录的权限
    if [ ! -w "$(dirname "$backup_dir")" ]; then
        echo "错误：没有写权限到 '$backup_dir' 的父目录！"
        continue
    fi
    
    # 创建备份目录（如果不存在）
    if [ ! -d "$backup_dir" ]; then
        echo "正在创建备份目录 '$backup_dir'..."
        mkdir -p "$backup_dir"
        if [ $? -ne 0 ]; then
            echo "错误：无法创建目录 '$backup_dir'，请检查权限！"
            continue
        fi
        echo "√ 成功创建备份目录 '$backup_dir'"
    else
        echo "√ 备份目录 '$backup_dir' 已存在"
    fi
    
    # 验证备份目录是否可写
    if [ ! -w "$backup_dir" ]; then
        echo "错误：没有写权限到备份目录 '$backup_dir'！"
        continue
    fi
    
    echo "√ 备份目录验证通过：$backup_dir"
    break
done

echo
echo "=================================="
echo "          备份配置摘要"
echo "=================================="
echo "源目录: $source_dir"
echo "备份目录: $backup_dir"
echo "压缩格式: ZIP"
echo "=================================="
echo

# 确认开始备份
read -p "是否开始备份？(Y/n): " confirm
if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
    echo "用户取消备份操作"
    exit 0
fi

echo
echo "开始备份 '$source_dir' 下的所有子目录..."
echo

# 获取当前日期
current_date=$(date +'%Y-%m-%d')
backup_count=0
error_count=0

# 遍历源目录下的所有子目录并压缩
for d in "$source_dir"/*/; do
    # 跳过非目录文件
    if [ ! -d "$d" ]; then
        continue
    fi
    
    # 获取目录名（移除路径部分和末尾斜杠）
    dir_name=$(basename "$d")
    
    # 跳过隐藏目录（以.开头）
    if [[ "$dir_name" = .* ]]; then
        echo "跳过隐藏目录: $dir_name"
        continue
    fi
    
    echo "正在备份: $dir_name"
    
    # 构建备份文件名
    backup_file="${backup_dir}/${dir_name}-${current_date}.zip"
    
    # 检查是否已存在同名备份文件
    if [ -f "$backup_file" ]; then
        read -p "备份文件 '$(basename "$backup_file")' 已存在，是否覆盖？(y/N): " overwrite
        if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
            echo "跳过目录: $dir_name"
            continue
        fi
    fi
    
    # 执行备份 - 使用 zip 命令
    echo "正在压缩目录..."
    cd "$source_dir" && zip -r "$backup_file" "$dir_name" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        # 获取备份文件大小
        file_size=$(du -h "$backup_file" 2>/dev/null | cut -f1)
        if [ -z "$file_size" ]; then
            file_size="未知"
        fi
        echo "√ 成功备份: $dir_name -> $(basename "$backup_file") (大小: $file_size)"
        backup_count=$((backup_count + 1))
    else
        echo "× 备份失败: $dir_name"
        error_count=$((error_count + 1))
        # 删除可能创建的不完整备份文件
        if [ -f "$backup_file" ]; then
            rm -f "$backup_file"
        fi
    fi
    
    echo
done

# 显示备份结果摘要
echo "=================================="
echo "          ZIP备份完成摘要"
echo "=================================="
echo "源目录: $source_dir"
echo "备份目录: $backup_dir"
echo "压缩格式: ZIP"
echo "成功备份: $backup_count 个目录"
echo "备份失败: $error_count 个目录"
echo "=================================="

if [ $error_count -eq 0 ] && [ $backup_count -gt 0 ]; then
    echo "所有目录备份完成！"
elif [ $backup_count -eq 0 ]; then
    echo "未找到任何可备份的目录！"
else
    echo "备份完成，但有 $error_count 个目录备份失败！"
fi

echo
read -p "按回车键退出..."
exit 0