#!/bin/bash

# 配置区
default_prefix="phone"

# 用户输入交互
read -p "请输入文件名前缀（默认 $default_prefix）：" prefix
if [ -z "$prefix" ]; then
    prefix="$default_prefix"
fi
echo "正在使用前缀：[$prefix]"

# 设置起始编号
counter=1
temp_folder="temp_rename_folder_$RANDOM"

# 创建临时文件夹
mkdir -p "$temp_folder"

# 移动所有图片文件（不区分大小写）到临时文件夹
find . -maxdepth 1 -type f \( \
    -iname "*.png" -o \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.webp" \
\) -exec mv -v -- "{}" "$temp_folder/" \;

# 按修改时间排序并重命名
find "$temp_folder" -type f -exec ls -tr {} + | while read -r old_path; do
    # 生成新文件名（三位数编号自动补零）
    new_file=$(printf "%s-%03d" "$prefix" "$counter")
    
    # 保留原始扩展名（自动识别大小写）
    ext="${old_path##*.}"
    new_file="${new_file}.${ext,,}"  # 转换为小写扩展名
    
    # 执行重命名并移动
    echo "正在重命名并移动：\"$old_path\" → $new_file"
    mv -v -- "$old_path" "$new_file"
    
    ((counter++))
done

# 删除临时文件夹
rm -rf "$temp_folder"

# 执行结果报告
echo "---------------------------"
echo "所有文件已处理完成！"
