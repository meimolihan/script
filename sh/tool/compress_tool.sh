#!/usr/bin/env bash
# 文件名: compress_tool.sh
set -euo pipefail

########## 颜色定义 ##########
RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'; BLUE='\033[34m'
PURPLE='\033[35m'; CYAN='\033[36m'; RESET='\033[0m'

line() {
  printf "${CYAN}==============================================\n${RESET}"
}

########## 系统检测和软件安装 ##########
detect_system() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "$ID"
  elif command -v lsb_release &> /dev/null; then
    lsb_release -si | tr '[:upper:]' '[:lower:]'
  else
    echo "unknown"
  fi
}

install_software() {
  local system="$1"
  local packages=()
  
  # 检测缺失的命令
  if ! command -v zip &> /dev/null || ! command -v unzip &> /dev/null; then
    packages+=("zip" "unzip")
  fi
  
  if ! command -v 7z &> /dev/null; then
    packages+=("p7zip-full")
  fi
  
  if ! command -v rar &> /dev/null && ! command -v unrar &> /dev/null; then
    packages+=("unrar")
  fi
  
  if ! command -v xz &> /dev/null; then
    packages+=("xz-utils")
  fi
  
  if ! command -v bzip2 &> /dev/null; then
    packages+=("bzip2")
  fi
  
  if ! command -v gzip &> /dev/null; then
    packages+=("gzip")
  fi
  
  if [[ ${#packages[@]} -eq 0 ]]; then
    echo -e "${GREEN}所有必要软件已安装！${RESET}"
    return 0
  fi
  
  echo -e "${YELLOW}需要安装以下软件：${RESET}"
  printf "  ${GREEN}•${RESET} %s\n" "${packages[@]}"
  
  case "$system" in
    ubuntu|debian|linuxmint|kali)
      echo -e "${YELLOW}使用 apt 安装...${RESET}"
      apt update && apt install -y "${packages[@]}"
      ;;
    centos|rhel|fedora|rocky|almalinux)
      echo -e "${YELLOW}使用 yum/dnf 安装...${RESET}"
      if command -v dnf &> /dev/null; then
        dnf install -y "${packages[@]}"
      else
        yum install -y "${packages[@]}"
      fi
      ;;
    arch|manjaro)
      echo -e "${YELLOW}使用 pacman 安装...${RESET}"
      pacman -Sy --noconfirm "${packages[@]}"
      ;;
    opensuse*)
      echo -e "${YELLOW}使用 zypper 安装...${RESET}"
      zypper install -y "${packages[@]}"
      ;;
    *)
      echo -e "${RED}无法自动安装软件，请手动安装：${RESET}"
      printf "  ${YELLOW}•${RESET} %s\n" "${packages[@]}"
      return 1
      ;;
  esac
  
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}软件安装成功！${RESET}"
    return 0
  else
    echo -e "${RED}软件安装失败，请手动安装！${RESET}"
    return 1
  fi
}

########## 主菜单 ##########
main_menu() {
  while true; do
    line
    printf "${BLUE}%-30s${RESET}\n" "Linux 压缩/解压小工具"
    line
    echo -e "  ${GREEN}1)${RESET} 压缩文件/目录"
    echo -e "  ${GREEN}2)${RESET} 解压文件"
    echo -e "  ${GREEN}0)${RESET} 退出"
    line
    read -rp "请选择操作 [0-2]: " choice
    case $choice in
      1) compress_submenu ;;
      2) decompress_submenu ;;
      0) echo -e "${YELLOW}感谢使用，再见！${RESET}"; exit 0 ;;
      *) echo -e "${RED}无效选择，请重试！${RESET}" ;;
    esac
  done
}

