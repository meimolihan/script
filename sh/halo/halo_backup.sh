#!/bin/bash

# =============================================
# Halo 自动备份脚本
# 版本: 1.0
# 描述: 自动备份Halo应用并保留最近3个备份
# =============================================

echo "============================================="
echo "        Halo 自动备份脚本"
echo "============================================="
echo "脚本功能:"
echo "  - 备份 Halo 应用数据"
echo "  - 自动保留最新的 3 个备份文件"
echo "  - 生成带时间戳的备份文件"
echo ""
echo "备份源: /vol1/1000/compose/halo"
echo "备份目标: /vol2/1000/阿里云盘/教程文件/Halo/backup/Halo-PostgreSQL"
echo "============================================="
echo ""

# 定义目录和备份路径
BACKUP_SRC_DIR="/vol1/1000/compose"
BACKUP_DEST="/vol2/1000/阿里云盘/教程文件/Halo/backup/Halo-PostgreSQL"
BACKUP_PREFIX="halo"
TIMESTAMP=$(date +%Y%m%d_%H%M)

# 创建备份目录（如果不存在）
echo "创建备份目录..."
mkdir -p "$BACKUP_DEST"

# 执行备份（保留halo目录本身）
echo "正在创建备份文件..."
tar -czf "${BACKUP_DEST}/${BACKUP_PREFIX}_${TIMESTAMP}.tar.gz" -C "$BACKUP_SRC_DIR" halo

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "✓ 备份成功完成: ${BACKUP_PREFIX}_${TIMESTAMP}.tar.gz"
else
    echo "✗ 备份失败，请检查错误信息"
    exit 1
fi

# 删除旧备份，仅保留最新的3个文件
echo "清理旧备份文件..."
cd "$BACKUP_DEST" || exit
BACKUP_COUNT=$(ls -1 ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null | wc -l)

if [ $BACKUP_COUNT -gt 3 ]; then
    ls -t ${BACKUP_PREFIX}_*.tar.gz | tail -n +4 | xargs -r rm -f
    echo "已删除 $(($BACKUP_COUNT - 3)) 个旧备份文件"
fi

# 显示当前备份文件列表
echo ""
echo "当前备份文件:"
ls -lh ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null || echo "暂无备份文件"

echo ""
echo "============================================="
echo "备份完成! 总共保留 $((BACKUP_COUNT > 3 ? 3 : BACKUP_COUNT)) 个备份文件"
echo "============================================="