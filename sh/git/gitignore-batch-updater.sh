#!/bin/bash

echo "正在处理当前目录下的直接子目录..."

# 遍历当前目录下的直接子目录
for dir in */; do
  # 检查是否为目录
  if [ -d "$dir" ]; then
    # 获取目录的完整路径并验证它是直接子目录
    full_path=$(realpath "$dir")
    parent_dir=$(realpath .)
    
    # 确认目录是当前目录的直接子目录
    if [ "$(dirname "$full_path")" = "$parent_dir" ]; then
      gitignore="$dir/.gitignore"
      if [ -f "$gitignore" ]; then
        echo "*\.log" >> "$gitignore"
        echo "kspeeder-data/" >> "$gitignore"
        echo "已更新: $gitignore"
      else
        echo "*\.log" > "$gitignore"
        echo "kspeeder-data/" >> "$gitignore"
        echo "已创建并添加: $gitignore"
      fi
    else
      echo "跳过非直接子目录: $dir"
    fi
  fi
done

echo "处理完成"
