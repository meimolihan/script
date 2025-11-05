#!/bin/bash
# =============================================
# 通用目录备份脚本（免交互版本）
# 版本: 2.1
# 描述: 自动备份指定目录并保留最近指定数量的备份
# 使用方法: ./universal_backup.sh <源目录> <备份目录> [保留备份数量]
# =============================================
set -euo pipefail

#-------------- 颜色定义 --------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; NC='\033[0m'

#-------------- 日志函数 --------------
log(){
  local color=$1; shift
  echo -e "${color}${*}${NC}"
}

#-------------- 横幅 --------------
echo -e "\033[1;36m
╔══════════════════════════════════════════════════════════════════════════════╗
║        通用目录备份脚本（免交互版本） \033[1;33m★ v2.2 ★\033[1;36m                               ║
║        自动保留指定数量 · 彩色日志 · 完全免交互                              ║
║        脚本功能:                                                             ║
║           - 备份指定源目录                                                   ║
║           - 自动保留指定数量的备份文件（默认3个）                            ║
║           - 生成带时间戳的备份文件                                           ║
║           - 完全免交互，适合自动化任务                                       ║
║                                                                              ║
║        使用方法: bash universal_backup.sh <源目录> <备份目录> [保留备份数量] ║
║        使用示例: bash universal_backup.sh /path/to/source /path/to/backup 5  ║
╚══════════════════════════════════════════════════════════════════════════════╝
\033[0m"

# 检查参数数量
if [ $# -lt 2 ]; then
    log "$RED" "错误：必须指定源目录和备份目录"
    log "$WHITE" "使用方法: $0 <源目录> <备份目录> [保留备份数量]"
    log "$WHITE" "示例: $0 /path/to/source /path/to/backup 5"
    exit 1
fi

# 设置目录和备份路径
BACKUP_SRC_DIR="$1"
BACKUP_DEST="$2"
KEEP_COUNT=${3:-3}  # 默认保留3个备份

# 获取源目录的basename作为备份前缀
BACKUP_PREFIX=$(basename "$BACKUP_SRC_DIR")
# 使用更精确的时间戳（包括秒）
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 验证源目录是否存在
if [ ! -d "$BACKUP_SRC_DIR" ]; then
    log "$RED" "错误：源目录 '$BACKUP_SRC_DIR' 不存在！"
    exit 1
fi

# 创建备份目录（如果不存在）
log "$CYAN" "创建备份目录..."
mkdir -p "$BACKUP_DEST"

if [ $? -ne 0 ]; then
    log "$RED" "错误：无法创建备份目录 '$BACKUP_DEST'，请检查权限！"
    exit 1
fi

# 验证备份目录是否可写
if [ ! -w "$BACKUP_DEST" ]; then
    log "$RED" "错误：没有写权限到备份目录 '$BACKUP_DEST'！"
    exit 1
fi

log "$BLUE"  "源目录: $BACKUP_SRC_DIR"
log "$BLUE"  "备份目录: $BACKUP_DEST"
log "$BLUE"  "保留备份数量: $KEEP_COUNT"
log "$BLUE"  "备份前缀: $BACKUP_PREFIX"
log "$CYAN" "----------------------------------------"

# 执行备份
BACKUP_FILE="${BACKUP_DEST}/${BACKUP_PREFIX}_${TIMESTAMP}.tar.gz"
log "$PURPLE" "正在创建备份文件: $(basename "$BACKUP_FILE")"
tar -czf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC_DIR")" "$(basename "$BACKUP_SRC_DIR")"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    log "$GREEN" "✓ 备份成功完成: $(basename "$BACKUP_FILE")"
    log "$GREEN" "备份大小: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    log "$RED" "✗ 备份失败，请检查错误信息"
    exit 1
fi

log "$CYAN" "----------------------------------------"
# 删除旧备份，仅保留指定数量的最新文件
log "$YELLOW" "清理旧备份文件..."
cd "$BACKUP_DEST" || exit

# 获取所有匹配的备份文件并按时间排序（最新的在前）
BACKUP_FILES=($(ls -1t ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null))

# 计算实际文件数量
FILE_COUNT=${#BACKUP_FILES[@]}

if [ $FILE_COUNT -gt $KEEP_COUNT ]; then
    # 删除超出保留数量的最旧文件
    for ((i = $KEEP_COUNT; i < $FILE_COUNT; i++)); do
        log "$YELLOW" "删除旧备份: ${BACKUP_FILES[i]}"
        rm -f "${BACKUP_FILES[i]}"
    done
    log "$GREEN" "已删除 $(($FILE_COUNT - $KEEP_COUNT)) 个旧备份文件"
fi

# 显示当前备份文件列表
log "$CYAN" "----------------------------------------"
log "$WHITE" "当前备份文件列表:"
ls -1t ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null | head -n $KEEP_COUNT | while read -r file; do
    size=$(du -h "$file" | cut -f1)
    date=$(date -r "$file" "+%Y-%m-%d %H:%M:%S")
    echo -e "  ${WHITE}- $file ($size, 创建于: $date)${NC}"
done

log "$CYAN" "----------------------------------------"
CURRENT_COUNT=$(ls -1 ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null | wc -l)
log "$GREEN" "备份完成! 总共保留 $CURRENT_COUNT 个备份文件"
log "$WHITE" "============================================="