########## 压缩子菜单 ##########
compress_submenu() {
  line; echo -e "${PURPLE}>>> 压缩模式${RESET}"

  # 扫描当前目录下的文件/目录（排除压缩包）
  mapfile -t list < <(
    find . -maxdepth 1 -type f \( ! -name '*.zip' ! -name '*.7z' ! -name '*.tar*' ! -name '*.rar' ! -name '*.gz' ! -name '*.bz2' ! -name '*.xz' \) -printf '%P\n' | sort
    find . -maxdepth 1 -type d ! -name '.' ! -name '.*' -printf '%P\n' | sort
  )
  if ((${#list[@]}==0)); then
    echo -e "${YELLOW}(当前目录无可压缩的文件/目录)${RESET}"
    list=()
  else
    echo -e "${CYAN}当前目录下的文件/目录：${RESET}"
    for i in "${!list[@]}"; do
      printf "  ${GREEN}%2d)${RESET} %s\n" $((i+1)) "${list[i]}"
    done
  fi
  line

  read -rp "请输入序号选择，或手动输入文件名/目录名（留空取消）: " choice
  [[ -z $choice ]] && { echo -e "${YELLOW}已取消${RESET}"; return; }

  # 判断是序号还是手动输入
  if [[ $choice =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#list[@]} )); then
    target="${list[$((choice-1))]}"
  else
    target="$choice"
  fi

  [[ -e $target ]] || { echo -e "${RED}错误：'$target' 不存在！${RESET}"; return; }

  echo -e "${YELLOW}请选择压缩格式：${RESET}"
  echo -e "  1) zip\n  2) 7z\n  3) tar.gz\n  4) tar.xz\n  5) tar.bz2\n  6) tar"
  read -rp "输入序号 [1-6]: " fmt_idx
  
  # 检查对应命令是否存在
  case $fmt_idx in
    1) 
      ext="zip"; cmd=("zip" "-r" "-q")
      if ! command -v zip &> /dev/null; then
        echo -e "${RED}错误：zip 命令未安装！${RESET}"
        return
      fi
      ;;
    2) 
      ext="7z"; cmd=("7z" "a")
      if ! command -v 7z &> /dev/null; then
        echo -e "${RED}错误：7z 命令未安装！${RESET}"
        return
      fi
      ;;
    3) 
      ext="tar.gz"; cmd=("tar" "-zcf")
      if ! command -v tar &> /dev/null; then
        echo -e "${RED}错误：tar 命令未安装！${RESET}"
        return
      fi
      ;;
    4) 
      ext="tar.xz"; cmd=("tar" "-Jcf")
      if ! command -v tar &> /dev/null || ! command -v xz &> /dev/null; then
        echo -e "${RED}错误：tar 或 xz 命令未安装！${RESET}"
        return
      fi
      ;;
    5) 
      ext="tar.bz2"; cmd=("tar" "-jcf")
      if ! command -v tar &> /dev/null || ! command -v bzip2 &> /dev/null; then
        echo -e "${RED}错误：tar 或 bzip2 命令未安装！${RESET}"
        return
      fi
      ;;
    6) 
      ext="tar"; cmd=("tar" "-cf")
      if ! command -v tar &> /dev/null; then
        echo -e "${RED}错误：tar 命令未安装！${RESET}"
        return
      fi
      ;;
    *) echo -e "${RED}无效序号！${RESET}"; return ;;
  esac

  output="${target%%/}.${ext}"
  echo -e "${GREEN}正在压缩 → ${output}${RESET}"
  
  case $fmt_idx in
    1|2) 
      "${cmd[@]}" "$output" "$target" 
      ;;
    3|4|5|6) 
      "${cmd[@]}" "$output" -C "$(dirname "$target")" "$(basename "$target")" 
      ;;
  esac 
  
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}压缩完成！${RESET}"
  else
    echo -e "${RED}压缩失败！${RESET}"
  fi
}

