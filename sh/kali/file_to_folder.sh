#!/bin/bash

# 获取当前目录路径
current_dir=$(pwd)

# 遍历当前目录下的所有文件和文件夹
for file in "$current_dir"/*; do
    # 跳过目录
    [ -f "$file" ] || continue
    
    # 获取文件名（不含扩展名）
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"
    
    # 跳过脚本文件本身
    if [ "$filename" = "$(basename -- "$0")" ]; then
        continue
    fi
    
    # 创建以文件名命名的文件夹（忽略已存在的错误）
    mkdir -p "$filename_noext" 2>/dev/null
    
    # 移动文件到新文件夹中
    mv -n "$file" "$filename_noext"/ 2>/dev/null || {
        echo "警告：无法移动 '$filename' 到 '$filename_noext'" >&2
    }
done

echo "处理完成！"    