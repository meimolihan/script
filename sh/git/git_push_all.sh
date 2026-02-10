#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# 一键批量提交并推送 Git 仓库
# 用法：./git_push_all.sh  [起始目录]  [提交信息]  [排除目录]
# 示例：./git_push_all.sh  ~/code  "daily update"  "node_modules|vendor"
# -----------------------------------------------------------------------------
set -euo pipefail

# ------------------------------ 颜色定义 ------------------------------
gl_hui='\e[37m'     # 灰色（或浅白）
gl_hong='\033[31m'  # 红色
gl_lv='\033[32m'    # 绿色
gl_huang='\033[33m' # 黄色
gl_lan='\033[34m'   # 蓝色
gl_bai='\033[0m'    # 重置
gl_zi='\033[35m'    # 紫色
gl_bufan='\033[96m' # 亮青色
gl_info='\033[94m'  # 亮蓝色（信息）

# ------------------------------ 日志函数 ------------------------------
log_info()  { echo -e "${gl_info}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# ------------------------------ 主逻辑 ------------------------------
main() {
    local start_dir="${1:-$(pwd)}"
    local commit_msg="${2:-update}"
    local exclude_dirs="${3:-}"

    clear
    echo -e "${gl_zi}>>> 正在推送所有仓库更改${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
    start_time=$(date '+%F %T'); start_ts=$(date +%s)
    echo -e "${gl_bai}开始推送时间：${gl_lv}$start_time${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    echo -e "${gl_bai}开始推送目录 ${gl_lv}$start_dir${gl_bai} 下的所有仓库更改${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"

    # 进入起始目录
    cd "$start_dir" || {
        log_error "无法进入目录：$start_dir"
        exit 1
    }

    # 构建排除参数
    local exclude_args=()
    if [[ -n "$exclude_dirs" ]]; then
        IFS='|' read -ra arr <<< "$exclude_dirs"
        for d in "${arr[@]}"; do
            exclude_args+=("-not" "-path" "*/$d/*")
        done
    fi

    # 查找所有 .git 目录
    while IFS= read -r -d '' git_dir; do
        repo_dir=$(dirname "$git_dir")

        # 二次校验：必须是合法仓库
        [[ -f "$git_dir/config" ]] || continue

        echo
        echo -e "${gl_huang}>>> 正在处理仓库：${gl_lv}$(basename "$repo_dir")${gl_bai}"

        # 子 Shell 中操作，避免目录跳转副作用
        (
            set -e
            # 检测变更
            if [[ -n $(git -C "$repo_dir" status --porcelain) ]]; then
                log_info "检测到更改，正在提交${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
                git -C "$repo_dir" add .
                git -C "$repo_dir" commit -m "$commit_msg"
            else
                echo -e "${gl_bai}工作区干净，无需提交"
            fi

            # 拉取并推送
            git -C "$repo_dir" pull --rebase 2>/dev/null || true
            git -C "$repo_dir" push 2>/dev/null || {
                log_error "推送失败：$(basename "$repo_dir")"
                exit 1
            }
        )

        if [[ $? -eq 0 ]]; then
            log_ok "推送完成 ${gl_lv}$(basename "$repo_dir")${gl_bai}"
        else
            log_error "推送失败 ${gl_lv}$(basename "$repo_dir")${gl_bai}"
        fi

    done < <(find . -type d -name '.git' "${exclude_args[@]}" -print0)

    echo -e ""
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    log_ok "全部处理完毕！"
    end_time=$(date '+%F %T'); end_ts=$(date +%s)
    total=$((end_ts - start_ts))
    printf -v dur "%d时%02d分%02d秒" $((total/3600)) $(((total%3600)/60)) $((total%60))
    echo -e "${gl_bai}结束推送时间：${gl_hong}$end_time${gl_bai}"
    echo -e "${gl_bai}推送用时共计：${gl_lv}$dur${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
}

main "$@"