#!/bin/bash

# 定义颜色变量
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# 定义日志函数
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# 定义公共函数
handle_invalid_input() {
    echo -ne "\r${gl_huang}无效的输入,请重新输入! ${gl_zi} 1 ${gl_huang} 秒后返回"
    sleep 1
    echo -e "\r${gl_lv}无效的输入,请重新输入! ${gl_zi}0${gl_lv} 秒后返回"
    sleep 0.5
    return 2
}

break_end() {
    echo -e "${gl_lv}操作完成${gl_bai}"
    echo -e "${gl_bai}按任意键继续${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai} \c"
    read -r -n 1 -s -r -p ""
    echo ""
    clear
}

exit_script() {
    clear
    exit 0
}

# 主脚本
main() {
    # 设置当前目录为搜索起点
    SEARCH_DIR=$PWD

    clear
    echo -e "${gl_zi}>>> 正在拉取所有仓库更新${gl_bai}"
    start_time=$(date '+%F %T'); start_ts=$(date +%s)
    echo -e "${gl_bai}开始拉取时间：${gl_lv}$start_time${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    echo -e "${gl_bai}开始拉取目录 ${SEARCH_DIR} 下的所有仓库更新${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
    
    echo -e ""
    # 查找当前目录及其子目录中的所有 .git 文件夹
    find "$SEARCH_DIR" -type d -name ".git" -print0 | while IFS= read -r -d '' git_dir; do
        # 获取仓库目录（.git 的父目录）
        repo_dir=$(dirname "$git_dir")
        
        echo -e ">>> ${gl_huang}正在处理仓库：${gl_lv}${repo_dir}${gl_bai}"
        
        # 进入仓库目录
        cd "$repo_dir" || continue
        
        # 获取当前分支名称
        CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [[ -z "$CURRENT_BRANCH" ]]; then
            log_warn "无法获取当前分支信息，跳过此仓库"
            cd - >/dev/null || exit
            continue
        fi
        
        echo -e "${gl_bai}当前分支：${gl_lv}${CURRENT_BRANCH}${gl_bai}"
        
        # 检查远程是否有更新
        echo -e "${gl_bai}正在拉取最新的远程信息${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
        git fetch origin
        
        # 比较本地分支和远程分支的差异
        LOCAL_COMMIT=$(git rev-parse @ 2>/dev/null)
        REMOTE_COMMIT=$(git rev-parse @{u} 2>/dev/null 2>/dev/null)
        BASE_COMMIT=$(git merge-base @ @{u} 2>/dev/null)
        
        if [[ -z "$REMOTE_COMMIT" ]]; then
            log_warn "此分支没有设置上游分支，跳过更新"
        elif [[ $LOCAL_COMMIT == $REMOTE_COMMIT ]]; then
            log_info "当前分支已经是最新版本，无需更新。"
        elif [[ $LOCAL_COMMIT == $BASE_COMMIT ]]; then
            log_info "检测到远程有更新，正在拉取最新代码..."
            git pull origin "$CURRENT_BRANCH"
            if [[ $? -eq 0 ]]; then
                log_ok "更新成功！"
            else
                log_error "更新失败，请检查错误信息。"
            fi
        else
            log_warn "本地分支与远程分支存在分歧（可能有未推送的提交），请手动解决冲突后再更新。"
        fi
        echo -e ""
        # 返回原始目录
        cd - >/dev/null || exit
    done
    
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    log_ok "全部处理完毕！"
    end_time=$(date '+%F %T'); end_ts=$(date +%s)
    total=$((end_ts - start_ts))
    printf -v dur "%d时%02d分%02d秒" $((total/3600)) $(((total%3600)/60)) $((total%60))
    echo -e "${gl_bai}结束拉取时间：${gl_hong}$end_time${gl_bai}"
    echo -e "${gl_bai}拉取用时共计：${gl_lv}$dur${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
}

# 执行主函数
main
