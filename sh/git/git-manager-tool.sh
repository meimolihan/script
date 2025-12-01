#!/usr/bin/env bash
# =============================================================================
#  名称: git-repo-manager.sh
#  作用: 统一风格 Git 多仓库管理脚本（克隆/拉取/提交/推送/标签）
#  用法: chmod +x git-repo-manager.sh && ./git-repo-manager.sh
# =============================================================================

set -euo pipefail

# ============================== 颜色变量 ==============================
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'
# ====================================================================

# -------------- 预设仓库表 --------------
declare -A repo=(
    [1]="git@gitee.com:meimolihan/bat.git"
    [2]="git@gitee.com:meimolihan/360.git"
    [3]="git@gitee.com:meimolihan/final-shell.git"
    [4]="git@gitee.com:meimolihan/clash.git"
    [5]="git@gitee.com:meimolihan/dism.git"
    [6]="git@gitee.com:meimolihan/youtube.git"
    [7]="git@gitee.com:meimolihan/ffmpeg.git"
    [8]="git@gitee.com:meimolihan/bcuninstaller.git"
    [9]="git@gitee.com:meimolihan/typora.git"
    [10]="git@gitee.com:meimolihan/lx-music-desktop.git"
    [11]="git@gitee.com:meimolihan/xsnip.git"
    [12]="git@gitee.com:meimolihan/image.git"
    [13]="git@gitee.com:meimolihan/rename.git"
    [14]="git@gitee.com:meimolihan/wallpaper.git"
    [15]="git@gitee.com:meimolihan/trafficmonitor.git"
)
repo_count=${#repo[@]}

# -------------- 工具函数 --------------
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功 ]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

pause() {
    read -r -e -p "按任意键返回菜单..." -n1 -s
}

# -------------- 菜单 --------------
show_menu() {
    clear
    echo -e "${gl_zi}>>> Git 项目管理脚本${gl_bai}"
    echo -e "当前工作目录: ${gl_huang}$(pwd)${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    echo -e "${gl_bufan} 1. ${gl_bai}拉取当前仓库更新"
    echo -e "${gl_bufan} 2. ${gl_bai}提交并推送当前仓库更改"
    echo -e "${gl_bufan} 3. ${gl_bai}更改当前仓库标签"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    echo -e "${gl_bufan} 4. ${gl_bai}拉取所有仓库更新"
    echo -e "${gl_bufan} 5. ${gl_bai}提交并推送所有仓库更改"
    echo -e "${gl_bufan} 6. ${gl_bai}克隆所有仓库菜单"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    echo -e "${gl_huang} 0. ${gl_bai}退出"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    read -r -e -p "请输入操作编号 (0-6): " choice
}

# -------------- 功能实现 --------------
pull_update() {
    clear
    echo -e "${gl_zi}>>> 正在拉取当前仓库更新...${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    echo -e "${gl_lan}当前仓库路径：${gl_bai}$(pwd)"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    if git pull; then
        log_ok "拉取成功！本地仓库已是最新版本。"
    else
        log_error "拉取失败！请检查网络或远程仓库地址。"
    fi
    echo -e "${gl_bufan}------------------------${gl_bai}"
    pause
}

commit_push() {
    clear
    echo -e "${gl_zi}>>> 提交并推送当前仓库更改${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    read -r -e -p "请输入提交信息（直接回车默认为 \"update\"）： " commit_msg
    [[ -z "$commit_msg" ]] && commit_msg="update"

    log_info "正在添加所有更改到暂存区..."
    git add .
    log_ok "添加完成！"

    log_info "正在提交更改，提交信息为：${commit_msg}"
    git commit -m "$commit_msg"
    log_ok "提交完成！"

    log_info "正在推送更改到远程仓库..."
    git push
    log_ok "推送完成！您的更改已成功同步到远程仓库。"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    pause
}

update_git_tag() {
    clear
    [[ ! -d ".git" ]] && {
        log_error "当前目录不是一个有效的 Git 仓库。"
        pause
        return
    }

    echo -e "${gl_zi}>>> 更改当前仓库标签${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"

    log_info "正在添加所有更改并提交..."
    git add .
    git commit -m "update"
    git pull --rebase

    log_info "正在删除本地标签 v1.0.0..."
    git tag -d v1.0.0 2>/dev/null || true

    log_info "正在删除远程标签 v1.0.0..."
    git push origin :refs/tags/v1.0.0 2>/dev/null || true

    read -r -e -p "请输入新标签名（直接回车默认 v1.0.0）： " tag_name
    [[ -z "$tag_name" ]] && tag_name="v1.0.0"

    log_info "正在创建新标签 ${tag_name}..."
    git tag -a "$tag_name" -m "Recreate tags for the latest submission"
    log_ok "标签创建完成！"

    log_info "正在推送新标签到远程仓库..."
    git push origin "$tag_name"
    log_ok "标签推送完成！"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    pause
}

git_update_all() {
    clear
    echo -e "${gl_huang}>>> 正在扫描目录及子目录中的 Git 仓库...${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    log_info "目标目录：$(pwd)"
    echo -e "${gl_bufan}------------------------${gl_bai}"

    find . -type d -name ".git" | while read -r git_dir; do
        repo_dir=$(dirname "$git_dir")
        echo
        log_info "检测到 Git 仓库：${gl_huang}$repo_dir${gl_bai}"
        cd "$repo_dir" || continue
        log_info "正在拉取远程更新..."
        git pull
        log_ok "拉取完成：$repo_dir"
        echo -e "${gl_bufan}------------------------${gl_bai}"
    done

    log_ok "子目录中的所有仓库，拉取更新操作已完成。"
    pause
}

