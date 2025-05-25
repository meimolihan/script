#!/bin/bash

# 定时备份脚本 - 保留最近7天的备份
# 用法：添加到crontab中每日执行

# 配置项
SOURCE_DIR="/vol1/1000/home"        # 要备份的目录
BACKUP_DIR="/vol2/1000/backup"      # 备份存储目录
MAX_BACKUPS=7                      # 保留的最大备份数
COMPRESSION="gz"                   # 压缩格式：gz, bz2, xz

# 确保备份目录存在
mkdir -p "$BACKUP_DIR"

# 获取当前日期
current_date=$(date +%Y%m%d)

# 创建当日备份（修改前缀为compose_）
backup_file="${BACKUP_DIR}/compose_${current_date}.tar.${COMPRESSION}"
echo "正在创建备份: ${backup_file}"

# 执行备份
case $COMPRESSION in
    gz) tar -czvf "$backup_file" --exclude="*.DS_Store" "$SOURCE_DIR" ;;
    bz2) tar -cjvf "$backup_file" --exclude="*.DS_Store" "$SOURCE_DIR" ;;
    xz) tar -cJvf "$backup_file" --exclude="*.DS_Store" "$SOURCE_DIR" ;;
    *) echo "不支持的压缩格式"; exit 1 ;;
esac

# 检查备份是否成功
if [ $? -ne 0 ]; then
    echo "备份失败！"
    exit 1
fi

# 清理旧备份（修改查找模式为compose_）
echo "清理旧备份..."
find "$BACKUP_DIR" -name "compose_*.tar.${COMPRESSION}" -type f -mtime +$MAX_BACKUPS -delete

# 显示结果
echo "备份完成！"
echo "当前备份: ${backup_file}"
echo "保留最近 ${MAX_BACKUPS} 天的备份"