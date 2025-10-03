#!/bin/bash
#=================================================================
#  多目录/文件增量同步工具  rsync.sh  v1.2
#  新增：-f 开关，支持单文件多目标同步
#  Author:  mobufan
#  Date  :  2025-09-26
#=================================================================
set -euo pipefail

#-------------- 颜色定义 --------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; NC='\033[0m'

#-------------- 日志相关 --------------
LOG_DIR="/var/log/rsync"
LOG_FILE="$LOG_DIR/rsync.log"
mkdir -p "$LOG_DIR"
ROTATE_CONF="/etc/logrotate.d/rsync"
if [[ ! -f "$ROTATE_CONF" ]]; then
  sudo tee "$ROTATE_CONF" >/dev/null <<'EOF'
/var/log/rsync/*.log {
    daily   rotate 4   maxage 15   compress   delaycompress
    missingok   notifempty   copytruncate
}
EOF
fi

# 双通道日志：终端带色，文件去色
log(){
  local color=$1; shift
  echo -e "${color}${*}${NC}"
  echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"
}

#-------------- 横幅 --------------
echo -e "\033[1;36m
╔══════════════════════════════════════════════════════════════╗
║     多目录/文件增量同步工具  rsync.sh  \033[1;33m★ v1.2 ★\033[1;36m            ║
║        一键多目标 · 彩色日志 · 完成度估算 · 耗时统计         ║
╚══════════════════════════════════════════════════════════════╝
\033[0m"

#-------------- 模式识别 --------------
SINGLE_FILE=false
if [[ ${1:-} == "-f" ]]; then
  SINGLE_FILE=true
  shift
fi

#-------------- 入参检查 --------------
if [[ $# -lt 2 ]]; then
  log "$RED" "用法1（目录）: $0 <源目录> <目标目录1> [目标目录2] ..."
  log "$RED" "用法2（文件）: $0 -f <源文件> <目标文件1> [目标文件2] ..."
  exit 1
fi

source_path="${1%/}"; shift
targets=("$@")

#-------------- 启动横幅写入日志 --------------
{ echo ""; echo "========== rsync.sh 启动：$(date '+%F %T') =========="; } >> "$LOG_FILE"

#-------------- 源存在性检查 --------------
if ! $SINGLE_FILE; then
  log "$CYAN" "检查源目录是否存在..."
  [[ -d $source_path ]] || { log "$RED" "源目录不存在：$source_path"; exit 1; }
  log "$GREEN" "✓ 源目录存在：$source_path"
else
  log "$CYAN" "检查源文件是否存在..."
  [[ -f $source_path ]] || { log "$RED" "源文件不存在：$source_path"; exit 1; }
  log "$GREEN" "✓ 源文件存在：$source_path"
fi

#-------------- rsync 安装检查 --------------
log "$CYAN" "检查 rsync 是否安装..."
if ! command -v rsync &>/dev/null; then
  log "$YELLOW" "rsync 未安装，正在尝试自动安装..."
  sudo apt-get update -qq && sudo apt-get install -y rsync || {
    log "$RED" "rsync 安装失败，请手动安装后重试"; exit 1
  }
fi
log "$GREEN" "✓ rsync 已就绪"

#-------------- 同步函数 --------------
sync_and_check(){
  local tgt=$1; local idx=$2
  local tgt_dir=$(dirname "$tgt")

  if [[ ! -d $tgt_dir ]]; then
    log "$YELLOW" "目标目录不存在，正在创建：$tgt_dir"
    mkdir -p "$tgt_dir" || { log "$RED" "创建失败：$tgt_dir"; return 1; }
  fi

  if $SINGLE_FILE; then
    log "$PURPLE" "开始同步文件：$source_path  →  $tgt"
    rsync -avh --progress "$source_path" "$tgt" 2>&1 | tee -a "$LOG_FILE"
  else
    log "$PURPLE" "开始同步目录：$source_path/  →  $tgt/"
    rsync -avhzp --progress --delete "$source_path/" "$tgt/" 2>&1 | tee -a "$LOG_FILE"
  fi
  local st=${PIPESTATUS[0]}

  if [[ $st -eq 0 ]]; then
    if $SINGLE_FILE; then
      log "$GREEN" "✓ 文件同步成功（目标$idx）"
    else
      local src_size=$(du -sb "$source_path" | awk '{print $1}')
      local tgt_size=$(du -sb "$tgt"      | awk '{print $1}')
      local comp=$(awk -v s=$src_size -v t=$tgt_size 'BEGIN{printf "%.2f",(t/s)*100}')
      log "$GREEN" "✓ 目录同步成功（目标$idx）  完成度约 ${comp}%"
    fi
  else
    log "$RED"  "✗ 同步失败（目标$idx），请查看日志"
  fi
}

#-------------- 主流程 --------------
start_time=$(date '+%F %T'); start_ts=$(date +%s)
log "$GREEN" "同步开始时间：$start_time"

for i in "${!targets[@]}"; do
  log "$BLUE" "----------------------------------------"
  sync_and_check "${targets[$i]}" "$((i+1))"
done

end_time=$(date '+%F %T'); end_ts=$(date +%s)
total=$((end_ts - start_ts))
printf -v dur "%d时%02d分%02d秒" $((total/3600)) $(((total%3600)/60)) $((total%60))

log "$BLUE"  "----------------------------------------"
log "$WHITE" "同步结束时间：$end_time"
log "$WHITE" "总用时：$dur"
if $SINGLE_FILE; then
  log "$WHITE" "源文件：$source_path"
  log "$WHITE" "目标文件列表："; printf '  %s\n' "${targets[@]}" | tee -a "$LOG_FILE"
else
  log "$WHITE" "源目录：$source_path"
  log "$WHITE" "目标目录列表："; printf '  %s\n' "${targets[@]}" | tee -a "$LOG_FILE"
fi
log "$CYAN"  "----------------------------------------"
log "$GREEN" "完整日志已保存至：$LOG_FILE"
{ echo "========== rsync.sh 结束：$(date '+%F %T') =========="; echo ""; } >> "$LOG_FILE"