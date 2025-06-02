#!/bin/bash

# 配置区 - 默认前缀改为 pc

default_prefix="pc"

# 用户输入交互

read -p "请输入文件名前缀（默认 $default_prefix）：" prefix

if [ -z "$prefix" ]; then

    prefix="$default_prefix"

fi

echo "正在使用前缀：[$prefix]"

# 设置起始编号为1

counter=1

temp_folder="temp_rename_folder_$RANDOM"

# 创建临时文件夹

mkdir -p "$temp_folder"

# 安全移动文件到临时文件夹

find . -maxdepth 1 -name '*.webp' -print0 | while IFS= read -r -d $'\0' file; do

    mv -v "$file" "$temp_folder/"

done

# 按顺序重命名文件

find "$temp_folder" -name '*.webp' -print0 | while IFS= read -r -d $'\0' old_path; do

    file=$(basename "$old_path")

    

    # 生成新文件名（三位数编号自动补零）

    new_file=$(printf "%s-%03d.webp" "$prefix" "$counter")

    

    # 执行重命名并移动

    echo "正在重命名并移动：\"$temp_folder/$file\" → $new_file"

    mv -v "$temp_folder/$file" "$new_file"

    

    ((counter++))

done

# 删除临时文件夹

rm -rf "$temp_folder"

# 执行结果报告

echo "---------------------------"

echo "所有文件已处理完成！共重命名 $((counter-1)) 个文件"