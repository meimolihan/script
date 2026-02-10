#!/bin/bash
# 比较两个指定目录的文件数量和总大小

gl_hui='\e[37m'     # 定义灰色（或浅白）字体的ANSI转义序列
gl_hong='\033[31m'  # 定义红色字体的ANSI转义序列
gl_lv='\033[32m'    # 定义绿色字体的ANSI转义序列
gl_huang='\033[33m' # 定义黄色字体的ANSI转义序列
gl_lan='\033[34m'   # 定义蓝色字体的ANSI转义序列
gl_bai='\033[0m'    # 定义重置终端颜色的ANSI转义序列（恢复默认样式）
gl_zi='\033[35m'    # 定义紫色（或品红）字体的ANSI转义序列
gl_bufan='\033[96m' # 定义亮青色（或浅蓝）字体的ANSI转义序列
gl_info='\033[94m'  # 新增：亮蓝色（用于log_info）

check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo "错误: 需要安装 '$1' 包"; exit 1; }
}

check_command find
check_command du
check_command awk
check_command bc

# 定义要比较的两个目录
dir1="/vol1/1000/compose/random-pic-api/landscape"
dir2="/vol2/1000/阿里云盘/教程文件/壁纸原图/电脑原图"

# 定义目录友好名称
name1="已处理电脑壁纸目录"
name2="电脑壁纸原图目录"

# clear  # 清屏命令
echo -e "${gl_huang}目录对比分析${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bai}比较目录: "
echo -e "  ${gl_bai}${name1} : ${gl_lv}${dir1}${gl_bai}"
echo -e "  ${gl_bai}${name2}   : ${gl_lv}${dir2}${gl_bai}"


# 统计目录1的信息
echo -e "${gl_bai}正在统计：${gl_lv}${name1}${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
total_files1=$(find "$dir1" -type f 2>/dev/null | wc -l)
total_size_mb1=$(du -sm "$dir1" 2>/dev/null | awk '{print $1}')
total_size_gb1=$(echo "scale=2; $total_size_mb1 / 1024" | bc)

# 统计目录2的信息
echo -e "${gl_bai}正在统计：${gl_lv}${name2}${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
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
echo -e ""
echo -e "${gl_huang}对比结果${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bai}文件数量:${gl_bai}"
echo -e "  ${name1}: ${gl_lv}$total_files1 ${gl_bai}个文件"
echo -e "  ${name2}: ${gl_lv}$total_files2 ${gl_bai}个文件"
echo -e "  ${gl_huang}$file_diff_msg${gl_bai}"
echo ""
echo -e "${gl_bai}目录大小:${gl_bai}"
echo -e "  ${name1}: ${gl_lv}${total_size_mb1} ${gl_bai}MB (${gl_lv}${total_size_gb1} ${gl_bai}GB)"
echo -e "  ${name2}: ${gl_lv}${total_size_mb2} ${gl_bai}MB (${gl_lv}${total_size_gb2} ${gl_bai}GB)"
echo -e "  ${gl_huang}$size_diff_msg${gl_bai}"
