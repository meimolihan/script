#!/bin/bash

# 检查是否提供了目录参数，默认为当前目录
target_dir="${1:-.}"

# 检查目录是否存在
if [ ! -d "$target_dir" ]; then
    echo "错误：目录 '$target_dir' 不存在。"
    exit 1
fi

echo "正在遍历目录 '$target_dir' 下的所有子目录..."

# 保存当前工作目录
original_dir=$(pwd)

# 遍历指定目录下的所有子目录
for dir in "$target_dir"/*; do
    if [ -d "$dir" ]; then
        echo "检查目录: $dir"
        cd "$dir" || continue
        
        if [ -f "docker-compose.yml" ]; then
            echo "在 $dir 中找到 docker-compose.yml，正在启动服务..."
            docker-compose up -d
            
            if [ $? -eq 0 ]; then
                echo "✓ $dir 中的服务已成功启动"
            else
                echo "✗ 启动 $dir 中的服务时出错"
            fi
        else
            echo "在 $dir 中未找到 docker-compose.yml，跳过..."
        fi
        
        # 返回原始目录
        cd "$original_dir" || exit
    fi
done

echo "遍历完成！"  