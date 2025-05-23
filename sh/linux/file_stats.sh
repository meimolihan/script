#!/bin/bash
# 统计当前目录下的文件、目录数量（含隐藏项）并计算总大小（MB和GB）

# 检查必要的命令是否存在
if ! command -v bc &> /dev/null; then
    echo "错误: 需要安装bc包来进行浮点数计算" >&2
    echo "请运行: apt-get install bc 或 yum install bc" >&2
    exit 1
fi

# 统计文件数量（包括隐藏文件）
file_count=$(find . -maxdepth 1 -type f -not -path '*/\.*' 2>/dev/null | wc -l)
hidden_file_count=$(find . -maxdepth 1 -type f -name '.*' 2>/dev/null | wc -l)
total_files=$((file_count + hidden_file_count))

# 统计目录数量（包括隐藏目录）
dir_count=$(find . -maxdepth 1 -type d -not -path '.' -not -path '*/\.*' 2>/dev/null | wc -l)
hidden_dir_count=$(find . -maxdepth 1 -type d -name '.*' -not -path '.' 2>/dev/null | wc -l)
total_dirs=$((dir_count + hidden_dir_count))

# 统计文件总大小（MB）
total_size_mb=$(du -sm .[!.]* * 2>/dev/null | awk '{sum += $1} END {print sum}')
total_size_gb=$(echo "scale=2; $total_size_mb / 1024" | bc)

echo "当前目录下的项目统计："
echo "  - 文件总数: $total_files"
echo "    • 普通文件: $file_count"
echo "    • 隐藏文件: $hidden_file_count"
echo "  - 目录总数: $total_dirs"
echo "    • 普通目录: $dir_count"
echo "    • 隐藏目录: $hidden_dir_count"
echo "  - 总项目数: $((total_files + total_dirs))"
echo "文件总大小为: ${total_size_mb} MB (${total_size_gb} GB)"