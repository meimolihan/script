#!/bin/bash

# =============================================
# 子目录单独备份脚本（免交互版本）
# 版本: 3.0
# 描述: 将源目录下的每个子目录单独压缩到备份目录
# 使用方法: ./directory_backup.sh <源目录> <备份目录> [保留备份数量]
# =============================================

echo "============================================="
echo "     子目录单独备份脚本（免交互版本）V3.0"
echo "============================================="
echo "脚本功能:"
echo "  - 遍历源目录下的每个子目录"
echo "  - 每个子目录单独压缩为一个备份文件"
echo "  - 自动保留指定数量的备份文件（默认3个）"
echo "  - 完全免交互，适合自动化任务"
echo ""
echo "使用方法: bash  directory_backup.sh <源目录> <备份目录> [保留备份数量]"
echo "使用示例: bash  directory_backup.sh /path/to/source /path/to/backup 5"
echo "============================================="
echo

# 检查参数数量
if [ $# -lt 2 ]; then
    echo "错误：必须指定源目录和备份目录"
    echo "使用方法: $0 <源目录> <备份目录> [保留备份数量]"
    exit 1
fi

BACKUP_SRC_DIR="$1"
BACKUP_DEST="$2"
KEEP_COUNT=${3:-3} # 默认保留3个备份

# 获取源目录的basename作为备份前缀
BACKUP_PREFIX=$(basename "$BACKUP_SRC_DIR")
# 使用更精确的时间戳（包括秒）
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 验证源目录是否存在
if [ ! -d "$BACKUP_SRC_DIR" ]; then
    echo "错误：源目录 '$BACKUP_SRC_DIR' 不存在！"
    exit 1
fi

# 创建备份目录
mkdir -p "$BACKUP_DEST"
if [ $? -ne 0 ]; then
    echo "错误：无法创建备份目录 '$BACKUP_DEST'，请检查权限！"
    exit 1
fi

if [ ! -w "$BACKUP_DEST" ]; then
    echo "错误：没有写权限到备份目录 '$BACKUP_DEST'！"
    exit 1
fi

echo "源目录: $BACKUP_SRC_DIR"
echo "备份目录: $BACKUP_DEST"
echo "保留备份数量: $KEEP_COUNT"
echo
echo "============================================="
echo ""

# 获取当前时间戳
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 遍历源目录下的每个子目录
for SUBDIR in "$BACKUP_SRC_DIR"/*; do
    if [ -d "$SUBDIR" ]; then
        SUBDIR_NAME=$(basename "$SUBDIR")
        BACKUP_FILE="${BACKUP_DEST}/${SUBDIR_NAME}_${TIMESTAMP}.tar.gz"

        echo "正在备份子目录: $SUBDIR_NAME"
        tar -czf "$BACKUP_FILE" -C "$BACKUP_SRC_DIR" "$SUBDIR_NAME"

        if [ $? -eq 0 ]; then
            echo "✓ 备份成功: $(basename "$BACKUP_FILE")"
        else
            echo "✗ 备份失败: $SUBDIR_NAME"
        fi
    fi
done

echo ""
echo "============================================="
# 删除旧备份，仅保留指定数量的最新文件
echo ""
echo "清理旧备份文件..."
cd "$BACKUP_DEST" || exit

for PREFIX in $(ls -1 *.tar.gz 2>/dev/null | sed 's/_[0-9]\{8\}_[0-9]\{6\}\.tar\.gz$//' | sort -u); do
    FILES=($(ls -1t "${PREFIX}"_*.tar.gz 2>/dev/null))
    FILE_COUNT=${#FILES[@]}
    if [ $FILE_COUNT -gt $KEEP_COUNT ]; then
        for ((i=KEEP_COUNT; i<FILE_COUNT; i++)); do
            echo "删除旧备份: ${FILES[i]}"
            rm -f "${FILES[i]}"
        done
    fi
done

# 显示当前备份文件列表
echo ""
echo "============================================="
echo ""
echo "当前备份文件列表:"
ls -1t *.tar.gz 2>/dev/null | head -n $((KEEP_COUNT * 10)) | while read -r file; do
    size=$(du -h "$file" | cut -f1)
    date=$(date -r "$file" "+%Y-%m-%d %H:%M:%S")
    echo "  - $file ($size, 创建于: $date)"
done

echo ""
echo "============================================="
CURRENT_COUNT=$(ls -1 *.tar.gz 2>/dev/null | wc -l)
echo "备份完成! 总共保留 $CURRENT_COUNT 个备份文件"
echo "============================================="