#!/usr/bin/env bash
#  linux_admin_onepage.sh  —— 同屏交互版
################################################################################
#  彩色横幅 + 居中欢迎语（无外部依赖）
################################################################################
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
banner() {
  local cyan='\033[36m' yellow='\033[33m' reset='\033[0m' bold='\033[1m'
  cat <<'BAN'
  _     _  ______   _____    _____   ______
 | |   | ||  ____| / ____|  / ____| |  ____|
 | |   | || |__   | |      | (___   | |__
 | |   | ||  __|  | |       \___ \  |  __|
 | |___| || |____ | |____   ____) | | |____
  \_____/ |______| \_____| |_____/  |______|
BAN
echo ""
  printf "${bold}${yellow}Linux 系统管理工具${reset}\n"
  printf "${cyan}一键运维 · 同屏交互 · 无需分页${reset}\n\n"
}

# 调用
banner
sleep 0.5
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

set -euo pipefail

###############################
# 0. 工具函数
###############################
RED=$(echo -e "\033[31m"); GREEN=$(echo -e "\033[32m"); YELLOW=$(echo -e "\033[33m")
BLUE=$(echo -e "\033[34m"); RESET=$(echo -e "\033[0m")

log_info()  { echo -e "${GREEN}[INFO]${RESET} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $*"; }
pause()     { read -rp "按 Enter 继续 … "; }

cmd_exist() { command -v "$1" >/dev/null 2>&1; }
detect_pkgmgr() {
  for m in dnf yum apt-get; do cmd_exist "$m" && echo "$m" && return 0; done
  return 1
}
PKGMGR=$(detect_pkgmgr) || { log_error "无法确认包管理器"; exit 1; }

install_tools() {
  local tools=(curl tar zstd unzip net-tools lsof nmap)
  local miss=()
  for t in "${tools[@]}"; do cmd_exist "$t" || miss+=("$t"); done
  if ((${#miss[@]})); then
    log_info "即将安装：${miss[*]}"
    sudo "$PKGMGR" install -y "${miss[@]}"
  fi
}
install_tools

confirm() {
  read -rp "$1 (y/N) " ans
  [[ $ans =~ ^[Yy]$ ]] || { log_warn "操作已取消"; return 1; }
  return 0
}

###############################
# 1. 主菜单
###############################
main_menu() {
  while :; do
    cat <<EOF
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
          Linux 系统管理工具
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
 1) 进程管理          2) 磁盘管理
 3) 网络管理          4) 日志分析
 5) 用户管理          6) 安全管理
 7) 系统信息          8) 计划任务
 0) 退出
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}
EOF
    read -rp "请选择操作 [0-8]：" CHOICE
    case $CHOICE in
      1) process_menu ;;
      2) disk_menu ;;
      3) network_menu ;;
      4) log_menu ;;
      5) user_menu ;;
      6) security_menu ;;
      7) sysinfo ;;
      8) cron_menu ;;
      0) log_info "谢谢使用，再见！"; exit 0 ;;
      *) log_error "错误的选择" ;;
    esac
  done
}

###############################
# 2. 进程管理
###############################
process_menu() {
  while :; do
    cat <<EOF
------ 进程管理 ------
 1) 列出所有进程
 2) 杀死指定进程
 3) 按端口杀进程
 0) 返回
EOF
    read -rp "请选择：" c
    case $c in
      1) ps aux ;;
      2) read -rp "PID：" pid; confirm "确定杀 $pid ？" && kill "$pid" ;;
      3) read -rp "端口号：" port; confirm "确定杀端口 $port ？" && sudo fuser -k "$port"/tcp ;;
      0) break ;;
      *) echo "无效选择" ;;
    esac
  done
}

###############################
# 3. 磁盘管理
###############################
disk_menu() {
  while :; do
    cat <<EOF
------ 磁盘管理 ------
 1) 查看磁盘使用情况
 2) 清理 30 天前旧文件
 0) 返回
EOF
    read -rp "请选择：" c
    case $c in
      1) df -h ;;
      2) read -rp "待清理目录：" dir
         [[ -d $dir ]] || { log_error "目录不存在"; continue; }
         confirm "确定删除 $dir 下 30 天前文件？" &&
         sudo find "$dir" -type f -mtime +30 -print0 | xargs -0 -r sudo rm -f
         log_info "清理完成"
         ;;
      0) break ;;
      *) echo "无效选择" ;;
    esac
  done
}

