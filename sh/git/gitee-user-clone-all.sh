# 替换为目标 Gitee 用户名
USERNAME="meimolihan"

# 创建目录并进入
mkdir -p "$USERNAME" && cd "$USERNAME"

# 获取所有仓库信息并克隆（排除指定项目）
curl -s "https://gitee.com/api/v5/users/$USERNAME/repos?per_page=100&page=1" |
  grep -o 'git@gitee.com:[^"]*' |  # 匹配 Gitee 的 SSH 仓库地址
  # grep -v 'ChinaTextbook\|meimolihan.gitee.io\|twikoo\|clash\|AutoBuildImmortalWrt\|DockerTarBuilder\|hexo' | # 忽略的仓库
  xargs -L1 git clone


