#!/bin/bash

# 定义分割线
divider="================================================"

echo -e "$divider"
echo "开始处理视频文件转换"
echo -e "$divider"

# 遍历当前目录下的所有视频文件
for file in *.{ts,mkv,mov,avi,flv,mpg,rmvb,wmv}; do
    # 检查文件是否存在
    if [ -f "$file" ]; then
        # 获取文件名（不包含扩展名）
        filename=$(basename "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"

        # 输出文件路径
        output_file="${filename}.mp4"

        # 检查输出文件是否已存在
        if [ -f "$output_file" ]; then
            echo "$output_file 已存在，跳过转换"
            continue
        fi

        # 使用 FFmpeg 转换为 .mp4 格式
        ffmpeg -i "$file" -c copy -y "$output_file" > /dev/null 2>&1
        echo "$file 转换为 $output_file 完成"
    fi
done

echo -e "$divider"
echo "所有视频文件转换完成"
echo -e "$divider"