########## 检查重复文件函数 ##########
check_duplicate_files() {
  local archive="$1"
  local dest="$2"
  local duplicates=()
  
  # 根据压缩格式检查重复文件
  case "$archive" in
    *.zip)
      if command -v unzip &> /dev/null; then
        mapfile -t files < <(unzip -Z1 "$archive" 2>/dev/null || true)
        for file in "${files[@]}"; do
          [[ -n "$file" && "$file" != */ ]] && [[ -f "$dest/$file" ]] && duplicates+=("$file")
        done
      fi
      ;;
    *.7z)
      if command -v 7z &> /dev/null; then
        mapfile -t files < <(7z l "$archive" 2>/dev/null | awk '/^[0-9]{4}-[0-9]{2}-[0-9]{2}/ {if(NF>=6) print $NF}' | grep -v '/$' || true)
        for file in "${files[@]}"; do
          [[ -n "$file" && "$file" != */ ]] && [[ -f "$dest/$file" ]] && duplicates+=("$file")
        done
      fi
      ;;
    *.tar|*.tar.gz|*.tar.bz2|*.tar.xz|*.tgz|*.tbz2|*.txz)
      if command -v tar &> /dev/null; then
        mapfile -t files < <(tar -tf "$archive" 2>/dev/null || true)
        for file in "${files[@]}"; do
          [[ -n "$file" && "$file" != */ ]] && [[ -f "$dest/$file" ]] && duplicates+=("$file")
        done
      fi
      ;;
    *.rar)
      if command -v unrar &> /dev/null; then
        mapfile -t files < <(unrar vb "$archive" 2>/dev/null || true)
        for file in "${files[@]}"; do
          [[ -n "$file" && "$file" != */ ]] && [[ -f "$dest/$file" ]] && duplicates+=("$file")
        done
      fi
      ;;
    # 对于其他格式，跳过重复检查
    *) return ;;
  esac
  
  printf '%s\n' "${duplicates[@]}"
}

