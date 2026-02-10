#!/bin/bash

# ==================== 颜色变量定义 ====================
gl_hui='\e[37m'     # 灰色（或浅白）
gl_hong='\033[31m'  # 红色
gl_lv='\033[32m'    # 绿色
gl_huang='\033[33m' # 黄色
gl_lan='\033[34m'   # 蓝色
gl_bai='\033[0m'    # 重置终端颜色
gl_zi='\033[35m'    # 紫色（或品红）
gl_bufan='\033[96m' # 亮青色（或浅蓝）
gl_info='\033[94m'  # 亮蓝色

# ==================== Gitee 脚本库 URL ====================
GITEE_SCRIPT_BASE_URL="https://gitee.com/meimolihan/script/raw/master/wallpaper/phone"

# ==================== 目录变量定义 ====================
PHOTOS_DIR="/vol1/1000/compose/random-pic-api/photos" # 待处理目录
BACKUP_DIR="/vol2/1000/阿里云盘/教程文件/壁纸原图/手机原图" # 壁纸原图目录
LANDSCAPE_DIR="/vol1/1000/compose/random-pic-api/portrait" # 壁纸目录

# ==================== 函数定义 ====================

# 按任意键继续
break_end() {
    echo -e "\n${gl_lv}操作完成${gl_bai}"
    echo -e "${gl_bai}按任意键继续${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai} \c"
    read -r -n 1 -s
    echo ""
    clear
}

# 用户确认函数
confirm_action() {
    local prompt="$1"
    local default="$2"  # y 或 n
    local choices="(${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai})"
    [[ "$default" == "y" ]] && choices="(${gl_lv}Y${gl_bai}/${gl_hong}n${gl_bai})"
    
    read -r -p "$(echo -e "${gl_bai}${prompt} ${choices}: ")" confirm
    confirm=${confirm:-$default}  # 如果用户直接回车，使用默认值
    
    [[ "$confirm" =~ ^[Yy]$ ]]
}

# 检查并进入目录
check_and_cd() {
    local dir="$1"
    local err_msg="$2"
    
    if cd "$dir" 2>/dev/null; then
        echo -e "${gl_lv}已进入目录: ${dir}${gl_bai}"
        return 0
    else
        echo -e "${gl_hong}${err_msg}${gl_bai}"
        return 1
    fi
}

# 检查是否有图片文件
check_image_files() {
    shopt -s nullglob nocaseglob
    local files=("$PHOTOS_DIR"/*.{jpg,jpeg,png,webp})
    
    if ((${#files[@]} == 0)); then
        echo ""
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        echo -e "${gl_bai}待整理目录：${gl_huang}${PHOTOS_DIR}${gl_bai}"
        echo -e "${gl_hong}未找到 .jpg、.jpeg、.png、.webp 壁纸文件，脚本终止。${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        break_end
        exit 1
    fi
    
    echo -e "${gl_info}找到 ${#files[@]} 个图片文件${gl_bai}"
    return 0
}

# 备份原图函数
backup_photos() {
    if ! confirm_action "是否备份手机壁纸原图" "n"; then
        echo -e "${gl_huang}已跳过原图备份${gl_bai}"
        return 0
    fi
    
    # 检查源目录是否还有文件
    if [ -z "$(ls -A "$PHOTOS_DIR" 2>/dev/null)" ]; then
        echo -e "${gl_huang}源目录已为空，无需备份${gl_bai}"
        return 0
    fi
    
    echo -e "${gl_lv}正在备份原图${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
    
    # 创建备份目录（如果不存在）
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    
    # 移动文件，避免覆盖已有文件
    if mv -n "$PHOTOS_DIR"/* "$BACKUP_DIR"/ 2>/dev/null; then
        echo -e "${gl_lv}原图备份完成${gl_bai}"
        echo -e "${gl_info}备份目录: ${BACKUP_DIR}${gl_bai}"
    else
        echo -e "${gl_hong}备份过程中出现错误${gl_bai}"
        return 1
    fi
}

# 执行远程脚本
execute_remote_script() {
    local script_name="$1"
    local script_url="${GITEE_SCRIPT_BASE_URL}/${script_name}"
    
    echo -e "${gl_info}正在执行: ${GITEE_SCRIPT_BASE_URL}/${script_name}${gl_bai}"
    
    if bash <(curl -sL "$script_url"); then
        echo -e "${gl_lv}${GITEE_SCRIPT_BASE_URL}/${script_name} 执行完成${gl_bai}"
        return 0
    else
        echo -e "${gl_hong}${GITEE_SCRIPT_BASE_URL}/${script_name} 执行失败${gl_bai}"
        return 1
    fi
}

# 显示最近文件
show_recent_files() {
    local dir="$1"
    local count="${2:-6}"
    
    if [ -d "$dir" ]; then
        echo -e "${gl_lv}最近${count}个文件：${gl_bai}"
        ls -t "$dir" 2>/dev/null | head -n "$count"
    fi
}

# ==================== 主程序开始 ====================

clear

# 1. 检查图片文件
check_image_files

echo ""
echo -e "${gl_zi}>>> 开始整理手机壁纸${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"

# 2. 整理壁纸
if cd /vol1/1000/compose/random-pic-api && python3 classify.py; then
    echo -e "${gl_lv}壁纸整理完成${gl_bai}"
else
    echo -e "${gl_hong}[ERROR] classify.py 执行失败，脚本终止${gl_bai}" >&2
    exit 1
fi

# 3. 备份原图
echo ""
echo -e "${gl_zi}>>> 开始备份手机壁纸原图${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
backup_photos

# 4. 比较目录
echo ""
echo -e "${gl_zi}>>> 开始比较手机壁纸目录${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
execute_remote_script "wallpaper_phone_dirs.sh"
echo -e "${gl_lv}目录比较完成${gl_bai}"

# 5. 询问是否继续
if ! confirm_action "是否继续执行后续步骤" "n"; then
    echo "脚本已退出。"
    exit 0
fi

echo -e "${gl_lv}继续执行后续步骤${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"

# 6. 手机壁纸排序
echo ""
echo -e "${gl_zi}>>> 开始手机壁纸排序${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"

if check_and_cd "$LANDSCAPE_DIR" "无法进入目录: $LANDSCAPE_DIR"; then
    show_recent_files "$LANDSCAPE_DIR" 6
    execute_remote_script "rename_webp_phone.sh"
fi

# 7. 手机原图壁纸排序
echo ""
echo -e "${gl_zi}>>> 开始手机原图壁纸排序${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"

if check_and_cd "$BACKUP_DIR" "无法进入目录: $BACKUP_DIR"; then
    show_recent_files "$BACKUP_DIR" 6
    execute_remote_script "rename_webp-png-jpg_phone.sh"
fi

# 8. 结束
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
break_end