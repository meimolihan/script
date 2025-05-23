#!/bin/bash

# 启用大小写不敏感的文件匹配
shopt -s nocaseglob

# 标志变量，用于检查是否找到可转换的文件
files_found=0

# 遍历当前目录下的所有图片文件（支持大小写不敏感的扩展名）
for file in *.{jpg,jpeg,png,gif,bmp,tiff,tif}; do
    # 检查文件是否存在
    if [ -f "$file" ]; then
        files_found=1  # 标志设置为1，表示找到了文件
        # 获取文件名（不包含扩展名）
        filename=$(basename "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"

        # 输出文件路径
        output_file="${filename}.webp"

        # 使用 FFmpeg 转换为 .webp 格式，隐藏转换过程中的详细信息
        ffmpeg -i "$file" -c:v libwebp -q:v 60 "$output_file" > /dev/null 2>&1
        echo ===================================================
        echo "将 $file 转换为 $output_file 已完成。"
    fi
done

# 恢复默认的文件匹配行为
shopt -u nocaseglob

# 检查是否找到并转换了文件
if [ $files_found -eq 0 ]; then
    echo ===================================================
    echo "当前目录下没有找到可转换的图片文件。"
    echo ===================================================
    exit 1  # 退出脚本
fi

echo "所有图片已转换为 .webp 格式，保存在当前目录下。"
echo ===================================================