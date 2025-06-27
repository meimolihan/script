#!/bin/bash

# 随机壁纸处理脚本 - 手机壁纸

# 一、整理壁纸
echo "===== 开始整理电脑壁纸 ====="
cd /vol1/1000/home/random-pic-api && \
python3 classify.py
echo "壁纸整理完成"
sleep 2  # 暂停2秒

# 二、备份电脑壁纸原图
echo "===== 开始备份电脑壁纸原图 ====="

mv -i /vol1/1000/home/random-pic-api/photos/* /vol2/1000/阿里云盘/教程文件/壁纸原图/电脑原图/
echo "原图备份完成"
sleep 2  # 暂停2秒

# 三、已完成电脑壁纸排序
echo "===== 开始电脑壁纸排序 ====="
cd /vol1/1000/home/random-pic-api/landscape && \
ls -t | head -n 6 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp_pc.sh)
echo "电脑壁纸排序完成"
sleep 2  # 暂停2秒

# 四、电脑原图壁纸排序
echo "===== 开始电脑原图壁纸排序 ====="
cd /vol2/1000/阿里云盘/教程文件/壁纸原图/电脑原图 && \
ls -t | head -n 6 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp-png-jpg_pc.sh)
echo "原图壁纸排序完成"
sleep 2  # 暂停2秒

# 五、比较两个指定目录电脑壁纸目录
echo "===== 开始比较电脑壁纸目录 ====="
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper_pc_dirs.sh)
echo "目录比较完成"

echo "===== 所有电脑壁纸处理步骤已完成 ====="
