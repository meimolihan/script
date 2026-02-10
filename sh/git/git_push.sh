#!/bin/sh

# 定义颜色变量
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

echo -e ""
echo -e "${gl_zi}>>> 推送 Git 仓库更新${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
# 检查当前目录是否为 Git 仓库
if [[ ! -d .git ]]; then
    echo -e "${gl_huang}当前目录不是 Git 仓库，请进入正确的 Git 仓库目录后重试。${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    exit 1
fi

# 脚本名称: deploy.sh
# 用途: 自动化部署 random-pic-api 到远程仓库
# 使用方法: 在目标目录下运行脚本

# 获取当前目录的绝对路径
TARGET_DIR=$(pwd)

# 检查目标目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
  echo -e "${gl_hong}错误: 目标目录 $TARGET_DIR 不存在，请确认路径是否正确。${gl_bai}"
  echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
  exit 1
fi

# 进入目标目录
cd "$TARGET_DIR"

# 检查是否是 Git 仓库
if ! git status > /dev/null 2>&1; then
  echo -e "${gl_hong}错误: 当前目录不是一个 Git 仓库，请确认是否初始化了 Git。${gl_bai}"
  echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
  exit 1
fi

# 检查 Git 配置是否完整
if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
  echo "错误: Git 用户名或邮箱未配置，请先配置 Git 用户名和邮箱。"
  echo "例如: git config --global user.name \"Your Name\""
  echo "      git config --global user.email \"your.email@example.com\""
  echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
  exit 1
fi

# 添加所有更改到暂存区
echo -e "${gl_bai}正在添加所有更改到暂存区${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
git add .

if [[ -z $(git status --porcelain) ]]; then
  echo -e "${gl_lv}无变更，无需提交${gl_bai}"
  echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
  exit 0
fi

# 提交更改
echo -e "${gl_bai}正在提交更改${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
git commit -m "update"

# 检查提交是否成功
if [ $? -ne 0 ]; then
  echo -e "${gl_hong}错误: 提交失败，请检查 Git 状态。${gl_bai}"
  echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
  exit 1
fi

# 推送到远程仓库
echo -e "正在推送到远程仓库${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
git push

# 检查推送是否成功
if [ $? -ne 0 ]; then
  echo -e "${gl_hong}错误: 推送失败，请检查网络连接或远程仓库配置。${gl_bai}"
  echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
  exit 1
fi

echo -e "${gl_lv}部署成功！${gl_bai}"
echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