########## 解压子菜单（支持更多格式） ##########
decompress_submenu() {
  line; echo -e "${PURPLE}>>> 解压模式${RESET}"
  
  # 支持更多压缩格式
  mapfile -t list < <(
    ls -1 *.zip *.7z *.tar *.tar.gz *.tar.bz2 *.tar.xz *.tgz *.tbz2 *.txz *.rar *.gz *.bz2 *.xz 2>/dev/null | sort -u
  )
  
  if ((${#list[@]}==0)); then
    echo -e "${YELLOW}(当前目录无压缩包)${RESET}"; list=()
  else
    echo -e "${CYAN}当前目录下的压缩包：${RESET}"
    for i in "${!list[@]}"; do
      printf "  ${GREEN}%2d)${RESET} %s\n" $((i+1)) "${list[i]}"
    done
  fi
  line
  
  read -rp "请输入序号选择，或手动输入文件名（留空取消）: " choice
  [[ -z $choice ]] && { echo -e "${YELLOW}已取消${RESET}"; return; }
  
  if [[ $choice =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#list[@]} )); then
    archive="${list[$((choice-1))]}"
  else
    archive="$choice"
  fi
  
  [[ -f $archive ]] || { echo -e "${RED}错误：'$archive' 不存在！${RESET}"; return; }
  
  # 根据文件扩展名设置解压命令
  local cmd=()
  case "$archive" in
    *.zip)  
      cmd=("unzip" "-q")
      if ! command -v unzip &> /dev/null; then
        echo -e "${RED}错误：unzip 命令未安装！${RESET}"
        return
      fi
      ;;
    *.7z)   
      cmd=("7z" "x")
      if ! command -v 7z &> /dev/null; then
        echo -e "${RED}错误：7z 命令未安装！${RESET}"
        return
      fi
      ;;
    *.tar) 
      cmd=("tar" "-xf")
      if ! command -v tar &> /dev/null; then
        echo -e "${RED}错误：tar 命令未安装！${RESET}"
        return
      fi
      ;;
    *.tar.gz|*.tgz) 
      cmd=("tar" "-zxf")
      if ! command -v tar &> /dev/null; then
        echo -e "${RED}错误：tar 命令未安装！${RESET}"
        return
      fi
      ;;
    *.tar.bz2|*.tbz2) 
      cmd=("tar" "-jxf")
      if ! command -v tar &> /dev/null; then
        echo -e "${RED}错误：tar 命令未安装！${RESET}"
        return
      fi
      ;;
    *.tar.xz|*.txz) 
      cmd=("tar" "-Jxf")
      if ! command -v tar &> /dev/null; then
        echo -e "${RED}错误：tar 命令未安装！${RESET}"
        return
      fi
      ;;
    *.rar)
      if command -v unrar &> /dev/null; then
        cmd=("unrar" "x" "-inul")
      elif command -v rar &> /dev/null; then
        cmd=("rar" "x" "-inul")
      else
        echo -e "${RED}错误：unrar 或 rar 命令未安装！${RESET}"
        return
      fi
      ;;
    *.gz)
      if ! command -v gzip &> /dev/null; then
        echo -e "${RED}错误：gzip 命令未安装！${RESET}"
        return
      fi
      # 对于单独的.gz文件，需要特殊处理
      read -rp "解压.gz文件将覆盖原文件，是否继续？[y/N]: " confirm
      [[ $confirm =~ ^[Yy]$ ]] || { echo -e "${YELLOW}已取消${RESET}"; return; }
      cmd=("gzip" "-d")
      ;;
    *.bz2)
      if ! command -v bzip2 &> /dev/null; then
        echo -e "${RED}错误：bzip2 命令未安装！${RESET}"
        return
      fi
      read -rp "解压.bz2文件将覆盖原文件，是否继续？[y/N]: " confirm
      [[ $confirm =~ ^[Yy]$ ]] || { echo -e "${YELLOW}已取消${RESET}"; return; }
      cmd=("bzip2" "-d")
      ;;
    *.xz)
      if ! command -v xz &> /dev/null; then
        echo -e "${RED}错误：xz 命令未安装！${RESET}"
        return
      fi
      read -rp "解压.xz文件将覆盖原文件，是否继续？[y/N]: " confirm
      [[ $confirm =~ ^[Yy]$ ]] || { echo -e "${YELLOW}已取消${RESET}"; return; }
      cmd=("xz" "-d")
      ;;
    *) 
      echo -e "${RED}不支持的压缩格式：$archive${RESET}"
      return 
      ;;
  esac
  
  read -rp "请输入解压目标目录（留空则当前目录）: " dest
  dest=${dest:-.}
  [[ -d $dest ]] || { echo -e "${YELLOW}目录不存在，将自动创建：${dest}${RESET}"; mkdir -p "$dest"; }
  
  # 检查重复文件（仅对支持格式）
  echo -e "${YELLOW}检查重复文件中...${RESET}"
  mapfile -t duplicates < <(check_duplicate_files "$archive" "$dest")
  
  if ((${#duplicates[@]} > 0)); then
    echo -e "${RED}发现以下重复文件：${RESET}"
    for file in "${duplicates[@]}"; do
      echo -e "  ${RED}•${RESET} $file"
    done
    
    while true; do
      echo -e "${YELLOW}请选择操作：${RESET}"
      echo -e "  ${GREEN}1)${RESET} 覆盖所有重复文件"
      echo -e "  ${GREEN}2)${RESET} 跳过所有重复文件"
      echo -e "  ${GREEN}3)${RESET} 逐个询问是否覆盖"
      echo -e "  ${GREEN}4)${RESET} 取消解压"
      read -rp "请选择 [1-4]: " overwrite_choice
      
      case $overwrite_choice in
        1)
          # 覆盖所有
          case "$archive" in
            *.zip) cmd=("unzip" "-o" "-q") ;;
            *.7z) cmd=("7z" "x" "-y") ;;
            *.rar) 
              if [[ "${cmd[0]}" == "unrar" ]]; then
                cmd=("unrar" "x" "-o+" "-inul")
              else
                cmd=("rar" "x" "-o+" "-inul")
              fi
              ;;
            *.tar|*.tar.gz|*.tar.bz2|*.tar.xz|*.tgz|*.tbz2|*.txz) 
              # tar 默认覆盖
              ;;
            *.gz|*.bz2|*.xz)
              # 单文件压缩格式直接覆盖
              ;;
          esac
          break
          ;;
        2)
          # 跳过所有
          case "$archive" in
            *.zip) cmd=("unzip" "-n" "-q") ;;
            *.7z|*.tar|*.tar.gz|*.tar.bz2|*.tar.xz|*.tgz|*.tbz2|*.txz|*.gz|*.bz2|*.xz) 
              echo -e "${YELLOW}注意：此格式不支持跳过重复文件，将取消解压${RESET}"
              return
              ;;
            *.rar)
              if [[ "${cmd[0]}" == "unrar" ]]; then
                cmd=("unrar" "x" "-o-" "-inul")
              else
                cmd=("rar" "x" "-o-" "-inul")
              fi
              ;;
          esac
          break
          ;;
        3)
          # 逐个询问
          for file in "${duplicates[@]}"; do
            while true; do
              read -rp "是否覆盖文件 '$file'? [y/N]: " answer
              case $answer in
                [Yy]*)
                  # 对于不支持跳过单个文件的格式，需要手动删除
                  if [[ "$archive" == *.tar.gz || "$archive" == *.tar.xz || "$archive" == *.tar.bz2 || "$archive" == *.tar || "$archive" == *.7z ]]; then
                    rm -f "$dest/$file"
                  fi
                  break
                  ;;
                [Nn]*|"")
                  # 对于 zip，设置跳过此文件
                  if [[ "$archive" == *.zip ]]; then
                    exclude_file=$(mktemp)
                    echo "$file" > "$exclude_file"
                    cmd=("unzip" "-q" "-x" "@$exclude_file")
                  elif [[ "$archive" == *.rar ]]; then
                    echo -e "${YELLOW}注意：rar 格式不支持排除单个文件，将跳过所有重复文件${RESET}"
                    if [[ "${cmd[0]}" == "unrar" ]]; then
                      cmd=("unrar" "x" "-o-" "-inul")
                    else
                      cmd=("rar" "x" "-o-" "-inul")
                    fi
                    break 2
                  else
                    echo -e "${YELLOW}注意：此格式不支持排除单个文件，将取消解压${RESET}"
                    return
                  fi
                  break
                  ;;
                *) echo -e "${RED}请输入 y 或 n${RESET}" ;;
              esac
            done
          done
          break
          ;;
        4)
          echo -e "${YELLOW}已取消解压${RESET}"
          return
          ;;
        *)
          echo -e "${RED}无效选择，请重试${RESET}"
          ;;
      esac
    done
  fi
  
  echo -e "${GREEN}正在解压 → ${dest}${RESET}"
  
  # 执行解压命令
  local result=0
  case "$archive" in
    *.zip)
      if [[ "${cmd[1]}" == "-x" ]]; then
        "${cmd[@]}" "$archive" -d "$dest"
        rm -f "$exclude_file" 2>/dev/null || true
      else
        "${cmd[@]}" "$archive" -d "$dest"
      fi
      result=$?
      ;;
    *.7z)
      "${cmd[@]}" "$archive" -o"$dest"
      result=$?
      ;;
    *.tar|*.tar.gz|*.tar.bz2|*.tar.xz|*.tgz|*.tbz2|*.txz)
      "${cmd[@]}" "$archive" -C "$dest"
      result=$?
      ;;
    *.rar)
      "${cmd[@]}" "$archive" "$dest"/ 2>/dev/null || "${cmd[@]}" "$archive" "$dest"
      result=$?
      ;;
    *.gz|*.bz2|*.xz)
      # 单文件压缩格式，直接解压到当前目录
      "${cmd[@]}" "$archive"
      result=$?
      ;;
  esac
  
  if [[ $result -eq 0 ]]; then
    echo -e "${GREEN}解压完成！${RESET}"
  else
    echo -e "${RED}解压失败！${RESET}"
  fi
}

########## 入口 ##########
# 检测系统并安装必要软件
echo -e "${BLUE}检测系统环境...${RESET}"
system_type=$(detect_system)
echo -e "${GREEN}检测到系统类型：$system_type${RESET}"

# 尝试安装必要软件
if [[ $EUID -eq 0 ]]; then
  install_software "$system_type"
else
  echo -e "${YELLOW}提示：非root用户，跳过自动安装软件${RESET}"
  echo -e "${YELLOW}如果遇到命令未找到错误，请以root权限运行此脚本${RESET}"
fi

# 进入主菜单
main_menu
