#!/bin/bash

# 使用规范中定义的颜色变量
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# 日志函数（中文标签，彩色输出）
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# 公共函数
break_end() {
    echo -e "${gl_lv}操作完成${gl_bai}"
    echo -e "${gl_bai}按任意键继续${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai} \c"
    read -r -n 1 -s
    echo ""
    clear
}

# 主功能函数
configure_git_https() {
    clear
    echo -e "${gl_zi}>>> Git HTTPS 配置工具${gl_bai}"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"
    log_info "此脚本将自动将当前目录设置为 Git 安全目录，并将远程仓库的连接方式修改为 HTTPS。"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"

    # 将当前目录添加到 Git 安全目录
    log_info "正在将当前目录添加到 Git 安全目录${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
    if git config --global --add safe.directory "$(pwd)"; then
        log_ok "当前目录已添加到 Git 安全目录。"
    else
        log_error "添加到安全目录失败。"
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
        break_end
        return 1
    fi
    
    echo -e "${gl_bufan}————————————————————————${gl_bai}"

    # 检查当前目录是否是一个 Git 仓库
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是一个 Git 仓库。"
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
        break_end
        return 1
    fi

    log_ok "当前目录是一个 Git 仓库。"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"

    # 获取当前远程仓库信息
    remote_info=$(git remote -v)
    if [[ -z "$remote_info" ]]; then
        log_error "当前 Git 仓库没有配置远程仓库。"
        echo -e "${gl_bufan}————————————————————————${gl_bai}"
        break_end
        return 1
    fi

    log_info "当前远程仓库信息："
    echo -e "${gl_hui}$remote_info${gl_bai}"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"

    log_info "正在将远程仓库修改为 HTTPS 连接${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
    echo -e "${gl_bufan}————————————————————————${gl_bai}"

    local changed=0
    while IFS= read -r line; do
        remote_name=$(echo "$line" | awk '{print $1}')
        remote_url=$(echo "$line" | awk '{print $2}')

        # 检测是否是 Gitee 或 GitHub 的 SSH 链接
        if [[ "$remote_url" =~ ^git@(gitee|github)\.com: ]]; then
            # 转换为 HTTPS 格式
            https_url=$(echo "$remote_url" | sed -e 's|^git@\([^:]*\)\(:\)\(.*\)$|https://\1/\3|')
            log_info "将远程仓库 ${remote_name} 的 URL 从 ${remote_url} 修改为 ${https_url}"
            if git remote set-url "$remote_name" "$https_url"; then
                log_ok "远程仓库 ${remote_name} 修改成功。"
                changed=1
            else
                log_error "远程仓库 ${remote_name} 修改失败。"
            fi
        else
            log_info "远程仓库 ${remote_name} 的 URL 已经是 HTTPS 格式，无需修改。"
        fi
    done <<< "$remote_info"

    if [[ $changed -eq 1 ]]; then
        log_ok "远程仓库已更新为 HTTPS 连接。"
    else
        log_info "没有需要修改的远程仓库。"
    fi
    
    echo -e "${gl_bufan}————————————————————————${gl_bai}"
    break_end
}

# 执行主函数
configure_git_https