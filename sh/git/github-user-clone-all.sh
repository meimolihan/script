# 替换为目标用户名
USERNAME="meimolihan"

# 创建目录并进入
mkdir -p "$USERNAME" && cd "$USERNAME"

# 获取所有仓库信息并克隆（排除ChinaTextbook项目）
curl -s "https://api.github.com/users/$USERNAME/repos?per_page=100" |
  grep -o 'git@[^"]*' |
  grep -v 'ChinaTextbook\|meimolihan.github.io\|twikoo\|clash\|AutoBuildImmortalWrt \|DockerTarBuilder\|hexo' |  # 排除多个项目
  xargs -L1 git clone


