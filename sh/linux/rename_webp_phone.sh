#!/bin/bash

# 提示输入前缀，默认值为'phone'
read -p "请输入文件名前缀（直接回车使用默认'phone'）: " prefix
prefix=${prefix:-phone}  # 如果用户直接回车，则使用默认值'phone'

# 获取所有.webp文件并按修改时间排序
files=()
while IFS= read -r -d $'\0' file; do
    files+=("$file")
done < <(find . -maxdepth 1 -name "*.webp" -print0 | sort -z)

# 检查是否有.webp文件
if [ ${#files[@]} -eq 0 ]; then
    echo "未找到.webp文件！"
    exit 1
fi

# 开始重命名操作
count=1
for file in "${files[@]}"; do
    # 生成新文件名（如phone-001.webp）
    new_name=$(printf "%s-%03d.webp" "$prefix" "$count")
    
    # 避免覆盖已存在的文件
    if [ -e "$new_name" ]; then
        echo "错误：文件 '$new_name' 已存在，跳过重命名 '$file'"
    else
        mv -n -- "$file" "$new_name" && echo "已重命名: $file -> $new_name"
    fi
    
    ((count++))
done

echo "操作完成！共处理 $((count-1)) 个文件。"
