#!/bin/bash
clear  # 清屏命令

# 随机壁纸处理脚本 - 手机壁纸
# 一、整理壁纸
echo "===== 开始整理手机壁纸 ====="
cd /vol1/1000/home/random-pic-api && \
python3 classify.py
echo "壁纸整理完成"
sleep 2  # 暂停2秒

# 二、备份手机壁纸原图
clear  # 清屏命令
echo "===== 开始备份手机壁纸原图 ====="
mv -i /vol1/1000/home/random-pic-api/photos/* /vol2/1000/阿里云盘/教程文件/壁纸原图/手机原图/
echo "原图备份完成"
sleep 2  # 暂停2秒

# 三、比较两个指定目录手机壁纸目录
clear  # 清屏命令
echo "===== 开始比较手机壁纸目录 ====="
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper_phone_dirs.sh)

read -p "是否继续执行后续步骤？输入y继续，输入n退出：" choice
case "$choice" in
    y|Y ) echo "继续执行后续步骤...";;
    n|N ) echo "脚本已退出。"; exit 0;;
    * ) echo "无效输入，脚本已退出。"; exit 1;;
esac

# 四、已完成手机壁纸排序
clear  # 清屏命令
echo "===== 开始手机壁纸排序 ====="
cd /vol1/1000/home/random-pic-api/portrait && \
ls -t | head -n 6 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp_phone.sh)
sleep 2  # 暂停2秒

# 五、手机原图壁纸排序
clear  # 清屏命令
echo "===== 开始手机原图壁纸排序 ====="
cd /vol2/1000/阿里云盘/教程文件/壁纸原图/手机原图 && \
ls -t | head -n 6 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp-png-jpg_phone.sh)


