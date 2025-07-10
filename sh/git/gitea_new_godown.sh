#!/bin/bash

# 设置颜色代码
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'

# 提取并打印仓库目录名（路径的最后一部分）
repo_dir=$(basename "$(pwd)")

echo -e "${BLUE}==================================${RESET}"
echo -e "${BLUE}Gitea 新仓库初始化脚本${RESET}"
echo -e "${BLUE}==================================${RESET}"
echo -e "${YELLOW}注意事项："
echo -e "1. 请确保已在 Gitea 创建名为 ${repo_dir} 的空仓库"
echo -e "2. 脚本已配置 Gitea 访问权限${RESET}"
echo -e "${BLUE}==================================${RESET}"
echo -e "当前操作目录: $(pwd)"
echo -e "${BLUE}==================================${RESET}"
echo -e "仓库目录: ${repo_dir}"
echo -e "${BLUE}==================================${RESET}"

# 检查 git 命令是否存在
if ! command -v git &> /dev/null; then
    echo -e "${RED}错误：未找到 git 命令，请先安装 Git${RESET}"
    exit 1
fi

# 输入验证函数
validate_repo_name() {
    local name="$1"

    # 检查是否为空
    if [[ -z "$name" ]]; then
        echo -e "${RED}错误：仓库名称不能为空${RESET}"
        return 1
    fi

    # 检查包含非法字符（只允许字母、数字、中划线下划线）
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}错误：仓库名称包含非法字符（只允许字母、数字、- 和 _）${RESET}"
        return 1
    fi

    return 0
}

# 获取有效的仓库名称
while true; do
    read -p "请输入仓库名称: " repo_name
    if validate_repo_name "$repo_name"; then
        break
    fi
done

# 检查是否已经是 Git 仓库
if [ -d ".git" ]; then
    echo -e "${YELLOW}警告：当前目录已存在 Git 仓库${RESET}"
    read -p "是否继续操作？(y/n) [n]: " continue_choice
    if [[ "${continue_choice,,}" != "y" ]]; then
        echo -e "${YELLOW}已中止操作${RESET}"
        exit 0
    fi
fi

# 初始化仓库
if ! git init; then
    echo -e "${RED}错误：Git 仓库初始化失败${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ 已初始化 Git 仓库${RESET}"

# 配置安全目录（解决CVE-2022-24765安全问题）
current_dir=$(pwd)
git config --global --add safe.directory "$current_dir"

# 创建/覆盖 README.md
readme_file="README.md"
if [ -f "$readme_file" ]; then
    echo -e "${YELLOW}检测到已存在的 README.md 文件${RESET}"
    read -p "是否覆盖？(y/n) [n]: " overwrite
    if [[ "${overwrite,,}" == "y" ]]; then
        echo "## $repo_name 项目说明" > "$readme_file"
        echo -e "${GREEN}✓ 已创建 README.md${RESET}"
    else
        echo -e "${YELLOW}保留原有 README.md 文件${RESET}"
    fi
else
    echo "## $repo_name 项目说明" > "$readme_file"
    echo -e "${GREEN}✓ 已创建 README.md${RESET}"
fi

# 添加文件到暂存区
if ! git add .; then
    echo -e "${RED}错误：文件添加到暂存区失败${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ 文件已暂存${RESET}"

# 提交更改
if ! git commit -m "首次提交"; then
    echo -e "${RED}错误：提交更改失败${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ 已提交初始版本${RESET}"

# 检查当前分支名
current_branch=$(git branch --show-current)
echo -e "${YELLOW}当前分支: ${current_branch}${RESET}"

# 重命名主分支为 main（如果不是 main）
if [ "$current_branch" != "main" ]; then
    if ! git branch -M main; then
        echo -e "${RED}错误：无法将分支重命名为 main${RESET}"
        echo -e "${YELLOW}尝试直接推送当前分支: ${current_branch}${RESET}"
        push_branch="$current_branch"
    else
        echo -e "${GREEN}✓ 已将分支重命名为 main${RESET}"
        push_branch="main"
    fi
else
    push_branch="main"
fi

# 固定Gitea配置
gitea_username="mobufan"
gitea_server="gitea.mobufan.eu.org:666"
gitea_password="yifan0719"

# 设置远程仓库
remote_url="https://${gitea_username}@${gitea_server}/${gitea_username}/${repo_name}.git"
current_remote=$(git remote get-url origin 2>/dev/null)

# 处理已存在的远程仓库
if [ -n "$current_remote" ]; then
    echo -e "${YELLOW}检测到已存在的远程仓库：${current_remote}${RESET}"
    read -p "是否要替换现有远程仓库？(y/n) [n]: " replace_remote
    if [[ "${replace_remote,,}" == "y" ]]; then
        git remote remove origin
        echo -e "${GREEN}✓ 已移除原有远程仓库${RESET}"
    else
        echo -e "${YELLOW}保留原有远程仓库配置${RESET}"
    fi
fi

# 添加新的远程仓库
if ! git remote add origin "$remote_url"; then
    echo -e "${RED}错误：添加远程仓库失败${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ 已配置远程仓库地址：${remote_url}${RESET}"

# 创建临时密码脚本
pass_script=$(mktemp)
echo "#!/bin/sh" > "$pass_script"
echo "echo \"$gitea_password\"" >> "$pass_script"
chmod +x "$pass_script"

# 设置环境变量以提供密码
export GIT_ASKPASS="$pass_script"

# 推送代码
echo -e "${BLUE}正在推送代码到 Gitea...${RESET}"
echo -e "${YELLOW}推送分支: ${push_branch}${RESET}"
if ! git push -u origin "$push_branch"; then
    echo -e "${RED}错误：代码推送失败，请检查："
    echo -e "1. 远程仓库是否存在"
    echo -e "2. Gitea 访问权限是否配置正确"
    echo -e "3. 网络连接是否正常${RESET}"
    # 删除临时密码脚本
    rm -f "$pass_script"
    exit 1
fi

# 删除临时密码脚本
rm -f "$pass_script"

echo -e "${GREEN}==================================${RESET}"
echo -e "${GREEN}仓库初始化并推送成功！${RESET}"
echo -e "${GREEN}仓库地址：${remote_url}${RESET}"
echo -e "${GREEN}==================================${RESET}"

# 获取当前远程仓库信息
remote_info=$(git remote -v | awk '{print $1, $2, $3}')

if [[ -z "$remote_info" ]]; then
    echo -e "${GREEN}当前 Git 仓库没有配置远程仓库。${RESET}"
    exit 1
fi

echo -e "${GREEN}当前远程仓库信息：${RESET}"
echo -e "${GREEN}$remote_info${RESET}"
echo -e "${GREEN}==================================${RESET}"