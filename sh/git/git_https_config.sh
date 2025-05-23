#!/bin/bash

# 定义颜色变量
GREEN='\033[0;32m'
NC='\033[0m' # 无颜色

# 输出分割线
print_divider() {
    echo -e "${GREEN}--------------------------------------------------${NC}"
}

# 输出信息
print_info() {
    echo -e "${GREEN}$1${NC}"
}

# 欢迎信息
print_divider
print_info "欢迎使用 Git URL 配置脚本！"
print_info "此脚本将自动将当前目录设置为 Git 安全目录，并将远程仓库的连接方式修改为 HTTPS。"
print_divider

# 将当前目录添加到 Git 安全目录
git config --global --add safe.directory "$(pwd)"

print_info "当前目录已添加到 Git 安全目录。"
print_divider

# 检查当前目录是否是一个 Git 仓库
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_info "当前目录不是一个 Git 仓库。"
    exit 1
fi

print_info "当前目录是一个 Git 仓库。"
print_divider

# 获取当前远程仓库信息
remote_info=$(git remote -v)

if [[ -z "$remote_info" ]]; then
    print_info "当前 Git 仓库没有配置远程仓库。"
    exit 1
fi

print_info "当前远程仓库信息："
print_info "$remote_info"
print_divider

print_info "正在将远程仓库修改为 URL 连接..."
print_divider

# 替换远程仓库为 URL 连接
while IFS= read -r line; do
    remote_name=$(echo "$line" | awk '{print $1}')
    remote_url=$(echo "$line" | awk '{print $2}')

    # 检测是否是 Gitee 或 GitHub 的 SSH 链接
    if [[ "$remote_url" =~ ^git@(gitee|github)\.com: ]]; then
        # 转换为 HTTPS 格式
        https_url=$(echo "$remote_url" | sed -e 's|^git@\([^:]*\)\(:\)\(.*\)$|https://\1/\3|')
        print_info "将远程仓库 $remote_name 的 URL 从 $remote_url 修改为 $https_url"
        git remote set-url "$remote_name" "$https_url"
    else
        print_info "远程仓库 $remote_name 的 URL 已经是 HTTPS 格式，无需修改。"
    fi
done <<< "$remote_info"

print_info "远程仓库已更新为 URL 连接。"
print_divider