#!/bin/bash

# 启用大小写不敏感的文件匹配
shopt -s nocaseglob

# 定义颜色变量
GREEN='\e[32m'
NC='\e[0m'  # 恢复默认颜色

# 定义分割线
divider="================================================"

# 菜单选择
while true; do
    echo -e "${GREEN}${divider}${NC}"
    echo -e "${GREEN}请选择要转换的目标格式：${NC}"
    echo -e "${GREEN}${divider}${NC}"
    echo "1. 转换为 webp"
    echo "2. 转换为 jpg"
    echo "3. 转换为 png"
    echo -e "${GREEN}${divider}${NC}"
    echo "0. 退出"
    echo -e "${GREEN}${divider}${NC}"
    read -p "请输入选项（0-3）： " choice

    case $choice in
        1)
            target_format="webp"
            break
            ;;
        2)
            target_format="jpg"
            break
            ;;
        3)
            target_format="png"
            break
            ;;
        0)
            echo -e "${GREEN}${divider}${NC}"
            echo -e "${GREEN}退出脚本。${NC}"
            exit 0
            ;;
        *)
            echo -e "${GREEN}无效选项，请重新输入。${NC}"
            ;;
    esac
done

echo -e "${GREEN}${divider}${NC}"

# 标志变量，用于检查是否找到可转换的文件
files_found=0

# 遍历当前目录下的所有图片文件（支持大小写不敏感的扩展名）
for file in *.{jpg,jpeg,png,gif,bmp,tiff,tif,webp}; do
    # 检查文件是否存在
    if [ -f "$file" ]; then
        # 获取文件名（不包含扩展名）
        filename=$(basename "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"

        # 如果目标格式与当前文件格式相同，则跳过
        if [ "${extension,,}" = "$target_format" ]; then
            continue
        fi

        files_found=1  # 标志设置为1，表示找到了文件
        # 输出文件路径
        output_file="${filename}.${target_format}"

        # 使用 FFmpeg 转换为指定格式，隐藏转换过程中的详细信息
        ffmpeg -i "$file" -q:v 60 "$output_file" > /dev/null 2>&1
        echo -e "${GREEN}$file 转换为 $output_file 完成${NC}"
    fi
done

# 恢复默认的文件匹配行为
shopt -u nocaseglob

# 检查是否找到并转换了文件
if [ $files_found -eq 0 ]; then
    echo -e "${GREEN}${divider}${NC}"
    echo -e "${GREEN}当前目录下没有找到可转换的图片文件。${NC}"
    exit 1  # 退出脚本
fi

echo -e "${GREEN}${divider}${NC}"
echo -e "${GREEN}所有图片已转换为 .${target_format} 格式，保存在当前目录下。${NC}"