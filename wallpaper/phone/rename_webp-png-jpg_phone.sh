#!/bin/bash

gl_hui='\e[37m'     # 定义灰色（或浅白）字体的ANSI转义序列
gl_hong='\033[31m'  # 定义红色字体的ANSI转义序列
gl_lv='\033[32m'    # 定义绿色字体的ANSI转义序列
gl_huang='\033[33m' # 定义黄色字体的ANSI转义序列
gl_lan='\033[34m'   # 定义蓝色字体的ANSI转义序列
gl_bai='\033[0m'    # 定义重置终端颜色的ANSI转义序列（恢复默认样式）
gl_zi='\033[35m'    # 定义紫色（或品红）字体的ANSI转义序列
gl_bufan='\033[96m' # 定义亮青色（或浅蓝）字体的ANSI转义序列
gl_info='\033[94m'  # 新增：亮蓝色（用于log_info）

# 配置区
default_prefix="phone"

# 用户输入交互
echo ""
echo -e "${gl_zi}>>> 修改文件名前缀${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
read -r -e -p "$(echo -e "${gl_bai}请输入文件名前缀（默认 ${gl_lv}$default_prefix${gl_bai}） : ")" prefix

if [ -z "$prefix" ]; then
    prefix="$default_prefix"
fi
echo -e "正在使用前缀：[${gl_lv}$prefix${gl_bai}]"

# 设置起始编号
counter=1
temp_folder="temp_rename_folder_$RANDOM"

# 创建临时文件夹
mkdir -p "$temp_folder"

# 移动所有图片文件（不区分大小写）到临时文件夹
find . -maxdepth 1 -type f \( \
    -iname "*.png" -o \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.webp" \
\) -exec mv -v -- "{}" "$temp_folder/" \;

# 按修改时间排序并重命名
find "$temp_folder" -type f -exec ls -tr {} + | while read -r old_path; do
    # 生成新文件名（三位数编号自动补零）
    new_file=$(printf "%s-%03d" "$prefix" "$counter")
    
    # 保留原始扩展名（自动识别大小写）
    ext="${old_path##*.}"
    new_file="${new_file}.${ext,,}"  # 转换为小写扩展名
    
    # 执行重命名并移动
    echo "正在重命名并移动：\"$old_path\" → $new_file"
    mv -v -- "$old_path" "$new_file"
    
    ((counter++))
done

# 删除临时文件夹
rm -rf "$temp_folder"

# 执行结果报告
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
echo -e "${gl_lv}手机原图壁纸排序完成！${gl_bai}"
