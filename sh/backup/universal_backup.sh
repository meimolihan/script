#!/usr/bash
# =============================================
# 通用目录备份脚本（免交互版本）
# 版本: 2.1
# 描述: 自动备份指定目录并保留最近指定数量的备份
# 使用方法: ./universal_backup.sh <源目录> <备份目录> [保留备份数量]
# =============================================
set -euo pipefail

#-------------- 颜色定义 --------------
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

#-------------- 日志函数 --------------
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

#-------------- 横幅 --------------
echo -e "${gl_bai}
╔══════════════════════════════════════════════════════════════════════════════╗
║        通用目录备份脚本（免交互版本） ${gl_huang}★ v2.2 ★${gl_bai}                               ║
║        自动保留指定数量 · 彩色日志 · 完全免交互                              ║
║        ${gl_huang}脚本功能:${gl_bai}                                                             ║
║           - 备份指定源目录                                                   ║
║           - 自动保留指定数量的备份文件（${gl_huang}默认3个${gl_bai}）                            ║
║           - 生成带时间戳的备份文件                                           ║
║           - 完全免交互，适合自动化任务                                       ║
║                                                                              ║
║        使用方法: ${gl_zi}bash universal_backup.sh${gl_bai} <${gl_hong}源目录${gl_bai}> <${gl_huang}备份目录${gl_bai}> [${gl_lv}保留备份数量${gl_bai}] ║
║        使用示例: ${gl_zi}bash universal_backup.sh ${gl_hong}/path/to/source${gl_bai} ${gl_huang}/path/to/backup${gl_bai} ${gl_lv}5${gl_bai}  ║
╚══════════════════════════════════════════════════════════════════════════════╝
${gl_bai}"

# 检查参数数量
if [ $# -lt 2 ]; then
    log_error "必须指定源目录和备份目录"
    log_info "使用方法: ${gl_zi}$0${gl_bai} <${gl_hong}源目录${gl_bai}> <${gl_huang}备份目录${gl_bai}> [${gl_lv}保留备份数量${gl_bai}]"
    log_info "示例: ${gl_zi}$0${gl_bai} ${gl_hong}/path/to/source${gl_bai} ${gl_huang}/path/to/backup${gl_bai} ${gl_lv}5${gl_bai}"
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
    log_error "源目录 '$BACKUP_SRC_DIR' 不存在！"
    exit 1
fi

# 创建备份目录（如果不存在）
log_info "${gl_bai}创建备份目录${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
mkdir -p "$BACKUP_DEST"

if [ $? -ne 0 ]; then
    log_error "无法创建备份目录 '$BACKUP_DEST'，请检查权限！"
    exit 1
fi

# 验证备份目录是否可写
if [ ! -w "$BACKUP_DEST" ]; then
    log_error "没有写权限到备份目录 '$BACKUP_DEST'！"
    exit 1
fi

echo -e "${gl_bufan}----------------------------------------${gl_bai}"
log_info "${gl_bai}源目录: ${gl_huang}$BACKUP_SRC_DIR${gl_bai}"
log_info "${gl_bai}备份目录: ${gl_lv}$BACKUP_DEST${gl_bai}"
log_info "${gl_bai}保留备份数量: ${gl_huang}$KEEP_COUNT${gl_bai}"
log_info "${gl_bai}备份前缀: ${gl_huang}$BACKUP_PREFIX${gl_bai}"
echo -e "${gl_bufan}----------------------------------------${gl_bai}"

# 执行备份
BACKUP_FILE="${BACKUP_DEST}/${BACKUP_PREFIX}_${TIMESTAMP}.tar.gz"
log_warn "${gl_bai}正在创建备份文件: ${gl_huang}$(basename "$BACKUP_FILE")${gl_bai}"
tar -czf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC_DIR")" "$(basename "$BACKUP_SRC_DIR")"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    log_ok "${gl_bai}备份成功完成: ${gl_lv}$(basename "$BACKUP_FILE")${gl_bai}"
    log_ok "${gl_bai}备份大小: ${gl_lv}$(du -h "$BACKUP_FILE" | cut -f1)${gl_bai}"
else
    log_error "备份失败，请检查错误信息"
    exit 1
fi

echo -e "${gl_bufan}----------------------------------------${gl_bai}"
# 删除旧备份，仅保留指定数量的最新文件
log_warn "${gl_bai}清理旧备份文件${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
cd "$BACKUP_DEST" || exit

# 获取所有匹配的备份文件并按时间排序（最新的在前）
BACKUP_FILES=($(ls -1t ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null))

# 计算实际文件数量
FILE_COUNT=${#BACKUP_FILES[@]}

if [ $FILE_COUNT -gt $KEEP_COUNT ]; then
    # 删除超出保留数量的最旧文件
    for ((i = $KEEP_COUNT; i < $FILE_COUNT; i++)); do
        log_warn "${gl_bai}删除旧备份: ${gl_huang}${BACKUP_FILES[i]}${gl_bai}"
        rm -f "${BACKUP_FILES[i]}"
    done
    log_ok "${gl_bai}已删除 ${gl_huang}$(($FILE_COUNT - $KEEP_COUNT)) ${gl_bai}个旧备份文件"
fi

# 显示当前备份文件列表
echo -e "${gl_bufan}----------------------------------------${gl_bai}"
log_info "当前备份文件列表:"
ls -1t ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null | head -n $KEEP_COUNT | while read -r file; do
    size=$(du -h "$file" | cut -f1)
    date=$(date -r "$file" "+%Y-%m-%d %H:%M:%S")
    echo -e "  ${gl_zi}•${gl_bai} ${gl_hui}$file${gl_bai}  ${gl_huang}($size)${gl_bai}  ${gl_bufan}$date${gl_bai}"
done

echo -e "${gl_bufan}----------------------------------------${gl_bai}"
CURRENT_COUNT=$(ls -1 ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null | wc -l)
log_ok "备份完成! 总共保留 ${gl_lv}$CURRENT_COUNT${gl_bai} 个备份文件"
echo -e "${gl_bufan}----------------------------------------${gl_bai}"
