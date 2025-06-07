#!/bin/bash
# 比较两个指定目录的文件数量和总大小

check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo "错误: 需要安装 '$1' 包"; exit 1; }
}

check_command find
check_command du
check_command awk
check_command bc

# 定义要比较的两个目录
dir1="/vol1/1000/home/random-pic-api/portrait"
dir2="/vol2/1000/阿里云盘/教程文件/壁纸原图/手机原图"

# 定义目录友好名称
name1="已处理手机壁纸目录"
name2="手机壁纸原图目录"

echo "==================================== 目录对比分析 ===================================="
echo "正在比较目录: ${name1} (${dir1}) 和 ${name2} (${dir2})"
echo "==============================================================================="

# 统计目录1的信息
echo "正在统计 ${name1}..."
total_files1=$(find "$dir1" -type f 2>/dev/null | wc -l)
total_size_mb1=$(du -sm "$dir1" 2>/dev/null | awk '{print $1}')
total_size_gb1=$(echo "scale=2; $total_size_mb1 / 1024" | bc)

# 统计目录2的信息
echo "正在统计 ${name2}..."
total_files2=$(find "$dir2" -type f 2>/dev/null | wc -l)
total_size_mb2=$(du -sm "$dir2" 2>/dev/null | awk '{print $1}')
total_size_gb2=$(echo "scale=2; $total_size_mb2 / 1024" | bc)

# 计算差异
file_diff=$((total_files1 - total_files2))
size_diff_mb=$(echo "$total_size_mb1 - $total_size_mb2" | bc)
size_diff_gb=$(echo "scale=2; $size_diff_mb / 1024" | bc)

# 确定哪个目录的文件更多
if [ $total_files1 -gt $total_files2 ]; then
    file_more="${name1}"
    file_less="${name2}"
    file_diff=$((total_files1 - total_files2))
    file_diff_msg="${file_more} 比 ${file_less} 多 $file_diff 个文件"
elif [ $total_files1 -lt $total_files2 ]; then
    file_more="${name2}"
    file_less="${name1}"
    file_diff=$((total_files2 - total_files1))
    file_diff_msg="${file_more} 比 ${file_less} 多 $file_diff 个文件"
else
    file_diff_msg="两个目录的文件数量相同"
fi

# 确定哪个目录更大
if (( $(echo "$total_size_mb1 > $total_size_mb2" | bc -l) )); then
    size_larger="${name1}"
    size_smaller="${name2}"
    size_diff_msg="${size_larger} 比 ${size_smaller} 大 ${size_diff_mb} MB (${size_diff_gb} GB)"
elif (( $(echo "$total_size_mb1 < $total_size_mb2" | bc -l) )); then
    size_larger="${name2}"
    size_smaller="${name1}"
    size_diff_msg="${size_larger} 比 ${size_smaller} 大 ${size_diff_mb#-} MB (${size_diff_gb#-} GB)"
else
    size_diff_msg="两个目录大小相同"
fi

# 输出结果
echo -e "\n===================== 对比结果 ====================="
echo "文件数量:"
echo "  ${name1}: $total_files1 个文件"
echo "  ${name2}: $total_files2 个文件"
echo "  $file_diff_msg"

echo -e "\n目录大小:"
echo "  ${name1}: ${total_size_mb1} MB (${total_size_gb1} GB)"
echo "  ${name2}: ${total_size_mb2} MB (${total_size_gb2} GB)"
echo "  $size_diff_msg"

echo -e "\n===================== 比率分析 ====================="
if [ $total_files2 -gt 0 ]; then
    file_ratio=$(echo "scale=2; $total_files1 / $total_files2" | bc)
    echo "文件数量比率 (${name1}/${name2}): $file_ratio"
fi

if (( $(echo "$total_size_mb2 > 0" | bc -l) )); then
    size_ratio=$(echo "scale=2; $total_size_mb1 / $total_size_mb2" | bc)
    echo "大小比率 (${name1}/${name2}): $size_ratio"
fi

echo "===================================================="

