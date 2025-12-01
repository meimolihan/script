#!/bin/bash
#============================== 颜色变量 ==============================
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_bai='\033[0m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
#====================================================================

repo_dir=$(basename "$(pwd)")

echo -e "${gl_zi}>>> Gitea 新仓库初始化脚本${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "当前工作目录: ${gl_huang}$(pwd)${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_huang}注意事项："
echo -e "${gl_bufan}1. ${gl_bai}请确保已在 Gitea 创建名为 ${gl_huang}$repo_dir${gl_bai} 的空仓库"
echo -e "${gl_bufan}2. ${gl_bai}脚本已配置 Gitea 访问权限"
echo -e "${gl_bufan}3. ${gl_bai}前往 Gitea 创建：${gl_lv}https://gitea.mobufan.eu.org:666/mobufan${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"

# 检查 git 命令
if ! command -v git &>/dev/null; then
    echo -e "${gl_hong}错误：未找到 git 命令，请先安装 Git${gl_bai}"
    exit 1
fi

# 输入验证函数
validate_repo_name() {
    local name="$1"
    [[ -z "$name" ]] && {
        echo -e "${gl_hong}错误：仓库名称不能为空${gl_bai}"
        return 1
    }
    [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]] && {
        echo -e "${gl_hong}错误：仓库名称包含非法字符（只允许字母、数字、- 和 _）${gl_bai}"
        return 1
    }
    return 0
}

# 一键确认/退出
while true; do
    read -e -p "$(echo -e "确认创建仓库 '${gl_huang}$repo_dir${gl_bai}' ? （${gl_lv}y${gl_bai}/${gl_hong}n${gl_bai}）：")" yn
    yn=${yn,,}
    case "$yn" in
        y|yes) repo_name="$repo_dir"; break ;;
        n|no|q|quit|0)
            echo -e "${gl_huang}已取消，脚本退出。${gl_bai}"
            sleep 2
            exit 0
            ;;
        *) echo -e "${gl_hong}请输入 y 或 n${gl_bai}" ;;
    esac
done

# 检查是否已存在 Git 仓库
if [[ -d ".git" ]]; then
    echo -e "${gl_huang}警告：当前目录已存在 Git 仓库${gl_bai}"
    read -p "是否继续操作？(y/n) [n]: " continue_choice
    if [[ "${continue_choice,,}" != "y" ]]; then
        echo -e "${gl_huang}已中止操作${gl_bai}"
        exit 0
    fi
fi

# 初始化仓库
git init || {
    echo -e "${gl_hong}错误：Git 仓库初始化失败${gl_bai}"
    exit 1
}
echo -e "${gl_lv}✓ 已初始化 Git 仓库${gl_bai}"

# 配置安全目录
current_dir=$(pwd)
git config --global --add safe.directory "$current_dir"

# 创建/覆盖 README.md
readme_file="README.md"
if [[ -f "$readme_file" ]]; then
    echo -e "${gl_huang}检测到已存在的 README.md 文件${gl_bai}"
    read -p "是否覆盖？(y/n) [n]: " overwrite
    if [[ "${overwrite,,}" == "y" ]]; then
        echo "## $repo_name 项目说明" > "$readme_file"
        echo -e "${gl_lv}✓ 已创建 README.md${gl_bai}"
    else
        echo -e "${gl_huang}保留原有 README.md 文件${gl_bai}"
    fi
else
    echo "## $repo_name 项目说明" > "$readme_file"
    echo -e "${gl_lv}✓ 已创建 README.md${gl_bai}"
fi

# 添加与提交
git add . || {
    echo -e "${gl_hong}错误：文件添加到暂存区失败${gl_bai}"
    exit 1
}
echo -e "${gl_lv}✓ 文件已暂存${gl_bai}"

git commit -m "feat: 初始提交" || {
    echo -e "${gl_hong}错误：提交更改失败${gl_bai}"
    exit 1
}
echo -e "${gl_lv}✓ 已提交初始版本${gl_bai}"

# 统一默认分支为 main
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "main" ]]; then
    git branch -M main || {
        echo -e "${gl_hong}错误：无法将分支重命名为 main${gl_bai}"
        exit 1
    }
    echo -e "${gl_lv}✓ 已将分支重命名为 main${gl_bai}"
fi

# 固定 Gitea 配置
gitea_username="mobufan"
gitea_server="gitea.mobufan.eu.org:666"
gitea_password="yifan0719"

# 设置远程仓库
remote_url="https://${gitea_username}@${gitea_server}/${gitea_username}/${repo_name}.git"
current_remote=$(git remote get-url origin 2>/dev/null)

if [[ -n "$current_remote" ]]; then
    echo -e "${gl_huang}检测到已存在的远程仓库：${current_remote}${gl_bai}"
    read -p "是否要替换现有远程仓库？(y/n) [n]: " replace_remote
    if [[ "${replace_remote,,}" == "y" ]]; then
        git remote remove origin
        echo -e "${gl_lv}✓ 已移除原有远程仓库${gl_bai}"
    else
        echo -e "${gl_huang}保留原有远程仓库配置${gl_bai}"
    fi
fi

git remote add origin "$remote_url" || {
    echo -e "${gl_hong}错误：添加远程仓库失败${gl_bai}"
    exit 1
}
echo -e "${gl_lv}✓ 已配置远程仓库地址：${remote_url}${gl_bai}"

# 临时密码脚本
pass_script=$(mktemp)
echo '#!/bin/sh' > "$pass_script"
echo "echo '$gitea_password'" >> "$pass_script"
chmod +x "$pass_script"
export GIT_ASKPASS="$pass_script"

# 推送代码
echo -e "${gl_bufan}正在推送代码到 Gitea...${gl_bai}"
git push -u origin main || {
    echo -e "${gl_hong}错误：代码推送失败，请检查："
    echo -e "1. 远程仓库是否存在"
    echo -e "2. Gitea 访问权限是否配置正确"
    echo -e "3. 网络连接是否正常${gl_bai}"
    rm -f "$pass_script"
    exit 1
}

# 清理临时脚本
rm -f "$pass_script"

echo -e "${gl_lv}==================================${gl_bai}"
echo -e "${gl_lv}仓库初始化并推送成功！${gl_bai}"
echo -e "${gl_lv}仓库地址：https://${gitea_server}/${gitea_username}/${repo_name}${gl_bai}"
echo -e "${gl_lv}==================================${gl_bai}"

remote_info=$(git remote -v)
if [[ -z "$remote_info" ]]; then
    echo -e "${gl_lv}当前 Git 仓库没有配置远程仓库。${gl_bai}"
else
    echo -e "${gl_lv}当前远程仓库信息：${gl_bai}"
    echo -e "${gl_lv}$remote_info${gl_bai}"
fi
echo -e "${gl_lv}==================================${gl_bai}"