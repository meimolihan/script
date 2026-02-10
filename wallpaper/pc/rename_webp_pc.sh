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

# 配置区 - 默认前缀改为 pc
default_prefix="pc"

# 用户输入交互
echo ""
echo -e "${gl_zi}>>> 修改文件名前缀${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
read -r -e -p "$(echo -e "${gl_bai}请输入文件名前缀（默认 ${gl_lv}$default_prefix${gl_bai}） : ")" prefix

if [ -z "$prefix" ]; then
    prefix="$default_prefix"
fi
echo -e "正在使用前缀：[${gl_lv}$prefix${gl_bai}]"

# 设置起始编号为1
counter=1
temp_folder="temp_rename_folder_$RANDOM"

# 创建临时文件夹
mkdir -p "$temp_folder"

# 安全移动文件到临时文件夹
find . -maxdepth 1 -name '*.webp' -print0 | while IFS= read -r -d $'\0' file; do
    mv -v "$file" "$temp_folder/"
done

# 按顺序重命名文件
find "$temp_folder" -name '*.webp' -print0 | while IFS= read -r -d $'\0' old_path; do
    file=$(basename "$old_path")

    # 生成新文件名（三位数编号自动补零）
    new_file=$(printf "%s-%03d.webp" "$prefix" "$counter")

    # 执行重命名并移动
    echo -e "正在重命名并移动：\"$temp_folder/$file\" → $new_file"
    mv -v "$temp_folder/$file" "$new_file"
    ((counter++))
done

# 删除临时文件夹
rm -rf "$temp_folder"

# 执行结果报告
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
echo -e "${gl_lv}电脑壁纸排序完成！${gl_bai}"