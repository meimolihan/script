#!/bin/bash

# 确保 ffmpeg 已安装
if ! command -v ffmpeg &> /dev/null; then
    echo "错误：未找到 ffmpeg。请先安装："
    echo "sudo apt update && sudo apt install ffmpeg -y"
    exit 1
fi

# 遍历当前目录下所有的 MP3 文件
for file in *.mp3; do
    # 检查文件是否存在（避免空匹配）
    [ -e "$file" ] || continue
    
    # 提取文件名（不含扩展名）
    filename="${file%.*}"
    
    # 使用 ffmpeg 提取专辑封面
    echo "正在处理: $file"
    ffmpeg -i "$file" -an -vcodec copy "$filename.jpg" -y || {
        echo "警告：无法从 $file 提取封面" >&2
    }
done

echo "处理完成！"   