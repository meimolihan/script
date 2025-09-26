#!/bin/bash
#=================================================================
#  欢迎使用多目录增量同步工具  rsync.sh  v1.0
#  Author:  <你的名字/组织>
#  Date  :  2025-09-26
#
#  功能说明：
#    1. 支持一次指定 1 个源目录、N 个目标目录；
#    2. 自动创建缺失目标目录；
#    3. 实时进度 + 完成度估算；
#    4. 彩色日志，一目了然；
#    5. 统计总耗时。
#
#  使用示例：
#    ./rsync.sh /源目录 /目标1 [/目标2 ...]
#
#  注意：
#    * 源目录与目标目录请勿带末尾“/”，脚本已自动处理。
#    * 首次运行若缺少 rsync，将尝试自动安装（Debian/Ubuntu）。
#=================================================================
echo -e "\033[1;36m
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     多目录增量同步工具  rsync.sh  \033[1;33m★ v1.0 ★\033[1;36m                   ║
║                                                              ║
║      一键多目标 · 彩色输出 · 完成度估算 · 耗时统计           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
\033[0m"

set -euo pipefail

#-------------- 颜色定义 --------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; NC='\033[0m'

print_color() { echo -e "${1}${2}${NC}"; }

#-------------- 入参检查 --------------
if [[ $# -lt 2 ]]; then
    print_color "$RED" "用法：$0 <源目录> <目标目录1> [目标目录2] ..."
    exit 1
fi

source_dir="${1%/}"      # 去掉末尾 /
shift
target_dirs=("$@")       # 剩余参数全部视为目标目录

#-------------- 基本检查 --------------
print_color "$CYAN" "检查源目录是否存在..."
[[ -d $source_dir ]] || { print_color "$RED" "源目录不存在：$source_dir"; exit 1; }
print_color "$GREEN" "✓ 源目录存在：$source_dir"

print_color "$CYAN" "检查 rsync 是否安装..."
if ! command -v rsync &>/dev/null; then
    print_color "$YELLOW" "rsync 未安装，正在尝试自动安装..."
    sudo apt-get update -qq && sudo apt-get install -y rsync || {
        print_color "$RED" "rsync 安装失败，请手动安装后重试"
        exit 1
    }
fi
print_color "$GREEN" "✓ rsync 已就绪"

#-------------- 同步函数 --------------
sync_and_check() {
    local tgt="${1%/}"
    local name="路径$2"

    if [[ ! -d $tgt ]]; then
        print_color "$YELLOW" "目标目录不存在，正在创建：$tgt"
        mkdir -p "$tgt" || { print_color "$RED" "创建失败：$tgt"; return 1; }
    fi

    print_color "$PURPLE" "开始同步：$source_dir  →  $tgt"
    rsync -avhzp --progress --delete "$source_dir/" "$tgt/"       # 注意末尾的 / 实现目录内容同步
    local st=$?

    # 简单的完成度估算（可选）
    local src_size=$(du -sb "$source_dir" | awk '{print $1}')
    local tgt_size=$(du -sb "$tgt"      | awk '{print $1}')
    local comp=$(awk -v s="$src_size" -v t="$tgt_size" 'BEGIN{printf "%.2f",(t/s)*100}')
    if [[ $st -eq 0 ]]; then
        print_color "$GREEN" "✓ 同步成功（$name）  完成度约 ${comp}%"
    else
        print_color "$RED"  "✗ 同步失败（$name），请查看上方日志"
    fi
}

#-------------- 主流程 --------------
start_time=$(date '+%Y-%m-%d %H:%M:%S')
start_ts=$(date +%s)
print_color "$GREEN" "同步开始时间：$start_time"

for i in "${!target_dirs[@]}"; do
    print_color "$BLUE" "----------------------------------------"
    sync_and_check "${target_dirs[$i]}" "$((i+1))"
done

print_color "$BLUE" "----------------------------------------"
end_time=$(date '+%Y-%m-%d %H:%M:%S')
end_ts=$(date +%s)
total=$((end_ts - start_ts))
printf -v dur "%d时%02d分%02d秒" $((total/3600)) $(((total%3600)/60)) $((total%60))

print_color "$WHITE" "同步结束时间：$end_time"
print_color "$WHITE" "总用时：$dur"
print_color "$BLUE" "----------------------------------------"
print_color "$WHITE" "源目录：$source_dir"
print_color "$WHITE" "目标目录列表："
printf '  %s\n' "${target_dirs[@]}"