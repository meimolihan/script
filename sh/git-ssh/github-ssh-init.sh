#!/usr/bin/env bash
# =============================================================================
#  名称: github-ssh-init.sh
#  作用: 全自动完成 GitHub SSH 密钥初始化
#        1) 检测并安装 git（Debian/Ubuntu/CentOS/RHEL/openSUSE）
#        2) 生成 4096 位 RSA 密钥
#        3) 终端打印公钥，等待用户手动添加到 GitHub
#        4) 写入 ssh config → 添加 known_hosts → 测试连通性
#  用法: chmod +x github-ssh-init.sh && ./github-ssh-init.sh
#  兼容: Linux / macOS / Windows-Git-Bash
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

clear
echo -e ""
echo -e "${gl_zi}>>> GitHub SSH 密钥设置${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_huang}本脚本将带你零配置完成 GitHub SSH 密钥设置，只需按提示操作即可！${gl_bai}"
echo -e "${gl_bai}官方公钥页面：${gl_lv}https://github.com/settings/keys  ${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e ""
echo -e "${gl_lv}>>>>>>>>>>>>>>>>${gl_bai} 脚本开始 ${gl_lv}<<<<<<<<<<<<<<<<${gl_bai}"

# ---------------- 可自定义变量 ----------
GITHUB_USER="meimolihan"
GITHUB_EMAIL="meimolihan@gmail.com"
KEY_COMMENT="$GITHUB_EMAIL"
KEY_FILE="$HOME/.ssh/id_rsa_github"
# ---------------------------------------

log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功 ]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }


# 1. 检测并安装 git
install_git_if_needed() {
    if command -v git &>/dev/null; then
        local ver
        ver=$(git --version)
        log_ok "git 已安装: ${gl_lv}${ver}${gl_bai}"
        return
    fi
    log_warn "未检测到 git，正在根据发行版自动安装..."
    if [ -f /etc/debian_version ]; then
        sudo apt-get update -qq && sudo apt-get install -y git
    elif [ -f /etc/redhat-release ]; then
        if command -v dnf &>/dev/null; then sudo dnf -y install git
        else sudo yum -y install git; fi
    elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ]; then
        sudo zypper -n install git
    else log_error "未识别的 Linux 发行版，请手动安装 git 后重试"; exit 1; fi
    log_ok "git 安装完成: $(git --version)"
}

# 2. Git 全局配置
step_git_config() {
    log_info "Step 1/6  Git 全局配置"
    git config --global user.name  "$GITHUB_USER"
    git config --global user.email "$GITHUB_EMAIL"
    log_ok "Git 全局配置完成"
}

# 3. 生成 RSA 密钥
step_gen_key() {
    log_info "Step 2/6  生成 4096 位 RSA 密钥（无密码）"
    if [ -f "$KEY_FILE" ]; then
        log_warn "密钥已存在，将直接使用：${gl_huang}$KEY_FILE${gl_bai}"
    else
        ssh-keygen -t rsa -b 4096 -C "$KEY_COMMENT" -f "$KEY_FILE" -N ""
        log_ok "密钥生成完成 → $KEY_FILE"
    fi
}

# 4. 打印公钥并等待用户确认已添加到 GitHub
step_show_pub_and_wait() {
    log_info "Step 3/6  你的 SSH 公钥如下（${gl_huang}请完整复制，包括 ssh-rsa 开头与末尾注释${gl_bai}）："
    echo -e "${gl_bufan}------------------------${gl_bai}"
    cat "${KEY_FILE}.pub"
    echo -e "${gl_bufan}------------------------${gl_bai}"
    echo -e "${gl_lan}打开 GitHub 官方添加页面：${gl_bai} ${gl_lv}https://github.com/settings/keys ${gl_bai}"
    echo
    log_warn "请立即在网页添加公钥，添加完成后回到终端按 Enter 继续..."
    read -r -p ""
    log_ok "已确认添加，继续后续步骤"
}

# 5. 写入 ssh config
step_ssh_config() {
    log_info "Step 4/6  写入 ~/.ssh/config"
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    cat > ~/.ssh/config <<EOF
Host github.com
    User git
    Hostname ssh.github.com
    Port 443
    IdentityFile $KEY_FILE
    IdentitiesOnly yes
EOF
    chmod 600 ~/.ssh/config
    log_ok "ssh config 写入完成"
}

# 6. 添加 known_hosts
step_known_hosts() {
    log_info "Step 5/6  添加 GitHub 主机密钥"
    ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true
    log_ok "known_hosts 更新完成"
}

# 7. 测试连通性
step_test() {
    log_info "Step 6/6  测试 SSH 连通性"
    ssh -T git@github.com || true
    log_ok "若上方出现 GitHub 欢迎语，则配置成功！"
}

# ---------------- 主流程 ----------------
main() {
    install_git_if_needed
    step_git_config
    step_gen_key
    step_show_pub_and_wait
    step_ssh_config
    step_known_hosts
    step_test
    echo -e "\n${gl_lv}全部完成！现在可以用 SSH 协议 clone/push 仓库了。${gl_bai}"
}

main "$@"