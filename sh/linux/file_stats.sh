#!/bin/bash
# 统计当前目录下的文件、目录数量（含隐藏项）并计算总大小（MB）

# 统计文件数量（包括隐藏文件）
file_count=$(find . -maxdepth 1 -type f -not -path '*/\.*' | wc -l)
hidden_file_count=$(find . -maxdepth 1 -type f -name '.*' | wc -l)
total_files=$((file_count + hidden_file_count))

# 统计目录数量（包括隐藏目录）
dir_count=$(find . -maxdepth 1 -type d -not -path '.' -not -path '*/\.*' | wc -l)
hidden_dir_count=$(find . -maxdepth 1 -type d -name '.*' -not -path '.' | wc -l)
total_dirs=$((dir_count + hidden_dir_count))

# 统计文件总大小（MB）
total_size=$(du -sm .[!.]* * 2>/dev/null | awk '{sum += $1} END {print sum}')

echo "当前目录下的项目统计："
echo "  - 文件总数: $total_files"
echo "    • 普通文件: $file_count"
echo "    • 隐藏文件: $hidden_file_count"
echo "  - 目录总数: $total_dirs"
echo "    • 普通目录: $dir_count"
echo "    • 隐藏目录: $hidden_dir_count"
echo "  - 总项目数: $((total_files + total_dirs))"
echo "文件总大小为: ${total_size} MB"