###############################
# 4. 网络管理
###############################
network_menu() {
  while :; do
    cat <<EOF
------ 网络管理 ------
 1) 查看网络连接
 2) 查询指定端口
 3) 扫描局域网存活
 0) 返回
EOF
    read -rp "请选择：" c
    case $c in
      1) sudo netstat -tulnp ;;
      2) read -rp "端口号：" port; sudo lsof -i:"$port" ;;
      3) read -rp "网段 (例 192.168.1.0/24)：" net; sudo nmap -sP "$net" ;;
      0) break ;;
      *) echo "无效选择" ;;
    esac
  done
}

###############################
# 5. 日志分析
###############################
log_menu() {
  while :; do
    cat <<EOF
------ 日志分析 ------
 1) 查看系统日志（尾部 50 行）
 2) 关键字搜索（尾部 50 行）
 3) 保存日志到文件
 0) 返回
EOF
    read -rp "请选择：" c
    case $c in
      1) tail -n 50 /var/log/syslog ;;
      2) read -rp "关键字：" key; tail -n 50 /var/log/syslog | grep --color=auto -i "$key" ;;
      3) read -rp "保存路径：" f; sudo cp /var/log/syslog "$f" && log_info "已保存到 $f" ;;
      0) break ;;
      *) echo "无效选择" ;;
    esac
  done
}

###############################
# 6. 用户管理
###############################
user_menu() {
  while :; do
    cat <<EOF
------ 用户管理 ------
 1) 查看用户列表
 2) 添加用户
 3) 删除用户
 4) 修改密码
 0) 返回
EOF
    read -rp "请选择：" c
    case $c in
      1) cat /etc/passwd ;;
      2) read -rp "新用户名：" u; sudo adduser "$u" ;;
      3) read -rp "待删除用户名：" u; confirm "确定删 $u 及其家目录？" && sudo userdel -r "$u" ;;
      4) read -rp "用户名：" u; sudo passwd "$u" ;;
      0) break ;;
      *) echo "无效选择" ;;
    esac
  done
}

###############################
# 7. 安全管理
###############################
security_menu() {
  while :; do
    cat <<EOF
------ 安全管理 ------
 1) 修改 SSH 端口
 2) 禁止 root 远程登录
 0) 返回
EOF
    read -rp "请选择：" c
    case $c in
      1) read -rp "新端口：" p
         sudo sed -Ei "s/^#?Port.*/Port $p/" /etc/ssh/sshd_config
         sudo systemctl restart sshd && log_info "SSH 端口已改为 $p"
         ;;
      2) sudo sed -Ei 's/^#?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
         sudo systemctl restart sshd && log_info "已禁止 root 远程登录"
         ;;
      0) break ;;
      *) echo "无效选择" ;;
    esac
  done
}

###############################
# 8. 系统信息
###############################
sysinfo() {
  cat <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 操作系统：$(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/redhat-release)
 内核版本：$(uname -r)
 CPU 信息：$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2-)
 内存容量：$(free -h | awk '/^Mem:/ {print $2}')
 磁盘容量：$(df -h | awk '$NF=="/"{print "总量:" $2 " 剩余:" $4}')
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

###############################
# 9. 计划任务
###############################
cron_menu() {
  while :; do
    cat <<EOF
------ 计划任务 ------
 1) 查看当前计划任务
 2) 添加任务
 3) 修改任务（直接编辑）
 4) 删除任务
 0) 返回
EOF
    read -rp "请选择：" c
    case $c in
      1) crontab -l ;;
      2) add_cron ;;
      3) crontab -e ;;
      4) del_cron ;;
      0) break ;;
      *) echo "无效选择" ;;
    esac
  done
}

add_cron() {
  read -rp "时间格式（例 0 2 * * *）：" t
  read -rp "完整命令：" cmd
  entry="$t $cmd"
  echo "将添加：$entry"
  confirm "确认？" || return
  (crontab -l 2>/dev/null; echo "$entry") | crontab -
  log_info "已添加"
}

del_cron() {
  tmp=$(mktemp)
  crontab -l > "$tmp"
  grep -n '^' "$tmp"
  read -rp "输入要删除的行号：" line
  sed -i "${line}d" "$tmp"
  crontab "$tmp" && log_info "已删除"
  rm -f "$tmp"
}

###############################
# 10. 主循环
###############################
main_menu