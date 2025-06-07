
#!/bin/bash
# 统计指定目录的文件、目录数量（含隐藏项）及总大小（MB和GB）

check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo "错误: 需要安装 '$1' 包"; exit 1; }
}

check_command find
check_command du
check_command awk
check_command bc

# 定义需要统计的目录列表（格式：中文名称|目录路径）
directories=(
    "未处理壁纸目录|/vol1/1000/home/random-pic-api/photos"
    "已处理手机壁纸目录|/vol1/1000/home/random-pic-api/portrait"
    "手机壁纸原图目录|/vol2/1000/阿里云盘/教程文件/壁纸原图/手机原图"
    "已处理电脑壁纸目录|/vol1/1000/home/random-pic-api/landscape"
    "电脑壁纸原图目录|/vol2/1000/阿里云盘/教程文件/壁纸原图/电脑原图"
)

for item in "${directories[@]}"; do
    # 分割中文名称和目录路径
    IFS='|' read -r name path <<< "$item"
    
    echo -e "\n====================== 【${name}】统计结果 ======================"
    echo "正在统计目录: ${path}"
    
    # 统计文件数量（含隐藏文件）
    file_count=$(find "$path" -maxdepth 1 -type f -not -path '*/\.*' 2>/dev/null | wc -l)
    hidden_file_count=$(find "$path" -maxdepth 1 -type f -name '.*' 2>/dev/null | wc -l)
    total_files=$((file_count + hidden_file_count))
    
    # 统计目录数量（含隐藏目录，排除当前目录）
    dir_count=$(find "$path" -maxdepth 1 -type d -not -path "$path" -not -path '*/\.*' 2>/dev/null | wc -l)
    hidden_dir_count=$(find "$path" -maxdepth 1 -type d -name '.*' -not -path "$path" 2>/dev/null | wc -l)
    total_dirs=$((dir_count + hidden_dir_count))
    
    # 统计总大小（排除当前目录自身占用）
    total_size_mb=$(du -sm "$path"/.* "$path"/* 2>/dev/null | awk '{sum += $1} END {print sum}')
    total_size_gb=$(echo "scale=2; $total_size_mb / 1024" | bc)
    
    # 输出结果
    echo "当前目录下的项目统计："
    echo "  - 文件总数: $total_files"
    echo "    • 普通文件: $file_count"
    echo "    • 隐藏文件: $hidden_file_count"
    echo "  - 目录总数: $total_dirs"
    echo "    • 普通目录: $dir_count"
    echo "    • 隐藏目录: $hidden_dir_count"
    echo "  - 总项目数: $((total_files + total_dirs))"
    echo "文件总大小为: ${total_size_mb} MB (${total_size_gb} GB)"
    echo "=============================================================="
done