git_push_all() {
    clear
    echo -e "${gl_huang}>>> 正在扫描目录及子目录中的 Git 仓库...${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    log_info "目标目录：$(pwd)"
    echo -e "${gl_bufan}------------------------${gl_bai}"

    find . -type d -name ".git" | while read -r git_dir; do
        repo_dir=$(dirname "$git_dir")
        echo
        log_info "正在处理仓库：${gl_huang}$(basename "$repo_dir")${gl_bai}"
        cd "$repo_dir" || continue
        git add .
        git commit -m "update"
        git pull --rebase
        git push
        log_ok "仓库 $(basename "$repo_dir") 处理完成"
        echo -e "${gl_bufan}------------------------${gl_bai}"
    done

    log_ok "子目录中的所有仓库，推送更新操作已完成。"
    pause
}

git_clone_all_menu() {
    while true; do
        clear
        echo -e "${gl_zi}>>> 克隆所有仓库菜单${gl_bai}"
        echo -e "当前工作目录: ${gl_huang}$(pwd)${gl_bai}"
        echo -e "${gl_bufan}------------------------${gl_bai}"
        for i in $(seq 1 "$repo_count"); do
            name=$(basename "${repo[$i]}" .git)
            echo -e "${gl_lv}$i. 克隆仓库：$name${gl_bai}"
        done
        echo -e "${gl_bufan}------------------------${gl_bai}"
        echo -e "${gl_huang}88. ${gl_bai}克隆新的仓库"
        echo -e "${gl_huang}99. ${gl_bai}克隆所有仓库"
        echo -e "${gl_bufan}------------------------${gl_bai}"
        echo -e "${gl_huang}00. ${gl_bai}退出"
        echo -e "${gl_huang}0. ${gl_bai}返回主菜单"
        echo -e "${gl_bufan}------------------------${gl_bai}"
        read -r -e -p "请输入操作编号: " choice

        case $choice in
            [1-9]|[1-1][0-5])
                url=${repo[$choice]}
                name=$(basename "$url" .git)
                clear
                echo -e "${gl_bufan}------------------------${gl_bai}"
                echo -e "${gl_huang}正在克隆仓库：$name${gl_bai}"
                echo -e "${gl_bufan}------------------------${gl_bai}"
                git clone "$url" || log_error "克隆仓库：$name 失败"
                log_ok "仓库：$name，克隆完成。"
                pause
                ;;
            99)
                git_clone_all
                ;;
            88)
                git_clone_new
                ;;
            0)
                return
                ;;
            00)
                exit_script
                ;;
            *)
                log_error "无效选项，请重新选择。"
                pause
                ;;
        esac
    done
}

git_clone_all() {
    clear
    echo -e "${gl_zi}>>> 正在准备克隆所有仓库...${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    local all_success=1
    for i in "${!repo[@]}"; do
        url=${repo[$i]}
        name=$(basename "$url" .git)
        log_info "正在克隆仓库：$name"
        git clone "$url" || {
            log_error "克隆仓库：$name 失败"
            all_success=0
        }
        echo -e "${gl_bufan}------------------------${gl_bai}"
    done
    [[ $all_success -eq 1 ]] && log_ok "所有仓库克隆成功！" || log_warn "部分仓库克隆失败，请检查网络或仓库地址。"
    pause
}

git_clone_new() {
    clear
    echo -e "${gl_zi}>>> Git 克隆新仓库${gl_bai}"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    read -r -e -p "请输入 Git 仓库 URL 或 git clone 命令: " repoUrl
    [[ -z "$repoUrl" ]] && {
        log_error "未输入有效 URL，返回菜单。"
        pause
        return
    }
    cleanUrl=${repoUrl#*git clone }
    repoName=${cleanUrl##*/}
    repoName=${repoName%.git}

    echo -e "${gl_bufan}------------------------${gl_bai}"
    log_info "正在克隆仓库：$repoName"
    git clone "$cleanUrl" && log_ok "仓库 \"$repoName\" 克隆成功！" || log_error "仓库 \"$repoName\" 克隆失败，请检查 URL 或网络。"
    pause
}

exit_script() {
    clear
    echo -e "\r${gl_hong}感谢使用，再见！ ${gl_zi}2${gl_hong} 秒后自动退出${gl_bai}"
    sleep 1
    echo -e "\r${gl_huang}感谢使用，再见！ ${gl_zi}1${gl_huang} 秒后自动退出${gl_bai}"
    sleep 1
    echo -e "\r${gl_lv}感谢使用，再见！ ${gl_zi}0${gl_lv} 秒后自动退出${gl_bai}"
    sleep 0.5
    exit 0
}

# ---------------- 主循环 ----------------
while true; do
    show_menu
    case $choice in
        1) pull_update ;;
        2) commit_push ;;
        3) update_git_tag ;;
        4) git_update_all ;;
        5) git_push_all ;;
        6) git_clone_all_menu ;;
        0) exit_script ;;
        *) log_error "无效选项，请重新选择。"; pause ;;
    esac
done
