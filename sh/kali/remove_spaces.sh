#!/bin/bash

# 文件名空格处理脚本
# 使用方法：./remove_spaces.sh [目录路径] [替换字符]

# 默认处理当前目录
directory="${1:-.}"
# 默认直接删除空格（修改此处！）
replace_char="${2:-}"

# 检查目录是否存在
if [ ! -d "$directory" ]; then
    echo "错误：目录 '$directory' 不存在。" >&2
    exit 1
fi

# 遍历目录中的所有文件和子目录
find "$directory" -depth -name "* *" | while IFS= read -r file; do
    # 获取目录部分和文件名部分
    dir=$(dirname "$file")
    filename=$(basename "$file")
    
    # 根据替换字符处理空格
    if [ "$replace_char" = "" ]; then
        # 直接删除空格
        new_filename=$(echo "$filename" | tr -d ' ')
    else
        # 用指定字符替换空格
        new_filename=$(echo "$filename" | tr ' ' "$replace_char")
    fi
    
    # 构建新的完整路径
    new_file="$dir/$new_filename"
    
    # 重命名文件（使用mv命令的-n选项避免覆盖已有文件）
    if [ "$file" != "$new_file" ]; then
        echo "重命名: '$file' -> '$new_file'"
        mv -n "$file" "$new_file" || echo "警告：无法重命名 '$file'" >&2
    fi
done

echo "处理完成！"    