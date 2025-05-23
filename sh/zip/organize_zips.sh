#!/bin/bash

# 切换到源目录
cd /vol1/1000/home || exit

# 获取当前日期时间，用于命名zip文件和目标文件夹
current_datetime=$(date +%Y%m%d-%H%M)
current_date=$(date +%Y%m%d)

# 创建备份目录
backup_dir="/vol2/1000/backup/${current_date}"
mkdir -p "$backup_dir"

# 压缩指定目录并排除特定文件夹
for dir in */; do
    if [ "$dir" != "wxdata/" ] && [ "$dir" != "xxxx/" ]; then
        zip_file="${backup_dir}/${dir%/}_${current_datetime}.zip"
        zip -r "$zip_file" "$dir"
        echo "已压缩: $dir -> $zip_file"
    fi
done

echo "压缩完成，所有zip文件已保存到: $backup_dir"