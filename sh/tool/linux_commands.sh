#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Docker 管理专用颜色变量（与全局保持一致）
gl_hong=$RED      # 红色用于警告
gl_huang=$YELLOW  # 黄色用于提示
gl_lv=$GREEN      # 绿色用于成功
gl_bai=$NC        # 白色/默认色

# 全局变量
gh_proxy="https://"

# 安装依赖函数
install_dependencies() {
    echo -e "${GREEN}正在检查并安装系统依赖...${NC}"
    
    # 检测系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${RED}无法检测操作系统类型${NC}"
        return 1
    fi
    
    # 检查并安装依赖
    local dependencies=(curl wget sudo git)
    local to_install=()
    
    # 检查哪些依赖未安装
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            to_install+=("$dep")
        fi
    done
    
    # 如果没有需要安装的依赖，直接返回
    if [ ${#to_install[@]} -eq 0 ]; then
        echo -e "${GREEN}所有依赖已安装${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}需要安装的依赖: ${to_install[*]}${NC}"
    
    # 根据系统类型安装依赖
    case $OS in
        ubuntu|debian)
            echo -e "${GREEN}检测到 Debian/Ubuntu 系统，使用 apt 安装...${NC}"
            apt update
            apt install -y "${to_install[@]}"
            ;;
        centos|rhel|fedora)
            echo -e "${GREEN}检测到 CentOS/RHEL/Fedora 系统，使用 yum/dnf 安装...${NC}"
            if command -v dnf &> /dev/null; then
                dnf install -y "${to_install[@]}"
            else
                yum install -y "${to_install[@]}"
            fi
            ;;
        alpine)
            echo -e "${GREEN}检测到 Alpine 系统，使用 apk 安装...${NC}"
            apk update
            apk add "${to_install[@]}"
            ;;
        arch|manjaro)
            echo -e "${GREEN}检测到 Arch/Manjaro 系统，使用 pacman 安装...${NC}"
            pacman -Sy --noconfirm "${to_install[@]}"
            ;;
        *)
            echo -e "${RED}不支持的操作系统: $OS${NC}"
            echo -e "${YELLOW}请手动安装以下依赖: ${to_install[*]}${NC}"
            return 1
            ;;
    esac
    
    # 检查安装结果
    local failed_deps=()
    for dep in "${to_install[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            failed_deps+=("$dep")
        fi
    done
    
    if [ ${#failed_deps[@]} -eq 0 ]; then
        echo -e "${GREEN}所有依赖安装成功${NC}"
        return 0
    else
        echo -e "${RED}以下依赖安装失败: ${failed_deps[*]}${NC}"
        return 1
    fi
}

# 在脚本开始时安装依赖
install_dependencies

# 函数：安全读取输入（支持回退，不删除提示）
safe_read() {
    local prompt="$1"
    local variable="$2"
    local default_value="$3"
    
    while true; do
        # 使用 read -p 参数来避免换行问题
        if [ -n "$default_value" ]; then
            read -e -p "$(echo -e "${YELLOW}${prompt} [默认: ${default_value}]: ${NC}")" input_value
            # 如果用户只按回车且有默认值，使用默认值
            if [ -z "$input_value" ]; then
                input_value="$default_value"
            fi
        else
            read -e -p "$(echo -e "${YELLOW}${prompt}: ${NC}")" input_value
        fi
        
        # 检查输入是否为空
        if [ -z "$input_value" ]; then
            echo -e "\r${RED}错误: 输入不能为空，请重新输入${NC}"
            continue
        fi
        
        # 检查是否要退出
        if [ "$input_value" = "q" ] || [ "$input_value" = "quit" ] || [ "$input_value" = "exit" ]; then
            echo -e "${YELLOW}退出操作${NC}"
            return 1
        fi
        
        # 将值赋给变量
        eval "$variable=\"$input_value\""
        return 0
    done
}

# 函数：安全读取数字输入
safe_read_number() {
    local prompt="$1"
    local variable="$2"
    local min="$3"
    local max="$4"
    
    while true; do
        # 使用 read -p 参数来避免换行问题
        read -e -p "$(echo -e "${YELLOW}${prompt}: ${NC}")" input_value
        
        # 检查是否要退出
        if [ "$input_value" = "q" ] || [ "$input_value" = "quit" ] || [ "$input_value" = "exit" ]; then
            echo -e "${YELLOW}退出操作${NC}"
            return 1
        fi
        
        # 检查是否为数字
        if ! [[ "$input_value" =~ ^[0-9]+$ ]]; then
            echo -e "\r${RED}错误: 请输入有效的数字${NC}"
            continue
        fi
        
        # 检查范围
        if [ -n "$min" ] && [ "$input_value" -lt "$min" ]; then
            echo -e "\r${RED}错误: 数字不能小于 $min${NC}"
            continue
        fi
        
        if [ -n "$max" ] && [ "$input_value" -gt "$max" ]; then
            echo -e "\r${RED}错误: 数字不能大于 $max${NC}"
            continue
        fi
        
        # 将值赋给变量
        eval "$variable=\"$input_value\""
        return 0
    done
}

# 函数：安全读取确认
safe_read_confirm() {
    local prompt="$1"
    local variable="$2"
    
    while true; do
        # 使用 read -p 参数来避免换行问题
        read -e -p "$(echo -e "${YELLOW}${prompt} [y/N]: ${NC}")" input_value
        
        # 转换为小写
        input_value=$(echo "$input_value" | tr '[:upper:]' '[:lower:]')
        
        # 检查是否要退出
        if [ "$input_value" = "q" ] || [ "$input_value" = "quit" ] || [ "$input_value" = "exit" ]; then
            echo -e "${YELLOW}退出操作${NC}"
            return 1
        fi
        
        # 处理各种确认输入
        case "$input_value" in
            y|yes|Y|YES|是|确认)
                eval "$variable=\"y\""
                return 0
                ;;
            n|no|N|NO|否|取消|"")
                eval "$variable=\"n\""
                return 0
                ;;
            *)
                echo -e "\r${RED}错误: 请输入 y 或 n${NC}"
                ;;
        esac
    done
}

# 函数：获取内网IP地址
get_internal_ip() {
    local ip=""
    # 尝试多种方法获取内网IP
    if command -v hostname >/dev/null 2>&1; then
        ip=$(hostname -I | awk '{print $1}')
    elif command -v ip >/dev/null 2>&1; then
        ip=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)
    elif command -v ifconfig >/dev/null 2>&1; then
        ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
    fi
    echo "$ip"
}

# 函数：根据IP确定默认菜单
get_default_menu() {
    local ip=$(get_internal_ip)
    case "$ip" in
        "10.10.10.254") echo "pve" ;;
        "10.10.10.251") echo "fnos" ;;
        "10.10.10.246") echo "nginx" ;;
        *) echo "main" ;;
    esac
}

# 函数：显示主菜单
show_main_menu() {
    clear
    echo -e "${GREEN}"
    echo "========================================"
    echo "         Linux 常用命令工具"
    echo "========================================"
    echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
    echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
    echo "----------------------------------------"
    echo -e "${CYAN}1. PVE 系统命令${NC}"
    echo -e "${CYAN}2. FnOS 系统命令${NC}"
    echo -e "${CYAN}3. Nginx 命令合集${NC}"
    echo -e "${CYAN}------------------------${NC}"
    echo -e "${CYAN}4. Linux 通用命令${NC}"
    echo -e "${CYAN}5. Linux 文件命令${NC}"
    echo -e "${CYAN}6. Linux 压缩/解压${NC}"
    echo -e "${CYAN}7. Linux 常用脚本${NC}"
    echo -e "${CYAN}------------------------${NC}"
    echo -e "${CYAN}8. Docker 管理${NC}"
    echo -e "${CYAN}------------------------${NC}"
    echo -e "${RED}0. 退出脚本${NC}"
    echo "========================================"
}

# 函数：显示PVE子菜单
show_pve_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "            PVE 系统命令"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${CYAN}1. 查看所有虚拟机${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${YELLOW}[虚拟机命令]${NC}"
        echo -e "${CYAN}2. 启动虚拟机${NC}"
        echo -e "${CYAN}3. 关闭虚拟机${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${YELLOW}[LXC容器命令]${NC}"
        echo -e "${CYAN}4. 启动LXC容器${NC}"
        echo -e "${CYAN}5. 关闭LXC容器${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}8. PVE 更新并清理系统${NC}"
        echo -e "${CYAN}9. PVE 优化脚本${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" choice 0 9; then
            continue
        fi
        
        case $choice in
            1)
                echo -e "${YELLOW}执行命令: pvesh get /cluster/resources${NC}"
                echo "----------------------------------------"
                pvesh get /cluster/resources
                echo "----------------------------------------"
                ;;
            2)
                if safe_read "请输入要启动的虚拟机ID(多个用空格隔开，输入q退出)" vm_ids; then
                    if [ -n "$vm_ids" ]; then
                        for vm_id in $vm_ids; do
                            echo -e "${YELLOW}启动虚拟机: $vm_id${NC}"
                            qm start $vm_id
                        done
                    else
                        echo -e "${RED}错误: 未输入虚拟机ID${NC}"
                    fi
                fi
                ;;
            3)
                if safe_read "请输入要关闭的虚拟机ID(多个用空格隔开，输入q退出)" vm_ids; then
                    if [ -n "$vm_ids" ]; then
                        for vm_id in $vm_ids; do
                            echo -e "${YELLOW}关闭虚拟机: $vm_id${NC}"
                            qm stop $vm_id
                        done
                    else
                        echo -e "${RED}错误: 未输入虚拟机ID${NC}"
                    fi
                fi
                ;;
            4)
                if safe_read "请输入要启动的容器ID(多个用空格隔开，输入q退出)" ct_ids; then
                    if [ -n "$ct_ids" ]; then
                        for ct_id in $ct_ids; do
                            echo -e "${YELLOW}启动容器: $ct_id${NC}"
                            lxc-start -n $ct_id
                        done
                    else
                        echo -e "${RED}错误: 未输入容器ID${NC}"
                    fi
                fi
                ;;
            5)
                if safe_read "请输入要关闭的容器ID(多个用空格隔开，输入q退出)" ct_ids; then
                    if [ -n "$ct_ids" ]; then
                        for ct_id in $ct_ids; do
                            echo -e "${YELLOW}关闭容器: $ct_id${NC}"
                            lxc-stop -n $ct_id
                        done
                    else
                        echo -e "${RED}错误: 未输入容器ID${NC}"
                    fi
                fi
                ;;

            8)
                echo -e "${YELLOW}执行命令: sudo apt update && sudo apt -y dist-upgrade && sudo apt autoremove --purge && sudo apt clean${NC}"
                echo "----------------------------------------"
                sudo apt update && sudo apt -y dist-upgrade && sudo apt autoremove --purge && sudo apt clean
                echo "----------------------------------------"
                ;;

            9)
                echo -e "${YELLOW}执行命令: wget  -q  -O  /root/pve_source.tar.gz 'https://gitee.com/meimolihan/script/raw/master/sh/pve/pve_source.tar.gz' &&  tar  zxvf  /root/pve_source.tar.gz  &&  /root/./pve_source${NC}"
                echo "----------------------------------------"
                wget  -q  -O  /root/pve_source.tar.gz 'https://gitee.com/meimolihan/script/raw/master/sh/pve/pve_source.tar.gz' &&  tar  zxvf  /root/pve_source.tar.gz  &&  /root/./pve_source
                echo "----------------------------------------"
                ;;

            0)
                break
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：显示	FnOS 子菜单
show_fnos_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "            	FnOS 系统命令"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"

        echo -e "${CYAN}1. Compose 容器管理${NC}"
        echo -e "${CYAN}2. 当前目录 Compose 启动服务${NC}"
        echo -e "${CYAN}3. 当前目录 Compose 停止服务${NC}"
        echo -e "${CYAN}4. 查看所有Docker容器${NC}"
        echo -e "${CYAN}5. 停止指定Docker容器${NC}"
        echo -e "${CYAN}6. 启动指定Docker容器${NC}"
        echo -e "${CYAN}7. 重启指定Docker容器${NC}"
        echo -e "${CYAN}8. 克隆 Docker 项目${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" choice 0 8; then
            continue
        fi
        
        case $choice in
            1)
                show_compose_project_menu
                ;;
            2)
                echo -e "${YELLOW}在当前目录执行命令: docker-compose up -d${NC}"
                echo "----------------------------------------"
                docker-compose up -d
                echo "----------------------------------------"
                ;;
            3)
                echo -e "${YELLOW}在当前目录执行命令: docker-compose down${NC}"
                echo "----------------------------------------"
                docker-compose down
                echo "----------------------------------------"
                ;;
            4)
                echo -e "${YELLOW}执行命令: docker ps -a${NC}"
                echo "----------------------------------------"
                docker ps -a
                echo "----------------------------------------"
                ;;
            5)
                if safe_read "请输入要停止的容器名称或ID(输入q退出)" container; then
                    if [ -n "$container" ]; then
                        echo -e "${YELLOW}停止容器: $container${NC}"
                        docker stop $container
                    else
                        echo -e "${RED}错误: 未输入容器名称或ID${NC}"
                    fi
                fi
                ;;
            6)
                if safe_read "请输入要启动的容器名称或ID(输入q退出)" container; then
                    if [ -n "$container" ]; then
                        echo -e "${YELLOW}启动容器: $container${NC}"
                        docker start $container
                    else
                        echo -e "${RED}错误: 未输入容器名称或ID${NC}"
                    fi
                fi
                ;;
            7)
                if safe_read "请输入要重启的容器名称或ID(输入q退出)" container; then
                    if [ -n "$container" ]; then
                        echo -e "${YELLOW}重启容器: $container${NC}"
                        docker restart $container
                    else
                        echo -e "${RED}错误: 未输入容器名称或ID${NC}"
                    fi
                fi
                ;;
            8)
                clone_docker_project
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：克隆Docker项目
clone_docker_project() {
    echo -e "${YELLOW}克隆 Docker 项目${NC}"
    echo "----------------------------------------"
    echo -e "${BLUE}当前工作目录: $(pwd)${NC}"
    
    if ! safe_read "请输入目标目录(回车使用当前目录，输入q退出)" target_dir "."; then
        return
    fi
    
    if [ "$target_dir" != "." ]; then
        # 如果目录不存在，询问是否创建
        if [ ! -d "$target_dir" ]; then
            if ! safe_read_confirm "目录不存在，是否创建" create_dir; then
                return
            fi
            if [ "$create_dir" = "y" ]; then
                mkdir -p "$target_dir"
                if [ $? -ne 0 ]; then
                    echo -e "${RED}目录创建失败${NC}"
                    return 1
                fi
            else
                echo -e "${RED}操作取消${NC}"
                return 1
            fi
        fi
    fi
    
    echo -e "${GREEN}将在目录: $target_dir 执行克隆命令${NC}"
    echo -e "${YELLOW}执行命令: bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/git_clone_docker.sh)${NC}"
    echo "----------------------------------------"
    
    # 切换到目标目录
    cd "$target_dir"
    bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/git_clone_docker.sh)
    echo "----------------------------------------"
    
    echo -e "${GREEN}克隆完成，当前目录: $(pwd)${NC}"
}

# 函数：显示Compose项目菜单
show_compose_project_menu() {
    local base_path="/vol1/1000/compose"
    
    if [ ! -d "$base_path" ]; then
        echo -e "${RED}错误: 路径 $base_path 不存在${NC}"
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
        return
    fi
    
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "      Compose 项目列表 - $base_path"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}基础路径: $base_path${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要进入的项目：${NC}"
        
        # 获取目录列表并排序
        local projects=()
        local count=0
        
        # 读取目录，排除隐藏目录
        for dir in "$base_path"/*/; do
            if [ -d "$dir" ]; then
                local dir_name=$(basename "$dir")
                # 排除以 . 开头的隐藏目录
                if [[ ! "$dir_name" =~ ^\. ]]; then
                    projects+=("$dir_name")
                fi
            fi
        done
        
        # 按字母顺序排序
        IFS=$'\n' projects=($(sort <<<"${projects[*]}"))
        unset IFS
        
        # 显示项目列表，每行两个
        count=0
        for project in "${projects[@]}"; do
            count=$((count + 1))
            printf "${CYAN}%2d. 进入 %-30s${NC}" "$count" "$project"
            # 每行显示两个项目
            if [ $((count % 2)) -eq 0 ]; then
                echo ""
            fi
        done
        
        # 如果项目数是奇数，确保最后换行
        if [ $((count % 2)) -eq 1 ]; then
            echo ""
        fi
        
        echo "----------------------------------------"
        echo -e "${RED}0. 返回上一级${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" project_choice 0 $count; then
            continue
        fi
        
        if [ "$project_choice" -eq 0 ]; then
            break
        elif [ "$project_choice" -ge 1 ] && [ "$project_choice" -le $count ]; then
            local selected_project="${projects[$((project_choice - 1))]}"
            local full_path="$base_path/$selected_project"
            echo -e "${GREEN}已选择项目: $selected_project${NC}"
            echo -e "${BLUE}项目路径: $full_path${NC}"
            cd "$full_path"
            show_compose_commands_menu
        else
            echo -e "${RED}无效的选择，请重新输入${NC}"
            sleep 1
        fi
    done
}

# 函数：显示Compose命令菜单
show_compose_commands_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "        Compose 命令菜单"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要执行的 Compose 命令：${NC}"
        echo -e "${CYAN}1. 启动服务 (docker-compose up -d)${NC}"
        echo -e "${CYAN}2. 停止服务 (docker-compose down)${NC}"
        echo -e "${CYAN}3. 重启服务 (docker-compose restart)${NC}"
        echo -e "${CYAN}4. 查看服务状态 (docker-compose ps)${NC}"
        echo -e "${CYAN}5. 查看服务日志 (docker-compose logs)${NC}"
        echo -e "${CYAN}6. 重新构建并启动 (docker-compose up -d --build)${NC}"
        echo -e "${RED}0. 返回项目列表${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" cmd_choice 0 6; then
            continue
        fi
        
        case $cmd_choice in
            1)
                echo -e "${YELLOW}执行命令: docker-compose up -d${NC}"
                echo "----------------------------------------"
                docker-compose up -d
                echo "----------------------------------------"
                ;;
            2)
                echo -e "${YELLOW}执行命令: docker-compose down${NC}"
                echo "----------------------------------------"
                docker-compose down
                echo "----------------------------------------"
                ;;
            3)
                echo -e "${YELLOW}执行命令: docker-compose restart${NC}"
                echo "----------------------------------------"
                docker-compose restart
                echo "----------------------------------------"
                ;;
            4)
                echo -e "${YELLOW}执行命令: docker-compose ps${NC}"
                echo "----------------------------------------"
                docker-compose ps
                echo "----------------------------------------"
                ;;
            5)
                echo -e "${YELLOW}执行命令: docker-compose logs${NC}"
                echo "----------------------------------------"
                docker-compose logs
                echo "----------------------------------------"
                ;;
            6)
                echo -e "${YELLOW}执行命令: docker-compose up -d --build${NC}"
                echo "----------------------------------------"
                docker-compose up -d --build
                echo "----------------------------------------"
                ;;
            0)
                show_compose_commands_menu
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：显示Nginx子菜单
show_nginx_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "           Nginx 命令合集"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}1. 启动Nginx${NC}"
        echo -e "${CYAN}2. 停止Nginx${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}3. 测试Nginx配置${NC}"
        echo -e "${CYAN}4. 测试Nginx并重启${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}5. 查看 80 端口占用${NC}"
        echo -e "${CYAN}6. 查看Nginx运行状态${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}7. 查看Nginx配置目录${NC}"
        echo -e "${CYAN}8. 查看html目录${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" choice 0 8; then
            continue
        fi
        
        case $choice in
            1)
                echo -e "${YELLOW}执行命令: sudo systemctl start nginx${NC}"
                echo "----------------------------------------"
                sudo systemctl start nginx
                echo "----------------------------------------"
                ;;
            2)
                echo -e "${YELLOW}执行命令: sudo systemctl stop nginx${NC}"
                echo "----------------------------------------"
                sudo systemctl stop nginx
                echo "----------------------------------------"
                ;;
            3)
                echo -e "${YELLOW}执行命令: nginx -t${NC}"
                echo "----------------------------------------"
                sudo nginx -t
                echo "----------------------------------------"
                ;;
            4)
                echo -e "${YELLOW}执行命令: sudo nginx -t && sudo systemctl restart nginx${NC}"
                echo "----------------------------------------"
                sudo nginx -t && sudo systemctl restart nginx
                echo "----------------------------------------"
                ;;
            5)
                echo -e "${YELLOW}执行命令: sudo ss -tulnp | grep :80${NC}"
                echo "----------------------------------------"
                sudo ss -tulnp | grep :80
                echo "----------------------------------------"
                ;;
            6)
                echo -e "${YELLOW}执行命令: sudo systemctl status nginx${NC}"
                echo "----------------------------------------"
                sudo systemctl status nginx
                echo "----------------------------------------"
                ;;
            7)
                echo -e "${YELLOW}执行命令: cd /etc/nginx/conf.d && ls${NC}"
                echo "----------------------------------------"
                cd /etc/nginx/conf.d && ls
                echo "----------------------------------------"
                ;;
            8)
                echo -e "${YELLOW}执行命令: cd /etc/nginx/html && ls${NC}"
                echo "----------------------------------------"
                cd /etc/nginx/html && ls
                echo "----------------------------------------"
                ;;

            0)
                break
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：显示Linux通用子菜单
show_linux_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "          Linux 通用命令"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"

        echo -e "${CYAN}1. 更新并清理系统${NC}"
        echo -e "${CYAN}2. 安装软件${NC}"
        echo -e "${CYAN}3. 卸载软件${NC}"
        echo -e "${CYAN}4. 创建文件夹${NC}"
        echo -e "${CYAN}5. 文件夹加权限${NC}"
        echo -e "${CYAN}6. 文件加可执行权限${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" choice 0 6; then
            continue
        fi
        
        case $choice in
            1)
                echo -e "${YELLOW}更新并清理系统...${NC}"
                echo "----------------------------------------"
                # 检测系统类型
                if command -v apt >/dev/null 2>&1; then
                    # Debian/Ubuntu
                    echo "检测到 Debian/Ubuntu 系统"
                    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
                elif command -v yum >/dev/null 2>&1; then
                    # CentOS/RHEL
                    echo "检测到 CentOS/RHEL 系统"
                    sudo yum update -y && sudo yum autoremove -y
                elif command -v dnf >/dev/null 2>&1; then
                    # Fedora
                    echo "检测到 Fedora 系统"
                    sudo dnf update -y && sudo dnf autoremove -y
                else
                    echo -e "${RED}错误: 不支持的包管理器${NC}"
                fi
                echo "----------------------------------------"
                ;;
            2)
                if safe_read "请输入要安装的软件包名称(输入q退出)" package; then
                    if [ -n "$package" ]; then
                        echo -e "${YELLOW}安装软件: $package${NC}"
                        echo "----------------------------------------"
                        # 检测系统类型
                        if command -v apt >/dev/null 2>&1; then
                            sudo apt update && sudo apt install -y $package
                        elif command -v yum >/dev/null 2>&1; then
                            sudo yum install -y $package
                        elif command -v dnf >/dev/null 2>&1; then
                            sudo dnf install -y $package
                        else
                            echo -e "${RED}错误: 不支持的包管理器${NC}"
                        fi
                        echo "----------------------------------------"
                    else
                        echo -e "${RED}错误: 未输入软件包名称${NC}"
                    fi
                fi
                ;;
            3)
                if safe_read "请输入要卸载的软件包名称(输入q退出)" package; then
                    if [ -n "$package" ]; then
                        echo -e "${YELLOW}卸载软件: $package${NC}"
                        echo "----------------------------------------"
                        # 检测系统类型
                        if command -v apt >/dev/null 2>&1; then
                            sudo apt remove -y $package
                        elif command -v yum >/dev/null 2>&1; then
                            sudo yum remove -y $package
                        elif command -v dnf >/dev/null 2>&1; then
                            sudo dnf remove -y $package
                        else
                            echo -e "${RED}错误: 不支持的包管理器${NC}"
                        fi
                        echo "----------------------------------------"
                    else
                        echo -e "${RED}错误: 未输入软件包名称${NC}"
                    fi
                fi
                ;;
            4)
                if safe_read "请输入要创建的文件夹路径(输入q退出)" dir_path; then
                    if [ -n "$dir_path" ]; then
                        echo -e "${YELLOW}创建文件夹: $dir_path${NC}"
                        mkdir -p "$dir_path"
                        if [ $? -eq 0 ]; then
                            echo -e "${GREEN}文件夹创建成功${NC}"
                        else
                            echo -e "${RED}文件夹创建失败${NC}"
                        fi
                    else
                        echo -e "${RED}错误: 未输入文件夹路径${NC}"
                    fi
                fi
                ;;
            5)
                if safe_read "请输入要设置权限的文件夹路径(输入q退出)" dir_path; then
                    if [ -n "$dir_path" ]; then
                        if [ -d "$dir_path" ]; then
                            if safe_read "请输入权限(如 755)" perm; then
                                if [ -n "$perm" ]; then
                                    echo -e "${YELLOW}设置文件夹 $dir_path 权限为 $perm${NC}"
                                    chmod $perm "$dir_path"
                                    if [ $? -eq 0 ]; then
                                        echo -e "${GREEN}权限设置成功${NC}"
                                    else
                                        echo -e "${RED}权限设置失败${NC}"
                                    fi
                                else
                                    echo -e "${RED}错误: 未输入权限${NC}"
                                fi
                            fi
                        else
                            echo -e "${RED}错误: 文件夹不存在${NC}"
                        fi
                    else
                        echo -e "${RED}错误: 未输入文件夹路径${NC}"
                    fi
                fi
                ;;
            6)
                if safe_read "请输入要加执行权限的文件路径(输入q退出)" file_path; then
                    if [ -n "$file_path" ]; then
                        if [ -f "$file_path" ]; then
                            echo -e "${YELLOW}给文件 $file_path 添加执行权限${NC}"
                            chmod +x "$file_path"
                            if [ $? -eq 0 ]; then
                                echo -e "${GREEN}权限添加成功${NC}"
                            else
                                echo -e "${RED}权限添加失败${NC}"
                            fi
                        else
                            echo -e "${RED}错误: 文件不存在${NC}"
                        fi
                    else
                        echo -e "${RED}错误: 未输入文件路径${NC}"
                    fi
                fi
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：显示Linux文件命令子菜单
show_linux_file_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "          Linux 文件命令"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"

        echo -e "${CYAN}1. 创建文件${NC}"
        echo -e "${CYAN}2. 创建文件夹${NC}"
        echo -e "${CYAN}3. 文件添加权限${NC}"
        echo -e "${CYAN}4. 文件夹添加权限${NC}"
        echo -e "${CYAN}5. 文件搜索${NC}"
        echo -e "${CYAN}6. 删除文件${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" choice 0 6; then
            continue
        fi
        
        case $choice in
            1)
                create_file
                ;;
            2)
                create_directory
                ;;
            3)
                add_file_permission
                ;;
            4)
                add_directory_permission
                ;;
            5)
                search_file
                ;;
            6)
                delete_file
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：创建文件
create_file() {
    while true; do
        echo -e "${YELLOW}创建文件${NC}"
        echo "----------------------------------------"
        
        if ! safe_read "请输入文件名(输入q退出)" file_name; then
            return
        fi
        
        # 检查文件是否已存在
        if [ -e "$file_name" ]; then
            echo -e "${RED}错误: 文件 '$file_name' 已存在${NC}"
            if ! safe_read_confirm "是否覆盖" overwrite; then
                continue
            fi
            if [ "$overwrite" != "y" ]; then
                continue
            fi
        fi
        
        echo -e "${GREEN}将创建文件: $file_name${NC}"
        echo -e "${YELLOW}请输入文件内容(输入 'EOF' 单独一行结束输入):${NC}"
        
        # 创建临时文件来存储内容
        temp_file=$(mktemp)
        
        # 读取多行输入
        line_count=0
        while IFS= read -r line; do
            if [ "$line" = "EOF" ]; then
                break
            fi
            echo "$line" >> "$temp_file"
            line_count=$((line_count + 1))
        done
        
        if [ $line_count -eq 0 ]; then
            echo -e "${YELLOW}未输入内容，创建空文件${NC}"
            touch "$file_name"
        else
            # 将内容写入目标文件
            mv "$temp_file" "$file_name"
            echo -e "${GREEN}文件 '$file_name' 创建成功，共写入 $line_count 行${NC}"
        fi
        
        # 显示文件内容预览
        echo -e "${YELLOW}文件内容预览:${NC}"
        echo "----------------------------------------"
        cat "$file_name" 2>/dev/null || echo -e "${RED}无法显示文件内容${NC}"
        echo "----------------------------------------"
        
        # 根据文件后缀提示添加权限
        if [[ "$file_name" =~ \.sh$ ]] || [[ "$file_name" =~ \.py$ ]] || [[ "$file_name" =~ \.pl$ ]]; then
            if ! safe_read_confirm "检测到脚本文件，是否添加执行权限" add_exec; then
                continue
            fi
            if [ "$add_exec" = "y" ]; then
                chmod +x "$file_name"
                echo -e "${GREEN}已为文件 '$file_name' 添加执行权限${NC}"
            fi
        fi
        
        if ! safe_read_confirm "是否继续创建其他文件" continue_create; then
            break
        fi
        if [ "$continue_create" != "y" ]; then
            break
        fi
    done
}

# 函数：创建文件夹
create_directory() {
    while true; do
        echo -e "${YELLOW}创建文件夹${NC}"
        echo "----------------------------------------"
        
        if ! safe_read "请输入文件夹名(输入q退出)" dir_name; then
            return
        fi
        
        # 检查文件夹是否已存在
        if [ -d "$dir_name" ]; then
            echo -e "${RED}错误: 文件夹 '$dir_name' 已存在${NC}"
            if ! safe_read_confirm "是否继续创建其他文件夹" continue_create; then
                break
            fi
            if [ "$continue_create" != "y" ]; then
                break
            else
                continue
            fi
        fi
        
        echo -e "${YELLOW}执行命令: mkdir -p $dir_name${NC}"
        mkdir -p "$dir_name"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}文件夹 '$dir_name' 创建成功${NC}"
            echo -e "${BLUE}完整路径: $(pwd)/$dir_name${NC}"
            
            # 提示添加文件夹权限
            echo -e "${YELLOW}是否设置文件夹权限?${NC}"
            echo -e "${CYAN}示例权限: ${NC}"
            echo -e "${CYAN}  755 - 所有者可读可写可执行，组和其他用户可读可执行${NC}"
            echo -e "${CYAN}  777 - 所有用户可读可写可执行${NC}"
            echo -e "${CYAN}  644 - 所有者可读可写，组和其他用户只读${NC}"
            
            if safe_read "请输入权限(回车使用默认755)" perm "755"; then
                if [[ "$perm" =~ ^[0-7]{3}$ ]]; then
                    chmod $perm "$dir_name"
                    echo -e "${GREEN}已设置文件夹 '$dir_name' 权限为 $perm${NC}"
                else
                    echo -e "${RED}无效的权限格式，使用默认权限755${NC}"
                    chmod 755 "$dir_name"
                fi
            fi
        else
            echo -e "${RED}文件夹创建失败${NC}"
        fi
        
        if ! safe_read_confirm "是否继续创建其他文件夹" continue_create; then
            break
        fi
        if [ "$continue_create" != "y" ]; then
            break
        fi
    done
}

# 函数：文件添加权限
add_file_permission() {
    while true; do
        echo -e "${YELLOW}文件添加权限${NC}"
        echo "----------------------------------------"
        echo -e "${BLUE}当前目录文件列表:${NC}"
        echo "----------------------------------------"
        
        # 获取当前目录的文件列表（排除目录）
        local files=()
        local count=0
        
        while IFS= read -r -d $'\0' file; do
            if [ -f "$file" ]; then
                files+=("$file")
            fi
        done < <(find . -maxdepth 1 -type f -print0 2>/dev/null | sort -z)
        
        # 显示文件列表
        count=0
        for file in "${files[@]}"; do
            count=$((count + 1))
            file_perms=$(ls -la "$file" | awk '{print $1}')
            file_size=$(ls -la "$file" | awk '{print $5}')
            printf "${CYAN}%2d. ${YELLOW}%-30s ${BLUE}(%s, %s bytes)${NC}\n" "$count" "$(basename "$file")" "$file_perms" "$file_size"
        done
        
        if [ $count -eq 0 ]; then
            echo -e "${RED}当前目录没有文件${NC}"
            return
        fi
        
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择操作方式:${NC}"
        echo -e "${CYAN}1. 从列表中选择文件${NC}"
        echo -e "${CYAN}2. 手动输入文件路径${NC}"
        echo -e "${RED}0. 返回上一级${NC}"
        
        if ! safe_read_number "请输入选择" choice 0 2; then
            continue
        fi
        
        case $choice in
            1)
                if [ $count -eq 0 ]; then
                    echo -e "${RED}没有文件可供选择${NC}"
                    continue
                fi
                
                if ! safe_read_number "请输入文件序号" file_index 1 $count; then
                    continue
                fi
                
                selected_file="${files[$((file_index - 1))]}"
                echo -e "${GREEN}已选择文件: $selected_file${NC}"
                ;;
            2)
                if ! safe_read "请输入文件路径" selected_file; then
                    continue
                fi
                if [ ! -f "$selected_file" ]; then
                    echo -e "${RED}错误: 文件不存在${NC}"
                    continue
                fi
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}无效的选择${NC}"
                continue
                ;;
        esac
        
        # 根据文件后缀提示添加权限
        echo -e "${YELLOW}文件: $selected_file${NC}"
        file_perms=$(ls -la "$selected_file" | awk '{print $1}')
        echo -e "${BLUE}当前权限: $file_perms${NC}"
        
        if [[ "$selected_file" =~ \.sh$ ]] || [[ "$selected_file" =~ \.py$ ]] || [[ "$selected_file" =~ \.pl$ ]]; then
            echo -e "${YELLOW}检测到脚本文件，建议添加执行权限${NC}"
            if ! safe_read_confirm "是否添加执行权限" add_exec; then
                continue
            fi
            if [ "$add_exec" = "y" ]; then
                chmod +x "$selected_file"
                echo -e "${GREEN}已为文件 '$selected_file' 添加执行权限${NC}"
            fi
        else
            echo -e "${YELLOW}请选择要设置的权限:${NC}"
            echo -e "${CYAN}1. 添加执行权限 (+x)${NC}"
            echo -e "${CYAN}2. 设置为可读可写 (644)${NC}"
            echo -e "${CYAN}3. 设置为可读可写可执行 (755)${NC}"
            echo -e "${CYAN}4. 自定义权限${NC}"
            echo -e "${RED}0. 跳过${NC}"
            
            if ! safe_read_number "请输入选择" perm_choice 0 4; then
                continue
            fi
            
            case $perm_choice in
                1)
                    chmod +x "$selected_file"
                    echo -e "${GREEN}已为文件 '$selected_file' 添加执行权限${NC}"
                    ;;
                2)
                    chmod 644 "$selected_file"
                    echo -e "${GREEN}已设置文件 '$selected_file' 权限为644${NC}"
                    ;;
                3)
                    chmod 755 "$selected_file"
                    echo -e "${GREEN}已设置文件 '$selected_file' 权限为755${NC}"
                    ;;
                4)
                    if safe_read "请输入权限(如 755)" custom_perm; then
                        if [[ "$custom_perm" =~ ^[0-7]{3}$ ]]; then
                            chmod $custom_perm "$selected_file"
                            echo -e "${GREEN}已设置文件 '$selected_file' 权限为 $custom_perm${NC}"
                        else
                            echo -e "${RED}无效的权限格式${NC}"
                        fi
                    fi
                    ;;
                0)
                    echo -e "${YELLOW}跳过权限设置${NC}"
                    ;;
                *)
                    echo -e "${RED}无效的选择${NC}"
                    ;;
            esac
        fi
        
        # 显示更新后的权限
        new_perms=$(ls -la "$selected_file" | awk '{print $1}')
        echo -e "${BLUE}更新后权限: $new_perms${NC}"
        
        if ! safe_read_confirm "是否继续设置其他文件权限" continue_set; then
            break
        fi
        if [ "$continue_set" != "y" ]; then
            break
        fi
    done
}

# 函数：文件夹添加权限
add_directory_permission() {
    while true; do
        echo -e "${YELLOW}文件夹添加权限${NC}"
        echo "----------------------------------------"
        echo -e "${BLUE}当前目录文件夹列表:${NC}"
        echo "----------------------------------------"
        
        # 获取当前目录的文件夹列表
        local dirs=()
        local count=0
        
        while IFS= read -r -d $'\0' dir; do
            if [ -d "$dir" ] && [ "$dir" != "." ] && [ "$dir" != ".." ]; then
                dirs+=("$dir")
            fi
        done < <(find . -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
        
        # 显示文件夹列表
        count=0
        for dir in "${dirs[@]}"; do
            count=$((count + 1))
            dir_perms=$(ls -la "$dir" | awk '{print $1}')
            printf "${CYAN}%2d. ${YELLOW}%-30s ${BLUE}(%s)${NC}\n" "$count" "$(basename "$dir")" "$dir_perms"
        done
        
        if [ $count -eq 0 ]; then
            echo -e "${RED}当前目录没有文件夹${NC}"
            return
        fi
        
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择操作方式:${NC}"
        echo -e "${CYAN}1. 从列表中选择文件夹${NC}"
        echo -e "${CYAN}2. 手动输入文件夹路径${NC}"
        echo -e "${RED}0. 返回上一级${NC}"
        
        if ! safe_read_number "请输入选择" choice 0 2; then
            continue
        fi
        
        case $choice in
            1)
                if [ $count -eq 0 ]; then
                    echo -e "${RED}没有文件夹可供选择${NC}"
                    continue
                fi
                
                if ! safe_read_number "请输入文件夹序号" dir_index 1 $count; then
                    continue
                fi
                
                selected_dir="${dirs[$((dir_index - 1))]}"
                echo -e "${GREEN}已选择文件夹: $selected_dir${NC}"
                ;;
            2)
                if ! safe_read "请输入文件夹路径" selected_dir; then
                    continue
                fi
                if [ ! -d "$selected_dir" ]; then
                    echo -e "${RED}错误: 文件夹不存在${NC}"
                    continue
                fi
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}无效的选择${NC}"
                continue
                ;;
        esac
        
        # 显示当前权限并设置新权限
        echo -e "${YELLOW}文件夹: $selected_dir${NC}"
        dir_perms=$(ls -la "$selected_dir" | awk '{print $1}')
        echo -e "${BLUE}当前权限: $dir_perms${NC}"
        
        echo -e "${YELLOW}请选择要设置的权限:${NC}"
        echo -e "${CYAN}示例权限: ${NC}"
        echo -e "${CYAN}  755 - 所有者可读可写可执行，组和其他用户可读可执行 (推荐)${NC}"
        echo -e "${CYAN}  777 - 所有用户可读可写可执行 (谨慎使用)${NC}"
        echo -e "${CYAN}  700 - 仅所有者可读可写可执行${NC}"
        echo -e "${CYAN}  1. 使用推荐权限 (755)${NC}"
        echo -e "${CYAN}  2. 完全开放权限 (777)${NC}"
        echo -e "${CYAN}  3. 私有权限 (700)${NC}"
        echo -e "${CYAN}  4. 自定义权限${NC}"
        echo -e "${RED}  0. 跳过${NC}"
        
        if ! 
_number "请输入选择" perm_choice 0 4; then
            continue
        fi
        
        case $perm_choice in
            1)
                chmod 755 "$selected_dir"
                echo -e "${GREEN}已设置文件夹 '$selected_dir' 权限为755${NC}"
                ;;
            2)
                if ! safe_read_confirm "警告: 777权限非常开放，确定要继续" confirm; then
                    continue
                fi
                if [ "$confirm" = "y" ]; then
                    chmod 777 "$selected_dir"
                    echo -e "${GREEN}已设置文件夹 '$selected_dir' 权限为777${NC}"
                else
                    echo -e "${YELLOW}已取消设置权限${NC}"
                fi
                ;;
            3)
                chmod 700 "$selected_dir"
                echo -e "${GREEN}已设置文件夹 '$selected_dir' 权限为700${NC}"
                ;;
            4)
                if safe_read "请输入权限(如 755)" custom_perm; then
                    if [[ "$custom_perm" =~ ^[0-7]{3}$ ]]; then
                        chmod $custom_perm "$selected_dir"
                        echo -e "${GREEN}已设置文件夹 '$selected_dir' 权限为 $custom_perm${NC}"
                    else
                        echo -e "${RED}无效的权限格式${NC}"
                    fi
                fi
                ;;
            0)
                echo -e "${YELLOW}跳过权限设置${NC}"
                ;;
            *)
                echo -e "${RED}无效的选择${NC}"
                ;;
        esac
        
        # 显示更新后的权限
        new_perms=$(ls -la "$selected_dir" | awk '{print $1}')
        echo -e "${BLUE}更新后权限: $new_perms${NC}"
        
        if ! safe_read_confirm "是否继续设置其他文件夹权限" continue_set; then
            break
        fi
        if [ "$continue_set" != "y" ]; then
            break
        fi
    done
}

# 函数：文件搜索
search_file() {
    while true; do
        echo -e "${YELLOW}文件搜索${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择搜索范围:${NC}"
        echo -e "${CYAN}1. 当前目录搜索${NC}"
        echo -e "${CYAN}2. 指定目录搜索${NC}"
        echo -e "${RED}0. 返回上一级${NC}"
        
        if ! safe_read_number "请输入选择" scope_choice 0 2; then
            continue
        fi
        
        case $scope_choice in
            1)
                search_path="."
                ;;
            2)
                if ! safe_read "请输入搜索目录路径" search_path; then
                    continue
                fi
                if [ ! -d "$search_path" ]; then
                    echo -e "${RED}错误: 目录不存在${NC}"
                    continue
                fi
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}无效的选择${NC}"
                continue
                ;;
        esac
        
        echo -e "${YELLOW}请选择搜索模式:${NC}"
        echo -e "${CYAN}1. 精确搜索 (按完整文件名)${NC}"
        echo -e "${CYAN}2. 模糊搜索 (按文件名包含)${NC}"
        echo -e "${CYAN}3. 扩展名搜索 (按文件后缀)${NC}"
        echo -e "${CYAN}4. 大小写不敏感搜索${NC}"
        
        if ! safe_read_number "请输入搜索模式" search_mode 1 4; then
            continue
        fi
        
        case $search_mode in
            1)
                if ! safe_read "请输入完整文件名(支持通配符 *)" search_name; then
                    continue
                fi
                find_cmd="find \"$search_path\" -name \"$search_name\""
                echo -e "${YELLOW}执行命令: $find_cmd${NC}"
                ;;
            2)
                if ! safe_read "请输入文件名包含的文本" search_name; then
                    continue
                fi
                find_cmd="find \"$search_path\" -name \"*$search_name*\""
                echo -e "${YELLOW}执行命令: $find_cmd${NC}"
                ;;
            3)
                if ! safe_read "请输入文件扩展名(如: txt, sh, py)" search_name; then
                    continue
                fi
                find_cmd="find \"$search_path\" -name \"*.$search_name\""
                echo -e "${YELLOW}执行命令: $find_cmd${NC}"
                ;;
            4)
                if ! safe_read "请输入搜索名称(不区分大小写)" search_name; then
                    continue
                fi
                find_cmd="find \"$search_path\" -iname \"*$search_name*\""
                echo -e "${YELLOW}执行命令: $find_cmd${NC}"
                ;;
            *)
                echo -e "${RED}无效的搜索模式${NC}"
                continue
                ;;
        esac
        
        echo "----------------------------------------"
        
        # 执行搜索
        result_count=0
        while IFS= read -r -d $'\0' file; do
            result_count=$((result_count + 1))
            file_type=""
            file_color=""
            
            if [ -d "$file" ]; then
                file_type="[目录]"
                file_color="${CYAN}"
            elif [ -f "$file" ]; then
                if [ -x "$file" ]; then
                    file_type="[可执行文件]"
                    file_color="${GREEN}"
                else
                    file_type="[文件]"
                    file_color="${GREEN}"
                fi
            elif [ -L "$file" ]; then
                file_type="[链接]"
                file_color="${PURPLE}"
            else
                file_type="[其他]"
                file_color="${YELLOW}"
            fi
            
            # 获取文件大小和权限
            file_size=$(ls -la "$file" 2>/dev/null | awk '{print $5}')
            file_perms=$(ls -la "$file" 2>/dev/null | awk '{print $1}')
            file_date=$(ls -la "$file" 2>/dev/null | awk '{print $6, $7, $8}')
            
            echo -e "${file_color}${file_type} $file ${BLUE}(大小: ${file_size}, 权限: ${file_perms}, 日期: ${file_date})${NC}"
        done < <(eval "$find_cmd -print0" 2>/dev/null)
        
        if [ $result_count -eq 0 ]; then
            echo -e "${RED}未找到匹配的文件或目录${NC}"
        else
            echo "----------------------------------------"
            echo -e "${GREEN}找到 $result_count 个结果${NC}"
            
            # 提供进一步操作的选项
            echo "----------------------------------------"
            echo -e "${YELLOW}是否对搜索结果执行操作?${NC}"
            echo -e "${CYAN}1. 查看文件内容${NC}"
            echo -e "${CYAN}2. 复制文件${NC}"
            echo -e "${CYAN}3. 移动文件${NC}"
            echo -e "${CYAN}4. 删除文件${NC}"
            echo -e "${RED}0. 不执行操作，继续搜索${NC}"
            
            if ! safe_read_number "请选择" action_choice 0 4; then
                continue
            fi
            
            case $action_choice in
                1)
                    # 重新执行搜索并存储结果
                    search_results=()
                    while IFS= read -r -d $'\0' file; do
                        if [ -f "$file" ] && [ -r "$file" ]; then
                            search_results+=("$file")
                        fi
                    done < <(eval "$find_cmd -print0" 2>/dev/null)
                    
                    if [ ${#search_results[@]} -eq 0 ]; then
                        echo -e "${RED}没有可读的文件${NC}"
                    else
                        echo -e "${YELLOW}请选择要查看的文件:${NC}"
                        for i in "${!search_results[@]}"; do
                            echo -e "${CYAN}$((i+1)). ${search_results[i]}${NC}"
                        done
                        if ! safe_read_number "请输入文件序号" file_index 1 ${#search_results[@]}; then
                            continue
                        fi
                        selected_file="${search_results[$((file_index-1))]}"
                        echo -e "${YELLOW}文件内容: $selected_file${NC}"
                        echo "----------------------------------------"
                        cat "$selected_file" 2>/dev/null || echo -e "${RED}无法读取文件${NC}"
                        echo "----------------------------------------"
                    fi
                    ;;
                2)
                    if safe_read "请输入目标目录" target_dir; then
                        if [ -d "$target_dir" ]; then
                            while IFS= read -r -d $'\0' file; do
                                if [ -f "$file" ]; then
                                    cp "$file" "$target_dir/"
                                    echo -e "${GREEN}已复制: $file -> $target_dir/${NC}"
                                fi
                            done < <(eval "$find_cmd -print0" 2>/dev/null)
                        else
                            echo -e "${RED}目标目录不存在${NC}"
                        fi
                    fi
                    ;;
                3)
                    if safe_read "请输入目标目录" target_dir; then
                        if [ -d "$target_dir" ]; then
                            while IFS= read -r -d $'\0' file; do
                                if [ -f "$file" ]; then
                                    mv "$file" "$target_dir/"
                                    echo -e "${GREEN}已移动: $file -> $target_dir/${NC}"
                                fi
                            done < <(eval "$find_cmd -print0" 2>/dev/null)
                        else
                            echo -e "${RED}目标目录不存在${NC}"
                        fi
                    fi
                    ;;
                4)
                    echo -e "${RED}警告: 这将删除所有搜索到的文件${NC}"
                    if ! safe_read_confirm "确定要删除吗" confirm_delete; then
                        continue
                    fi
                    if [ "$confirm_delete" = "y" ]; then
                        while IFS= read -r -d $'\0' file; do
                            if [ -f "$file" ]; then
                                rm -f "$file"
                                echo -e "${GREEN}已删除: $file${NC}"
                            fi
                        done < <(eval "$find_cmd -print0" 2>/dev/null)
                    else
                        echo -e "${YELLOW}已取消删除${NC}"
                    fi
                    ;;
                0)
                    # 不执行任何操作，继续
                    ;;
                *)
                    echo -e "${RED}无效的选择${NC}"
                    ;;
            esac
        fi
        
        if ! safe_read_confirm "是否继续搜索" continue_search; then
            break
        fi
        if [ "$continue_search" != "y" ]; then
            break
        fi
    done
}

# 函数：删除文件
delete_file() {
    while true; do
        echo -e "${YELLOW}删除文件${NC}"
        echo "----------------------------------------"
        echo -e "${BLUE}当前目录内容列表:${NC}"
        echo "----------------------------------------"
        
        # 获取当前目录的所有内容
        local items=()
        local count=0
        
        while IFS= read -r -d $'\0' item; do
            if [ "$item" != "." ]; then
                items+=("$item")
            fi
        done < <(find . -maxdepth 1 -print0 2>/dev/null | sort -z)
        
        # 显示内容列表
        count=0
        for item in "${items[@]}"; do
            count=$((count + 1))
            item_name=$(basename "$item")
            if [ -d "$item" ]; then
                printf "${CYAN}%2d. ${RED}[目录] %-30s${NC}\n" "$count" "$item_name"
            elif [ -f "$item" ]; then
                printf "${CYAN}%2d. ${GREEN}[文件] %-30s${NC}\n" "$count" "$item_name"
            else
                printf "${CYAN}%2d. ${YELLOW}[其他] %-30s${NC}\n" "$count" "$item_name"
            fi
        done
        
        if [ $count -eq 0 ]; then
            echo -e "${RED}当前目录为空${NC}"
            return
        fi
        
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择操作方式:${NC}"
        echo -e "${CYAN}1. 从列表中选择${NC}"
        echo -e "${CYAN}2. 手动输入路径${NC}"
        echo -e "${RED}0. 返回上一级${NC}"
        
        if ! safe_read_number "请输入选择" choice 0 2; then
            continue
        fi
        
        case $choice in
            1)
                if [ $count -eq 0 ]; then
                    echo -e "${RED}没有内容可供选择${NC}"
                    continue
                fi
                
                if ! safe_read_number "请输入序号" item_index 1 $count; then
                    continue
                fi
                
                selected_item="${items[$((item_index - 1))]}"
                echo -e "${GREEN}已选择: $selected_item${NC}"
                ;;
            2)
                if ! safe_read "请输入要删除的路径" selected_item; then
                    continue
                fi
                if [ ! -e "$selected_item" ]; then
                    echo -e "${RED}错误: 路径不存在${NC}"
                    continue
                fi
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}无效的选择${NC}"
                continue
                ;;
        esac
        
        # 确认删除
        if [ -d "$selected_item" ]; then
            echo -e "${RED}警告: 您将要删除目录 '$selected_item'${NC}"
            if ! safe_read_confirm "确定要删除这个目录及其所有内容吗" confirm; then
                continue
            fi
        else
            echo -e "${RED}警告: 您将要删除 '$selected_item'${NC}"
            if ! safe_read_confirm "确定要删除吗" confirm; then
                continue
            fi
        fi
        
        if [ "$confirm" = "y" ]; then
            if rm -rf "$selected_item"; then
                echo -e "${GREEN}成功删除: $selected_item${NC}"
            else
                echo -e "${RED}删除失败: $selected_item${NC}"
            fi
        else
            echo -e "${YELLOW}已取消删除${NC}"
        fi
        
        if ! safe_read_confirm "是否继续删除其他文件" continue_delete; then
            break
        fi
        if [ "$continue_delete" != "y" ]; then
            break
        fi
    done
}

# 函数：显示压缩/解压子菜单
show_compress_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "          Linux 压缩/解压工具"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要执行的操作：${NC}"
        echo -e "${CYAN}1. 压缩文件/目录${NC}"
        echo -e "${CYAN}2. 解压文件${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" choice 0 2; then
            continue
        fi
        
        case $choice in
            1)
                compress_submenu
                ;;
            2)
                decompress_submenu
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：压缩子菜单
compress_submenu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "=============================================="
        echo ">>> 压缩模式"
        echo "=============================================="
        echo -e "${NC}"
        
        # 扫描当前目录下的文件/目录（排除压缩包）
        mapfile -t list < <(
            find . -maxdepth 1 -type f \( ! -name '*.zip' ! -name '*.7z' ! -name '*.tar*' ! -name '*.rar' ! -name '*.gz' ! -name '*.bz2' ! -name '*.xz' \) -printf '%P\n' | sort
            find . -maxdepth 1 -type d ! -name '.' ! -name '.*' -printf '%P\n' | sort
        )
        
        if ((${#list[@]}==0)); then
            echo -e "${YELLOW}(当前目录无可压缩的文件/目录)${NC}"
            list=()
        else
            echo -e "${CYAN}当前目录下的文件/目录：${NC}"
            for i in "${!list[@]}"; do
                printf "  ${GREEN}%2d)${NC} %s\n" $((i+1)) "${list[i]}"
            done
        fi
        echo -e "${CYAN}==============================================${NC}"
        
        if ! safe_read "请输入序号选择，或手动输入文件名/目录名（留空取消）" choice; then
            echo -e "${YELLOW}已取消${NC}"
            return
        fi
        
        [[ -z $choice ]] && { echo -e "${YELLOW}已取消${NC}"; return; }
        
        # 判断是序号还是手动输入
        if [[ $choice =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#list[@]} )); then
            target="${list[$((choice-1))]}"
        else
            target="$choice"
        fi
        
        [[ -e $target ]] || { echo -e "${RED}错误：'$target' 不存在！${NC}"; return; }
        
        echo -e "${YELLOW}请选择压缩格式：${NC}"
        echo -e "  1) zip\n  2) 7z\n  3) tar.gz\n  4) tar.xz\n  5) tar.bz2\n  6) tar"
        
        if ! safe_read_number "输入序号 [1-6]" fmt_idx 1 6; then
            continue
        fi
        
        # 检查对应命令是否存在
        case $fmt_idx in
            1) 
                ext="zip"; cmd=("zip" "-r" "-q")
                if ! command -v zip &> /dev/null; then
                    echo -e "${RED}错误：zip 命令未安装！${NC}"
                    return
                fi
                ;;
            2) 
                ext="7z"; cmd=("7z" "a")
                if ! command -v 7z &> /dev/null; then
                    echo -e "${RED}错误：7z 命令未安装！${NC}"
                    return
                fi
                ;;
            3) 
                ext="tar.gz"; cmd=("tar" "-zcf")
                if ! command -v tar &> /dev/null; then
                    echo -e "${RED}错误：tar 命令未安装！${NC}"
                    return
                fi
                ;;
            4) 
                ext="tar.xz"; cmd=("tar" "-Jcf")
                if ! command -v tar &> /dev/null || ! command -v xz &> /dev/null; then
                    echo -e "${RED}错误：tar 或 xz 命令未安装！${NC}"
                    return
                fi
                ;;
            5) 
                ext="tar.bz2"; cmd=("tar" "-jcf")
                if ! command -v tar &> /dev/null || ! command -v bzip2 &> /dev/null; then
                    echo -e "${RED}错误：tar 或 bzip2 命令未安装！${NC}"
                    return
                fi
                ;;
            6) 
                ext="tar"; cmd=("tar" "-cf")
                if ! command -v tar &> /dev/null; then
                    echo -e "${RED}错误：tar 命令未安装！${NC}"
                    return
                fi
                ;;
            *) echo -e "${RED}无效序号！${NC}"; return ;;
        esac
        
        output="${target%%/}.${ext}"
        echo -e "${GREEN}正在压缩 → ${output}${NC}"
        
        case $fmt_idx in
            1|2) 
                "${cmd[@]}" "$output" "$target" 
                ;;
            3|4|5|6) 
                "${cmd[@]}" "$output" -C "$(dirname "$target")" "$(basename "$target")" 
                ;;
        esac 
        
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}压缩完成！${NC}"
        else
            echo -e "${RED}压缩失败！${NC}"
        fi
        
        if ! safe_read_confirm "是否继续压缩其他文件" continue_compress; then
            break
        fi
        if [ "$continue_compress" != "y" ]; then
            break
        fi
    done
}

# 函数：检查重复文件
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

# 函数：解压子菜单
decompress_submenu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo "=============================================="
        echo ">>> 解压模式"
        echo "=============================================="
        echo -e "${NC}"
        
        # 支持更多压缩格式
        mapfile -t list < <(
            ls -1 *.zip *.7z *.tar *.tar.gz *.tar.bz2 *.tar.xz *.tgz *.tbz2 *.txz *.rar *.gz *.bz2 *.xz 2>/dev/null | sort -u
        )
        
        if ((${#list[@]}==0)); then
            echo -e "${YELLOW}(当前目录无压缩包)${NC}"
            list=()
        else
            echo -e "${CYAN}当前目录下的压缩包：${NC}"
            for i in "${!list[@]}"; do
                printf "  ${GREEN}%2d)${NC} %s\n" $((i+1)) "${list[i]}"
            done
        fi
        echo -e "${CYAN}==============================================${NC}"
        
        if ! safe_read "请输入序号选择，或手动输入文件名（留空取消）" choice; then
            echo -e "${YELLOW}已取消${NC}"
            return
        fi
        
        [[ -z $choice ]] && { echo -e "${YELLOW}已取消${NC}"; return; }
        
        if [[ $choice =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#list[@]} )); then
            archive="${list[$((choice-1))]}"
        else
            archive="$choice"
        fi
        
        [[ -f $archive ]] || { echo -e "${RED}错误：'$archive' 不存在！${NC}"; return; }
        
        # 根据文件扩展名设置解压命令
        local cmd=()
        case "$archive" in
            *.zip)  
                cmd=("unzip" "-q")
                if ! command -v unzip &> /dev/null; then
                    echo -e "${RED}错误：unzip 命令未安装！${NC}"
                    return
                fi
                ;;
            *.7z)   
                cmd=("7z" "x")
                if ! command -v 7z &> /dev/null; then
                    echo -e "${RED}错误：7z 命令未安装！${NC}"
                    return
                fi
                ;;
            *.tar) 
                cmd=("tar" "-xf")
                if ! command -v tar &> /dev/null; then
                    echo -e "${RED}错误：tar 命令未安装！${NC}"
                    return
                fi
                ;;
            *.tar.gz|*.tgz) 
                cmd=("tar" "-zxf")
                if ! command -v tar &> /dev/null; then
                    echo -e "${RED}错误：tar 命令未安装！${NC}"
                    return
                fi
                ;;
            *.tar.bz2|*.tbz2) 
                cmd=("tar" "-jxf")
                if ! command -v tar &> /dev/null; then
                    echo -e "${RED}错误：tar 命令未安装！${NC}"
                    return
                fi
                ;;
            *.tar.xz|*.txz) 
                cmd=("tar" "-Jxf")
                if ! command -v tar &> /dev/null; then
                    echo -e "${RED}错误：tar 命令未安装！${NC}"
                    return
                fi
                ;;
            *.rar)
                if command -v unrar &> /dev/null; then
                    cmd=("unrar" "x" "-inul")
                elif command -v rar &> /dev/null; then
                    cmd=("rar" "x" "-inul")
                else
                    echo -e "${RED}错误：unrar 或 rar 命令未安装！${NC}"
                    return
                fi
                ;;
            *.gz)
                if ! command -v gzip &> /dev/null; then
                    echo -e "${RED}错误：gzip 命令未安装！${NC}"
                    return
                fi
                # 对于单独的.gz文件，需要特殊处理
                if ! safe_read_confirm "解压.gz文件将覆盖原文件，是否继续" confirm; then
                    echo -e "${YELLOW}已取消${NC}"
                    return
                fi
                if [ "$confirm" != "y" ]; then
                    echo -e "${YELLOW}已取消${NC}"
                    return
                fi
                cmd=("gzip" "-d")
                ;;
            *.bz2)
                if ! command -v bzip2 &> /dev/null; then
                    echo -e "${RED}错误：bzip2 命令未安装！${NC}"
                    return
                fi
                if ! safe_read_confirm "解压.bz2文件将覆盖原文件，是否继续" confirm; then
                    echo -e "${YELLOW}已取消${NC}"
                    return
                fi
                if [ "$confirm" != "y" ]; then
                    echo -e "${YELLOW}已取消${NC}"
                    return
                fi
                cmd=("bzip2" "-d")
                ;;
            *.xz)
                if ! command -v xz &> /dev/null; then
                    echo -e "${RED}错误：xz 命令未安装！${NC}"
                    return
                fi
                if ! safe_read_confirm "解压.xz文件将覆盖原文件，是否继续" confirm; then
                    echo -e "${YELLOW}已取消${NC}"
                    return
                fi
                if [ "$confirm" != "y" ]; then
                    echo -e "${YELLOW}已取消${NC}"
                    return
                fi
                cmd=("xz" "-d")
                ;;
            *) 
                echo -e "${RED}不支持的压缩格式：$archive${NC}"
                return 
                ;;
        esac
        
        if ! safe_read "请输入解压目标目录（留空则当前目录）" dest "."; then
            return
        fi
        
        [[ -d $dest ]] || { echo -e "${YELLOW}目录不存在，将自动创建：${dest}${NC}"; mkdir -p "$dest"; }
        
        # 检查重复文件（仅对支持格式）
        echo -e "${YELLOW}检查重复文件中...${NC}"
        mapfile -t duplicates < <(check_duplicate_files "$archive" "$dest")
        
        if ((${#duplicates[@]} > 0)); then
            echo -e "${RED}发现以下重复文件：${NC}"
            for file in "${duplicates[@]}"; do
                echo -e "  ${RED}•${NC} $file"
            done
            
            while true; do
                echo -e "${YELLOW}请选择操作：${NC}"
                echo -e "  ${GREEN}1)${NC} 覆盖所有重复文件"
                echo -e "  ${GREEN}2)${NC} 跳过所有重复文件"
                echo -e "  ${GREEN}3)${NC} 逐个询问是否覆盖"
                echo -e "  ${GREEN}4)${NC} 取消解压"
                
                if ! safe_read_number "请选择 [1-4]" overwrite_choice 1 4; then
                    continue
                fi
                
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
                                echo -e "${YELLOW}注意：此格式不支持跳过重复文件，将取消解压${NC}"
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
                                if ! safe_read_confirm "是否覆盖文件 '$file'" answer; then
                                    continue
                                fi
                                case $answer in
                                    y)
                                        # 对于不支持跳过单个文件的格式，需要手动删除
                                        if [[ "$archive" == *.tar.gz || "$archive" == *.tar.xz || "$archive" == *.tar.bz2 || "$archive" == *.tar || "$archive" == *.7z ]]; then
                                            rm -f "$dest/$file"
                                        fi
                                        break
                                        ;;
                                    n)
                                        # 对于 zip，设置跳过此文件
                                        if [[ "$archive" == *.zip ]]; then
                                            exclude_file=$(mktemp)
                                            echo "$file" > "$exclude_file"
                                            cmd=("unzip" "-q" "-x" "@$exclude_file")
                                        elif [[ "$archive" == *.rar ]]; then
                                            echo -e "${YELLOW}注意：rar 格式不支持排除单个文件，将跳过所有重复文件${NC}"
                                            if [[ "${cmd[0]}" == "unrar" ]]; then
                                                cmd=("unrar" "x" "-o-" "-inul")
                                            else
                                                cmd=("rar" "x" "-o-" "-inul")
                                            fi
                                            break 2
                                        else
                                            echo -e "${YELLOW}注意：此格式不支持排除单个文件，将取消解压${NC}"
                                            return
                                        fi
                                        break
                                        ;;
                                    *)
                                        echo -e "${RED}请输入 y 或 n${NC}"
                                        ;;
                                esac
                            done
                        done
                        break
                        ;;
                    4)
                        echo -e "${YELLOW}已取消解压${NC}"
                        return
                        ;;
                    *)
                        echo -e "${RED}无效选择，请重试${NC}"
                        ;;
                esac
            done
        fi
        
        echo -e "${GREEN}正在解压 → ${dest}${NC}"
        
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
            echo -e "${GREEN}解压完成！${NC}"
        else
            echo -e "${RED}解压失败！${NC}"
        fi
        
        if ! safe_read_confirm "是否继续解压其他文件" continue_decompress; then
            break
        fi
        if [ "$continue_decompress" != "y" ]; then
            break
        fi
    done
}

# ================== Docker 管理函数 ==================

# 安装docker环境
install_add_docker() {
	echo -e "${gl_huang}正在安装docker环境...${gl_bai}"
	if  [ -f /etc/os-release ] && grep -q "Fedora" /etc/os-release; then
		install_add_docker_guanfang
	elif command -v dnf &>/dev/null; then
		dnf update -y
		dnf install -y yum-utils device-mapper-persistent-data lvm2
		rm -f /etc/yum.repos.d/docker*.repo > /dev/null
		country=$(curl -s ipinfo.io/country)
		arch=$(uname -m)
		if [ "$country" = "CN" ]; then
			curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo | tee /etc/yum.repos.d/docker-ce.repo > /dev/null
		else
			yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null
		fi
		dnf install -y docker-ce docker-ce-cli containerd.io
		install_add_docker_cn

	elif [ -f /etc/os-release ] && grep -q "Kali" /etc/os-release; then
		apt update
		apt upgrade -y
		apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
		rm -f /usr/share/keyrings/docker-archive-keyring.gpg
		local country=$(curl -s ipinfo.io/country)
		local arch=$(uname -m)
		if [ "$country" = "CN" ]; then
			if [ "$arch" = "x86_64" ]; then
				sed -i '/^deb \[arch=amd64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
				mkdir -p /etc/apt/keyrings
				curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
				echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
			elif [ "$arch" = "aarch64" ]; then
				sed -i '/^deb \[arch=arm64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
				mkdir -p /etc/apt/keyrings
				curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
				echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
			fi
		else
			if [ "$arch" = "x86_64" ]; then
				sed -i '/^deb \[arch=amd64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
				mkdir -p /etc/apt/keyrings
				curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
				echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
			elif [ "$arch" = "aarch64" ]; then
				sed -i '/^deb \[arch=arm64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
				mkdir -p /etc/apt/keyrings
				curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
				echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
			fi
		fi
		apt update
		apt install -y docker-ce docker-ce-cli containerd.io
		install_add_docker_cn


	elif command -v apt &>/dev/null || command -v yum &>/dev/null; then
		install_add_docker_guanfang
	else
		install docker docker-compose
		install_add_docker_cn

	fi
	sleep 2
}


install_docker() {
	if ! command -v docker &>/dev/null; then
		install_add_docker
	fi
}

# 安装函数
docker_install() {
    if [ $# -eq 0 ]; then
        echo "未提供软件包参数!"
        return 1
    fi

    for package in "$@"; do
        if ! command -v "$package" &>/dev/null; then
            echo -e "${YELLOW}正在安装 $package...${NC}"
            if command -v dnf &>/dev/null; then
                dnf -y update
                dnf install -y epel-release
                dnf install -y "$package"
            elif command -v yum &>/dev/null; then
                yum -y update
                yum install -y epel-release
                yum install -y "$package"
            elif command -v apt &>/dev/null; then
                apt update -y
                apt install -y "$package"
            elif command -v apk &>/dev/null; then
                apk update
                apk add "$package"
            elif command -v pacman &>/dev/null; then
                pacman -Syu --noconfirm
                pacman -S --noconfirm "$package"
            elif command -v zypper &>/dev/null; then
                zypper refresh
                zypper install -y "$package"
            elif command -v opkg &>/dev/null; then
                opkg update
                opkg install "$package"
            elif command -v pkg &>/dev/null; then
                pkg update
                pkg install -y "$package"
            else
                echo "未知的包管理器!"
                return 1
            fi
        fi
    done
}

# 卸载软件包函数
docker_remove_packages() {
    if [ $# -eq 0 ]; then
        echo "未提供软件包参数!"
        return 1
    fi

    for package in "$@"; do
        echo -e "${YELLOW}正在卸载 $package...${NC}"
        if command -v dnf &>/dev/null; then
            dnf remove -y "$package"
        elif command -v yum &>/dev/null; then
            yum remove -y "$package"
        elif command -v apt &>/dev/null; then
            apt purge -y "$package"
        elif command -v apk &>/dev/null; then
            apk del "$package"
        elif command -v pacman &>/dev/null; then
            pacman -Rns --noconfirm "$package"
        elif command -v zypper &>/dev/null; then
            zypper remove -y "$package"
        elif command -v opkg &>/dev/null; then
            opkg remove "$package"
        elif command -v pkg &>/dev/null; then
            pkg delete -y "$package"
        else
            echo "未知的包管理器!"
            return 1
        fi
    done
}

# 系统服务管理函数
docker_systemctl() {
    local COMMAND="$1"
    local SERVICE_NAME="$2"

    if command -v apk &>/dev/null; then
        service "$SERVICE_NAME" "$COMMAND"
    else
        /bin/systemctl "$COMMAND" "$SERVICE_NAME"
    fi
}

docker_restart() {
    docker_systemctl restart "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务已重启。"
    else
        echo "错误：重启 $1 服务失败。"
    fi
}

docker_start() {
    docker_systemctl start "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务已启动。"
    else
        echo "错误：启动 $1 服务失败。"
    fi
}

docker_stop() {
    docker_systemctl stop "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务已停止。"
    else
        echo "错误：停止 $1 服务失败。"
    fi
}

docker_status() {
    docker_systemctl status "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务状态已显示。"
    else
        echo "错误：无法显示 $1 服务状态。"
    fi
}

docker_enable() {
    local SERVICE_NAME="$1"
    if command -v apk &>/dev/null; then
        rc-update add "$SERVICE_NAME" default
    else
       /bin/systemctl enable "$SERVICE_NAME"
    fi

    echo "$SERVICE_NAME 已设置为开机自启。"
}

# 停止容器或杀死进程
docker_stop_containers_or_kill_process() {
    local port=$1
    local containers=$(docker ps --filter "publish=$port" --format "{{.ID}}" 2>/dev/null)

    if [ -n "$containers" ]; then
        docker stop $containers
    else
        docker_install lsof
        for pid in $(lsof -t -i:$port); do
            kill -9 $pid
        done
    fi
}

# 检查端口占用
docker_check_port() {
    docker_stop_containers_or_kill_process 80
    docker_stop_containers_or_kill_process 443
}

# 添加 Docker 中国镜像源
docker_install_add_docker_cn() {
    local country=$(curl -s ipinfo.io/country)
    if [ "$country" = "CN" ]; then
        cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.m.ixdev.cn",
    "https://hub.rat.dev",
    "https://dockerproxy.net",
    "https://docker-registry.nmqu.com",
    "https://docker.amingg.com",
    "https://docker.hlmirror.com",
    "https://hub1.nat.tf",
    "https://hub2.nat.tf",
    "https://hub3.nat.tf",
    "https://docker.m.daocloud.io",
    "https://docker.kejilion.pro",
    "https://docker.367231.xyz",
    "https://hub.1panel.dev",
    "https://dockerproxy.cool",
    "https://docker.apiba.cn",
    "https://proxy.vvvv.ee"
  ]
}
EOF
    fi

    docker_enable docker
    docker_start docker
    docker_restart docker
}

# 安装官方 Docker
docker_install_add_docker_guanfang() {
    local country=$(curl -s ipinfo.io/country)
    if [ "$country" = "CN" ]; then
        cd ~
        curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/install && chmod +x install
        sh install --mirror Aliyun
        rm -f install
    else
        curl -fsSL https://get.docker.com | sh
    fi
    docker_install_add_docker_cn
}

# 安装 Docker
docker_install_add_docker() {
    echo -e "${YELLOW}正在安装docker环境...${NC}"
    if  [ -f /etc/os-release ] && grep -q "Fedora" /etc/os-release; then
        docker_install_add_docker_guanfang
    elif command -v dnf &>/dev/null; then
        dnf update -y
        dnf install -y yum-utils device-mapper-persistent-data lvm2
        rm -f /etc/yum.repos.d/docker*.repo > /dev/null
        country=$(curl -s ipinfo.io/country)
        arch=$(uname -m)
        if [ "$country" = "CN" ]; then
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo | tee /etc/yum.repos.d/docker-ce.repo > /dev/null
        else
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null
        fi
        dnf install -y docker-ce docker-ce-cli containerd.io
        docker_install_add_docker_cn

    elif [ -f /etc/os-release ] && grep -q "Kali" /etc/os-release; then
        apt update
        apt upgrade -y
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        rm -f /usr/share/keyrings/docker-archive-keyring.gpg
        local country=$(curl -s ipinfo.io/country)
        local arch=$(uname -m)
        if [ "$country" = "CN" ]; then
            if [ "$arch" = "x86_64" ]; then
                sed -i '/^deb \[arch=amd64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                sed -i '/^deb \[arch=arm64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi
        else
            if [ "$arch" = "x86_64" ]; then
                sed -i '/^deb \[arch=amd64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                sed -i '/^deb \[arch=arm64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi
        fi
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io
        docker_install_add_docker_cn

    elif command -v apt &>/dev/null || command -v yum &>/dev/null; then
        docker_install_add_docker_guanfang
    else
        docker_install docker docker-compose
        docker_install_add_docker_cn

    fi
    sleep 2
}

# 检查并安装 Docker
docker_install_docker() {
    if ! command -v docker &>/dev/null; then
        docker_install_add_docker
    fi
}

install_add_docker_guanfang() {
local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	cd ~
	curl -sS -O ${gh_proxy}raw.githubusercontent.com/kejilion/docker/main/install && chmod +x install
	sh install --mirror Aliyun
	rm -f install
else
	curl -fsSL https://get.docker.com | sh
fi
install_add_docker_cn
}


install_add_docker_cn() {

local country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
	cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
	"https://docker.1ms.run",
	"https://docker.m.ixdev.cn",
	"https://hub.rat.dev",
	"https://dockerproxy.net",
	"https://docker-registry.nmqu.com",
	"https://docker.amingg.com",
	"https://docker.hlmirror.com",
	"https://hub1.nat.tf",
	"https://hub2.nat.tf",
	"https://hub3.nat.tf",
	"https://docker.m.daocloud.io",
	"https://docker.kejilion.pro",
	"https://docker.367231.xyz",
	"https://hub.1panel.dev",
	"https://dockerproxy.cool",
	"https://docker.apiba.cn",
	"https://proxy.vvvv.ee"
  ]
}
EOF
fi

systemctl enable docker
systemctl start docker
systemctl restart docker

}


# Docker 容器管理
docker_ps() {
    while true; do
        clear
        echo "Docker容器列表"
        docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        echo "容器操作"
        echo "------------------------"
        echo "1. 创建新的容器"
        echo "------------------------"
        echo "2. 启动指定容器             6. 启动所有容器"
        echo "3. 停止指定容器             7. 停止所有容器"
        echo "4. 删除指定容器             8. 删除所有容器"
        echo "5. 重启指定容器             9. 重启所有容器"
        echo "------------------------"
        echo "11. 进入指定容器           12. 查看容器日志"
        echo "13. 查看容器网络           14. 查看容器占用"
        echo "------------------------"
        echo "15. 开启容器端口访问       16. 关闭容器端口访问"
        echo "------------------------"
        echo -e "${RED}0. 返回上级菜单${NC}"
        echo "------------------------"
        if ! safe_read_number "请输入你的选择" sub_choice 0 16; then
            continue
        fi
        case $sub_choice in
            1)
                if safe_read "请输入创建命令: " dockername; then
                    $dockername
                fi
                ;;
            2)
                if safe_read "请输入容器名（多个容器名请用空格分隔）" dockername; then
                    docker start $dockername
                fi
                ;;
            3)
                if safe_read "请输入容器名（多个容器名请用空格分隔）" dockername; then
                    docker stop $dockername
                fi
                ;;
            4)
                if safe_read "请输入容器名（多个容器名请用空格分隔）" dockername; then
                    docker rm -f $dockername
                fi
                ;;
            5)
                if safe_read "请输入容器名（多个容器名请用空格分隔）" dockername; then
                    docker restart $dockername
                fi
                ;;
            6)
                docker start $(docker ps -a -q)
                ;;
            7)
                docker stop $(docker ps -q)
                ;;
            8)
                if safe_read_confirm "确定删除所有容器吗？(Y/N): " choice; then
                    case "$choice" in
                      [Yy])
                        docker rm -f $(docker ps -a -q)
                        ;;
                      [Nn])
                        ;;
                      *)
                        echo "无效的选择，请输入 Y 或 N。"
                        ;;
                    esac
                fi
                ;;
            9)
                docker restart $(docker ps -q)
                ;;
            11)
                if safe_read "请输入容器名: " dockername; then
                    docker exec -it $dockername /bin/sh
                fi
                ;;
            12)
                if safe_read "请输入容器名: " dockername; then
                    docker logs $dockername
                fi
                ;;
            13)
                echo ""
                container_ids=$(docker ps -q)
                echo "------------------------------------------------------------"
                printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"
                for container_id in $container_ids; do
                    local container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")
                    local container_name=$(echo "$container_info" | awk '{print $1}')
                    local network_info=$(echo "$container_info" | cut -d' ' -f2-)
                    while IFS= read -r line; do
                        local network_name=$(echo "$line" | awk '{print $1}')
                        local ip_address=$(echo "$line" | awk '{print $2}')
                        printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
                    done <<< "$network_info"
                done
                ;;
            14)
                docker stats --no-stream
                ;;
            15)
                if safe_read "请输入容器名: " docker_name; then
                    echo "允许容器端口访问功能"
                    echo -e "${YELLOW}注意：此功能需要具体实现${NC}"
                fi
                ;;
            16)
                if safe_read "请输入容器名: " docker_name; then
                    echo "阻止容器端口访问功能"
                    echo -e "${YELLOW}注意：此功能需要具体实现${NC}"
                fi
                ;;
            *)
                break
                ;;
        esac
        echo "按任意键继续..."
        read -n 1 -s -r -p ""
        echo ""
        clear
    done
}

# Docker 镜像管理
docker_image() {
    while true; do
        clear
        echo "Docker镜像列表"
        docker image ls
        echo ""
        echo "镜像操作"
        echo "------------------------"
        echo "1. 获取指定镜像             3. 删除指定镜像"
        echo "2. 更新指定镜像             4. 删除所有镜像"
        echo "------------------------"
        echo -e "${RED}0. 返回上级菜单${NC}"
        echo "------------------------"
        if ! safe_read_number "请输入你的选择" sub_choice 0 4; then
            continue
        fi
        case $sub_choice in
            1)
                if safe_read "请输入镜像名（多个镜像名请用空格分隔）" imagenames; then
                    for name in $imagenames; do
                        echo -e "${YELLOW}正在获取镜像: $name${NC}"
                        docker pull $name
                    done
                fi
                ;;
            2)
                if safe_read "请输入镜像名（多个镜像名请用空格分隔）" imagenames; then
                    for name in $imagenames; do
                        echo -e "${YELLOW}正在更新镜像: $name${NC}"
                        docker pull $name
                    done
                fi
                ;;
            3)
                if safe_read "请输入镜像名（多个镜像名请用空格分隔）" imagenames; then
                    for name in $imagenames; do
                        docker rmi -f $name
                    done
                fi
                ;;
            4)
                if safe_read_confirm "确定删除所有镜像吗？(Y/N)" choice; then
                    case "$choice" in
                      [Yy])
                        docker rmi -f $(docker images -q)
                        ;;
                      [Nn])
                        ;;
                      *)
                        echo "无效的选择，请输入 Y 或 N。"
                        ;;
                    esac
                fi
                ;;
            *)
                break
                ;;
        esac
        echo "按任意键继续..."
        read -n 1 -s -r -p ""
        echo ""
        clear
    done
}

# Docker IPv6 支持
docker_ipv6_on() {
    docker_install jq

    local CONFIG_FILE="/etc/docker/daemon.json"
    local REQUIRED_IPV6_CONFIG='{"ipv6": true, "fixed-cidr-v6": "2001:db8:1::/64"}'

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "$REQUIRED_IPV6_CONFIG" | jq . > "$CONFIG_FILE"
        docker_restart docker
    else
        local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")
        local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq '.ipv6 // false')

        if [[ "$CURRENT_IPV6" == "false" ]]; then
            UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {ipv6: true, "fixed-cidr-v6": "2001:db8:1::/64"}')
        else
            UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq '. + {"fixed-cidr-v6": "2001:db8:1::/64"}')
        fi

        if [[ "$ORIGINAL_CONFIG" == "$UPDATED_CONFIG" ]]; then
            echo -e "${YELLOW}当前已开启ipv6访问${NC}"
        else
            echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
            docker_restart docker
        fi
    fi
}

docker_ipv6_off() {
    docker_install jq

    local CONFIG_FILE="/etc/docker/daemon.json"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}配置文件不存在${NC}"
        return
    fi

    local ORIGINAL_CONFIG=$(<"$CONFIG_FILE")
    local UPDATED_CONFIG=$(echo "$ORIGINAL_CONFIG" | jq 'del(.["fixed-cidr-v6"]) | .ipv6 = false')
    local CURRENT_IPV6=$(echo "$ORIGINAL_CONFIG" | jq -r '.ipv6 // false')

    if [[ "$CURRENT_IPV6" == "false" ]]; then
        echo -e "${YELLOW}当前已关闭ipv6访问${NC}"
    else
        echo "$UPDATED_CONFIG" | jq . > "$CONFIG_FILE"
        docker_restart docker
        echo -e "${YELLOW}已成功关闭ipv6访问${NC}"
    fi
}

docker_network() {
    while true; do
      clear
      echo "Docker网络列表"
      echo "------------------------------------------------------------"
      docker network ls
      echo ""

      echo "------------------------------------------------------------"
      container_ids=$(docker ps -q)
      printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"

      for container_id in $container_ids; do
          local container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

          local container_name=$(echo "$container_info" | awk '{print $1}')
          local network_info=$(echo "$container_info" | cut -d' ' -f2-)

          while IFS= read -r line; do
              local network_name=$(echo "$line" | awk '{print $1}')
              local ip_address=$(echo "$line" | awk '{print $2}')

              printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
          done <<< "$network_info"
      done

      echo ""
      echo "网络操作"
      echo "------------------------"
      echo "1. 创建网络"
      echo "2. 加入网络"
      echo "3. 退出网络"
      echo "4. 删除网络"
      echo "------------------------"
      echo -e "${RED}0. 返回上级菜单${NC}"
      echo "------------------------"
      if ! safe_read_number "请输入你的选择: " sub_choice 0 4; then
          continue
      fi

      case $sub_choice in
          1)
              if safe_read "设置新网络名: " dockernetwork; then
                  docker network create $dockernetwork
              fi
              ;;
          2)
              if safe_read "加入网络名: " dockernetwork; then
                  if safe_read "那些容器加入该网络（多个容器名请用空格分隔）: " dockernames; then
                      for dockername in $dockernames; do
                          docker network connect $dockernetwork $dockername
                      done
                  fi
              fi
              ;;
          3)
              if safe_read "退出网络名: " dockernetwork; then
                  if safe_read "那些容器退出该网络（多个容器名请用空格分隔）: " dockernames; then
                      for dockername in $dockernames; do
                          docker network disconnect $dockernetwork $dockername
                      done
                  fi
              fi
              ;;
          4)
              if safe_read "请输入要删除的网络名: " dockernetwork; then
                  docker network rm $dockernetwork
              fi
              ;;
          *)
              break  # 跳出循环，退出菜单
              ;;
      esac
    done
}

docker_service_status() {
      clear
      local container_count=$(docker ps -a -q 2>/dev/null | wc -l)
      local image_count=$(docker images -q 2>/dev/null | wc -l)
      local network_count=$(docker network ls -q 2>/dev/null | wc -l)
      local volume_count=$(docker volume ls -q 2>/dev/null | wc -l)

      echo "Docker版本"
      docker -v
      docker compose version

      echo ""
      echo -e "Docker镜像: ${GREEN}$image_count${NC} "
      docker image ls
      echo ""
      echo -e "Docker容器: ${GREEN}$container_count${NC}"
      docker ps -a
      echo ""
      echo -e "Docker卷: ${GREEN}$volume_count${NC}"
      docker volume ls
      echo ""
      echo -e "Docker网络: ${GREEN}$network_count${NC}"
      docker network ls
      echo ""
}

docker_disk() {
      while true; do
          clear
          echo "Docker卷列表"
          docker volume ls
          echo ""
          echo "卷操作"
          echo "------------------------"
          echo "1. 创建新卷"
          echo "2. 删除指定卷"
          echo "3. 删除所有卷"
          echo "------------------------"
          echo "0. 返回上一级选单"
          echo "------------------------"
          if ! safe_read_number "请输入你的选择: " sub_choice 0 3; then
              continue
          fi

          case $sub_choice in
              1)
                  if safe_read "设置新卷名: " dockerjuan; then
                      docker volume create $dockerjuan
                  fi
                  ;;
              2)
                  if safe_read "输入删除卷名（多个卷名请用空格分隔）: " dockerjuans; then
                      for dockerjuan in $dockerjuans; do
                          docker volume rm $dockerjuan
                      done
                  fi
                  ;;
               3)
                  if safe_read_confirm "确定删除所有未使用的卷吗？(Y/N): " choice; then
                    case "$choice" in
                      [Yy])
                        docker volume prune -f
                        ;;
                      [Nn])
                        ;;
                      *)
                        echo "无效的选择，请输入 Y 或 N。"
                        ;;
                    esac
                  fi
                  ;;
              *)
                  break  # 跳出循环，退出菜单
                  ;;
          esac
      done
}

docker_clear() {
    clear
    
    echo -e "${YELLOW}=== Docker 清理预览 ===${NC}"
    echo ""
    
    # 显示将要清理的内容
    echo -e "${CYAN}将要清理以下内容：${NC}"
    echo "----------------------------------------"
    
    # 停止的容器
    stopped_containers=$(docker ps -a -f status=exited -f status=created -q | wc -l)
    if [ "$stopped_containers" -gt 0 ]; then
        echo -e "${YELLOW}● 停止的容器 ($stopped_containers 个):${NC}"
        docker ps -a -f status=exited -f status=created --format "  - {{.Names}} ({{.ID}})"
    else
        echo -e "${GREEN}● 停止的容器: 无${NC}"
    fi
    echo ""
    
    # 悬空镜像
    dangling_images=$(docker images -f "dangling=true" -q | wc -l)
    if [ "$dangling_images" -gt 0 ]; then
        echo -e "${YELLOW}● 悬空镜像 ($dangling_images 个):${NC}"
        docker images -f "dangling=true" --format "  - {{.Repository}}:{{.Tag}} ({{.ID}})"
    else
        echo -e "${GREEN}● 悬空镜像: 无${NC}"
    fi
    echo ""
    
    # 未被使用的镜像
    unused_images=$(docker images -q | wc -l)
    if [ "$unused_images" -gt 0 ]; then
        echo -e "${YELLOW}● 未被使用的镜像 ($unused_images 个):${NC}"
        echo "  (所有未被容器使用的镜像)"
    else
        echo -e "${GREEN}● 未被使用的镜像: 无${NC}"
    fi
    echo ""
    
    # 未被使用的卷
    unused_volumes=$(docker volume ls -q -f "dangling=true" | wc -l)
    if [ "$unused_volumes" -gt 0 ]; then
        echo -e "${YELLOW}● 未被使用的卷 ($unused_volumes 个):${NC}"
        docker volume ls -q -f "dangling=true" | head -5 | while read volume; do
            echo "  - $volume"
        done
        if [ "$unused_volumes" -gt 5 ]; then
            echo "  - ... 还有 $(($unused_volumes - 5)) 个"
        fi
    else
        echo -e "${GREEN}● 未被使用的卷: 无${NC}"
    fi
    echo ""
    
    # 未被使用的网络（除了默认网络）
    unused_networks=$(docker network ls -q --filter type=custom | wc -l)
    if [ "$unused_networks" -gt 0 ]; then
        echo -e "${YELLOW}● 未被使用的网络 ($unused_networks 个):${NC}"
        docker network ls --filter type=custom --format "  - {{.Name}} ({{.Driver}})" | head -3
        if [ "$unused_networks" -gt 3 ]; then
            echo "  - ... 还有 $(($unused_networks - 3)) 个"
        fi
    else
        echo -e "${GREEN}● 未被使用的网络: 无${NC}"
    fi
    echo ""
    
    echo "----------------------------------------"
    
    # 获取当前磁盘使用情况
    echo -e "${CYAN}当前 Docker 磁盘使用情况:${NC}"
    docker system df
    echo ""
    
    # 确认清理
    if ! safe_read_confirm "确定要执行清理吗" confirm_clean; then
        return
    fi
    
    if [ "$confirm_clean" = "y" ]; then
        echo ""
        echo -e "${YELLOW}正在执行 Docker 清理...${NC}"
        echo "----------------------------------------"
        
        # 执行清理并捕获输出
        cleanup_output=$(docker system prune -af --volumes 2>&1)
        
        # 显示清理结果
        echo -e "${GREEN}=== 清理完成 ===${NC}"
        echo ""
        echo "$cleanup_output"
        echo ""
        
        # 显示清理后的磁盘使用情况
        echo -e "${CYAN}清理后 Docker 磁盘使用情况:${NC}"
        docker system df
        
        echo ""
        echo -e "${GREEN}✅ Docker 清理完成${NC}"
    else
        echo -e "${YELLOW}已取消清理操作${NC}"
    fi
}

# 备份/迁移/还原Docker环境
docker_ssh_migration() {

	GREEN='\033[0;32m'
	RED='\033[0;31m'
	YELLOW='\033[1;33m'
	BLUE='\033[0;36m'
	NC='\033[0m'

	is_compose_container() {
		local container=$1
		docker inspect "$container" | jq -e '.[0].Config.Labels["com.docker.compose.project"]' >/dev/null 2>&1
	}

	list_backups() {
		local BACKUP_ROOT="/tmp"
		echo -e "${BLUE}当前备份列表:${NC}"
		ls -1dt ${BACKUP_ROOT}/docker_backup_* 2>/dev/null || echo "无备份"
	}



	# ----------------------------
	# 备份
	# ----------------------------
	backup_docker() {
		send_stats "Docker备份"

		echo -e "${YELLOW}正在备份 Docker 容器...${NC}"
		docker ps --format '{{.Names}}'
		read -e -p  "请输入要备份的容器名（多个空格分隔，回车备份全部运行中容器）: " containers

		install tar jq gzip
		install_docker

		local BACKUP_ROOT="/tmp"
		local DATE_STR=$(date +%Y%m%d_%H%M%S)
		local TARGET_CONTAINERS=()
		if [ -z "$containers" ]; then
			mapfile -t TARGET_CONTAINERS < <(docker ps --format '{{.Names}}')
		else
			read -ra TARGET_CONTAINERS <<< "$containers"
		fi
		[[ ${#TARGET_CONTAINERS[@]} -eq 0 ]] && { echo -e "${RED}没有找到容器${NC}"; return; }

		local BACKUP_DIR="${BACKUP_ROOT}/docker_backup_${DATE_STR}"
		mkdir -p "$BACKUP_DIR"

		local RESTORE_SCRIPT="${BACKUP_DIR}/docker_restore.sh"
		echo "#!/bin/bash" > "$RESTORE_SCRIPT"
		echo "set -e" >> "$RESTORE_SCRIPT"
		echo "# 自动生成的还原脚本" >> "$RESTORE_SCRIPT"

		# 记录已打包过的 Compose 项目路径，避免重复打包
		declare -A PACKED_COMPOSE_PATHS=()

		for c in "${TARGET_CONTAINERS[@]}"; do
			echo -e "${GREEN}备份容器: $c${NC}"
			local inspect_file="${BACKUP_DIR}/${c}_inspect.json"
			docker inspect "$c" > "$inspect_file"

			if is_compose_container "$c"; then
				echo -e "${BLUE}检测到 $c 是 docker-compose 容器${NC}"
				local project_dir=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project.working_dir"] // empty')
				local project_name=$(docker inspect "$c" | jq -r '.[0].Config.Labels["com.docker.compose.project"] // empty')

				if [ -z "$project_dir" ]; then
					read -e -p  "未检测到 compose 目录，请手动输入路径: " project_dir
				fi

				# 如果该 Compose 项目已经打包过，跳过
				if [[ -n "${PACKED_COMPOSE_PATHS[$project_dir]}" ]]; then
					echo -e "${YELLOW}Compose 项目 [$project_name] 已备份过，跳过重复打包...${NC}"
					continue
				fi

				if [ -f "$project_dir/docker-compose.yml" ]; then
					echo "compose" > "${BACKUP_DIR}/backup_type_${project_name}"
					echo "$project_dir" > "${BACKUP_DIR}/compose_path_${project_name}.txt"
					tar -czf "${BACKUP_DIR}/compose_project_${project_name}.tar.gz" -C "$project_dir" .
					echo "# docker-compose 恢复: $project_name" >> "$RESTORE_SCRIPT"
					echo "cd \"$project_dir\" && docker compose up -d" >> "$RESTORE_SCRIPT"
					PACKED_COMPOSE_PATHS["$project_dir"]=1
					echo -e "${GREEN}Compose 项目 [$project_name] 已打包: ${project_dir}${NC}"
				else
					echo -e "${RED}未找到 docker-compose.yml，跳过此容器...${NC}"
				fi
			else
				# 普通容器备份卷
				local VOL_PATHS
				VOL_PATHS=$(docker inspect "$c" --format '{{range .Mounts}}{{.Source}} {{end}}')
				for path in $VOL_PATHS; do
					echo "打包卷: $path"
					tar -czpf "${BACKUP_DIR}/${c}_$(basename $path).tar.gz" -C / "$(echo $path | sed 's/^\///')"
				done

				# 端口
				local PORT_ARGS=""
				mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[] | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$inspect_file" 2>/dev/null)
				for p in "${PORTS[@]}"; do PORT_ARGS+="-p $p "; done

				# 环境变量
				local ENV_VARS=""
				mapfile -t ENVS < <(jq -r '.[0].Config.Env[] | @sh' "$inspect_file")
				for e in "${ENVS[@]}"; do ENV_VARS+="-e $e "; done

				# 卷映射
				local VOL_ARGS=""
				for path in $VOL_PATHS; do VOL_ARGS+="-v $path:$path "; done

				# 镜像
				local IMAGE
				IMAGE=$(jq -r '.[0].Config.Image' "$inspect_file")

				echo -e "\n# 还原容器: $c" >> "$RESTORE_SCRIPT"
				echo "docker run -d --name $c $PORT_ARGS $VOL_ARGS $ENV_VARS $IMAGE" >> "$RESTORE_SCRIPT"
			fi
		done


		# 备份 /home/docker 下的所有文件（不含子目录）
		if [ -d "/home/docker" ]; then
			echo -e "${BLUE}备份 /home/docker 下的文件...${NC}"
			find /home/docker -maxdepth 1 -type f | tar -czf "${BACKUP_DIR}/home_docker_files.tar.gz" -T -
			echo -e "${GREEN}/home/docker 下的文件已打包到: ${BACKUP_DIR}/home_docker_files.tar.gz${NC}"
		fi

		chmod +x "$RESTORE_SCRIPT"
		echo -e "${GREEN}备份完成: ${BACKUP_DIR}${NC}"
		echo -e "${GREEN}可用还原脚本: ${RESTORE_SCRIPT}${NC}"


	}

	# ----------------------------
	# 还原
	# ----------------------------
	restore_docker() {

		send_stats "Docker还原"
		read -e -p  "请输入要还原的备份目录: " BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${RED}备份目录不存在${NC}"; return; }

		echo -e "${BLUE}开始执行还原操作...${NC}"

		install tar jq gzip
		install_docker

		# --------- 优先还原 Compose 项目 ---------
		for f in "$BACKUP_DIR"/backup_type_*; do
			[[ ! -f "$f" ]] && continue
			if grep -q "compose" "$f"; then
				project_name=$(basename "$f" | sed 's/backup_type_//')
				path_file="$BACKUP_DIR/compose_path_${project_name}.txt"
				[[ -f "$path_file" ]] && original_path=$(cat "$path_file") || original_path=""
				[[ -z "$original_path" ]] && read -e -p  "未找到原始路径，请输入还原目录路径: " original_path

				# 检查该 compose 项目的容器是否已经在运行
				running_count=$(docker ps --filter "label=com.docker.compose.project=$project_name" --format '{{.Names}}' | wc -l)
				if [[ "$running_count" -gt 0 ]]; then
					echo -e "${YELLOW}Compose 项目 [$project_name] 已有容器在运行，跳过还原...${NC}"
					continue
				fi

				read -e -p  "确认还原 Compose 项目 [$project_name] 到路径 [$original_path] ? (y/n): " confirm
				[[ "$confirm" != "y" ]] && read -e -p  "请输入新的还原路径: " original_path

				mkdir -p "$original_path"
				tar -xzf "$BACKUP_DIR/compose_project_${project_name}.tar.gz" -C "$original_path"
				echo -e "${GREEN}Compose 项目 [$project_name] 已解压到: $original_path${NC}"

				cd "$original_path" || return
				docker compose down || true
				docker compose up -d
				echo -e "${GREEN}Compose 项目 [$project_name] 还原完成！${NC}"
			fi
		done

		# --------- 继续还原普通容器 ---------
		echo -e "${BLUE}检查并还原普通 Docker 容器...${NC}"
		local has_container=false
		for json in "$BACKUP_DIR"/*_inspect.json; do
			[[ ! -f "$json" ]] && continue
			has_container=true
			container=$(basename "$json" | sed 's/_inspect.json//')
			echo -e "${GREEN}处理容器: $container${NC}"

			# 检查容器是否已经存在且正在运行
			if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${YELLOW}容器 [$container] 已在运行，跳过还原...${NC}"
				continue
			fi

			IMAGE=$(jq -r '.[0].Config.Image' "$json")
			[[ -z "$IMAGE" || "$IMAGE" == "null" ]] && { echo -e "${RED}未找到镜像信息，跳过: $container${NC}"; continue; }

			# 端口映射
			PORT_ARGS=""
			mapfile -t PORTS < <(jq -r '.[0].HostConfig.PortBindings | to_entries[]? | "\(.value[0].HostPort):\(.key | split("/")[0])"' "$json")
			for p in "${PORTS[@]}"; do
				[[ -n "$p" ]] && PORT_ARGS="$PORT_ARGS -p $p"
			done

			# 环境变量
			ENV_ARGS=""
			mapfile -t ENVS < <(jq -r '.[0].Config.Env[]' "$json")
			for e in "${ENVS[@]}"; do
				ENV_ARGS="$ENV_ARGS -e \"$e\""
			done

			# 卷映射 + 卷数据恢复
			VOL_ARGS=""
			mapfile -t VOLS < <(jq -r '.[0].Mounts[] | "\(.Source):\(.Destination)"' "$json")
			for v in "${VOLS[@]}"; do
				VOL_SRC=$(echo "$v" | cut -d':' -f1)
				VOL_DST=$(echo "$v" | cut -d':' -f2)
				mkdir -p "$VOL_SRC"
				VOL_ARGS="$VOL_ARGS -v $VOL_SRC:$VOL_DST"

				VOL_FILE="$BACKUP_DIR/${container}_$(basename $VOL_SRC).tar.gz"
				if [[ -f "$VOL_FILE" ]]; then
					echo "恢复卷数据: $VOL_SRC"
					tar -xzf "$VOL_FILE" -C /
				fi
			done

			# 删除已存在但未运行的容器
			if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
				echo -e "${YELLOW}容器 [$container] 存在但未运行，删除旧容器...${NC}"
				docker rm -f "$container"
			fi

			# 启动容器
			echo "执行还原命令: docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
			eval "docker run -d --name \"$container\" $PORT_ARGS $VOL_ARGS $ENV_ARGS \"$IMAGE\""
		done

		[[ "$has_container" == false ]] && echo -e "${YELLOW}未找到普通容器的备份信息${NC}"

		# 还原 /home/docker 下的文件
		if [ -f "$BACKUP_DIR/home_docker_files.tar.gz" ]; then
			echo -e "${BLUE}正在还原 /home/docker 下的文件...${NC}"
			mkdir -p /home/docker
			tar -xzf "$BACKUP_DIR/home_docker_files.tar.gz" -C /
			echo -e "${GREEN}/home/docker 下的文件已还原完成${NC}"
		else
			echo -e "${YELLOW}未找到 /home/docker 下文件的备份，跳过...${NC}"
		fi


	}


	# ----------------------------
	# 迁移
	# ----------------------------
	migrate_docker() {
		send_stats "Docker迁移"
		install jq
		read -e -p  "请输入要迁移的备份目录: " BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${RED}备份目录不存在${NC}"; return; }

		read -e -p  "目标服务器IP: " TARGET_IP
		read -e -p  "目标服务器SSH用户名: " TARGET_USER
		read -e -p "目标服务器SSH端口 [默认22]: " TARGET_PORT
		local TARGET_PORT=${TARGET_PORT:-22}

		local LATEST_TAR="$BACKUP_DIR"

		echo -e "${YELLOW}传输备份中...${NC}"
		if [[ -z "$TARGET_PASS" ]]; then
			# 使用密钥登录
			scp -P "$TARGET_PORT" -o StrictHostKeyChecking=no -r "$LATEST_TAR" "$TARGET_USER@$TARGET_IP:/tmp/"
		fi

	}

	# ----------------------------
	# 删除备份
	# ----------------------------
	delete_backup() {
		send_stats "Docker备份文件删除"
		read -e -p  "请输入要删除的备份目录: " BACKUP_DIR
		[[ ! -d "$BACKUP_DIR" ]] && { echo -e "${RED}备份目录不存在${NC}"; return; }
		rm -rf "$BACKUP_DIR"
		echo -e "${GREEN}已删除备份: ${BACKUP_DIR}${NC}"
	}
}

# 卸载Docker环境
docker_remove() {
    clear
    echo -e "${RED}=== Docker 环境卸载 ===${NC}"
    echo ""
    
    # 显示当前Docker状态
    echo -e "${YELLOW}当前 Docker 状态:${NC}"
    if command -v docker &>/dev/null; then
        docker -v
        echo ""
        echo -e "${YELLOW}当前运行的容器:${NC}"
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        echo ""
        echo -e "${YELLOW}当前镜像:${NC}"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    else
        echo -e "${RED}Docker 未安装${NC}"
    fi
    echo ""
    
    # 警告信息
    echo -e "${RED}⚠️  警告: 此操作将永久删除所有Docker数据！${NC}"
    echo -e "${RED}包括:${NC}"
    echo -e "${RED}  • 所有容器、镜像、网络、数据卷${NC}"
    echo -e "${RED}  • Docker引擎和所有相关软件包${NC}"
    echo -e "${RED}  • Docker配置文件${NC}"
    echo ""
    
    # 二次确认
    if ! safe_read_confirm "确定要卸载Docker环境吗？此操作不可恢复！" confirm_uninstall; then
        return
    fi
    
    if [ "$confirm_uninstall" != "y" ]; then
        echo -e "${YELLOW}已取消卸载操作${NC}"
        return
    fi
    
    echo ""
    echo -e "${YELLOW}开始卸载 Docker 环境...${NC}"
    echo "----------------------------------------"
    
    # 停止并删除所有容器
    echo -e "${YELLOW}1. 停止并删除所有容器...${NC}"
    if command -v docker &>/dev/null; then
        docker ps -a -q | xargs -r docker rm -f 2>/dev/null || true
        echo -e "${GREEN}✓ 所有容器已删除${NC}"
    fi
    
    # 删除所有镜像
    echo -e "${YELLOW}2. 删除所有镜像...${NC}"
    if command -v docker &>/dev/null; then
        docker images -q | xargs -r docker rmi -f 2>/dev/null || true
        echo -e "${GREEN}✓ 所有镜像已删除${NC}"
    fi
    
    # 清理网络和数据卷
    echo -e "${YELLOW}3. 清理网络和数据卷...${NC}"
    if command -v docker &>/dev/null; then
        docker network prune -f 2>/dev/null || true
        docker volume prune -f 2>/dev/null || true
        echo -e "${GREEN}✓ 网络和数据卷已清理${NC}"
    fi
    
    # 停止Docker服务
    echo -e "${YELLOW}4. 停止Docker服务...${NC}"
    if systemctl is-active --quiet docker 2>/dev/null; then
        systemctl stop docker
        echo -e "${GREEN}✓ Docker服务已停止${NC}"
    fi
    
    # 卸载Docker软件包
    echo -e "${YELLOW}5. 卸载Docker软件包...${NC}"
    
    # 根据系统类型卸载相应的软件包
    if command -v dnf &>/dev/null; then
        # RedHat/CentOS/Fedora
        dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    elif command -v yum &>/dev/null; then
        # CentOS/RHEL
        yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif command -v apt &>/dev/null; then
        # Debian/Ubuntu
        apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        apt autoremove -y
    elif command -v apk &>/dev/null; then
        # Alpine
        apk del docker docker-compose containerd
    elif command -v pacman &>/dev/null; then
        # Arch Linux
        pacman -Rns --noconfirm docker docker-compose containerd
    elif command -v zypper &>/dev/null; then
        # openSUSE
        zypper remove -y docker docker-compose containerd
    else
        echo -e "${YELLOW}未知的包管理器，跳过软件包卸载${NC}"
    fi
    echo -e "${GREEN}✓ Docker软件包已卸载${NC}"
    
    # 删除配置文件和数据
    echo -e "${YELLOW}6. 删除配置文件和数据...${NC}"
    rm -rf /etc/docker
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm -f /etc/systemd/system/docker.service
    rm -f /etc/systemd/system/docker.socket
    rm -rf ~/.docker
    echo -e "${GREEN}✓ 配置文件和数据已删除${NC}"
    
    # 重新加载systemd
    echo -e "${YELLOW}7. 重新加载systemd...${NC}"
    systemctl daemon-reload 2>/dev/null || true
    
    # 清理命令缓存
    echo -e "${YELLOW}8. 清理命令缓存...${NC}"
    hash -r
    
    echo "----------------------------------------"
    echo -e "${GREEN}✅ Docker 环境卸载完成${NC}"
    echo ""
    echo -e "${YELLOW}如需重新安装Docker，请使用菜单中的安装选项${NC}"
}

# Docker 管理主菜单
show_docker_menu() {
    while true; do
        clear
        echo "========================================"
        echo "            Docker 管理"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo "----------------------------------------"
        echo -e "${YELLOW}请选择要执行的操作：${NC}"
        echo -e "${CYAN}1. 安装Docker环境${NC}"
        echo -e "${CYAN}2. 查看Docker状态${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}3. Docker容器管理${NC}"
        echo -e "${CYAN}4. Docker镜像管理${NC}"
        echo -e "${CYAN}5. Docker网络管理${NC}"
        echo -e "${CYAN}6. Docker卷管理${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}7. 清理无用的docker容器和镜像网络数据卷${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}8. 更换Docker源${NC}"
        echo -e "${CYAN}9. 编辑daemon.json文件${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}11. 开启 IPv6 支持${NC}"
        echo -e "${CYAN}12. 关闭 IPv6 支持${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}19. 备份/迁移/还原Docker环境${NC}"
        echo -e "${RED}20. 卸载Docker环境${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入你的选择" main_choice 0 20; then
            continue
        fi

        case $main_choice in
            1)
                clear
                install_add_docker
                ;;
            2)
                docker_service_status
                ;;
            3)
                docker_ps
                ;;
            4)
                docker_image
                ;;
            5)
                docker_network
                ;;
            6)
                docker_disk
                ;;
            7)
                docker_clear
                ;;
            8)
              clear
              bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
              ;;
            9)
              clear
              mkdir -p /etc/docker && nano /etc/docker/daemon.json
              restart docker
              ;;
            11)
                docker_ipv6_on
                ;;
            12)
                docker_ipv6_off
                ;;
            19)
                docker_ssh_migration
                ;;
            20)
                docker_remove
                ;;
            0)
                break
                ;;
            *)
                echo "无效的选择，请重新输入"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 函数：显示 Linux 常用脚本 子菜单
show_script_menu() {
    while true; do
        clear
        echo -e "${GREEN}"
        echo "========================================"
        echo "           Linux 常用脚本"
        echo "========================================"
        echo -e "${YELLOW}当前工作目录: $(pwd)${NC}"
        echo -e "${BLUE}内网IP: $(get_internal_ip)${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}1. 配置 SSH 服务${NC}"
        echo -e "${CYAN}2. 配置 Samba 服务${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}3. 科技 Lion 脚本${NC}"
        echo -e "${CYAN}4. PVE 优化脚本${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}5. Linux开机信息显示${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${CYAN}8. Linux系统清理${NC}"
        echo -e "${CYAN}------------------------${NC}"
        echo -e "${RED}0. 返回主菜单${NC}"
        echo "========================================"
        
        if ! safe_read_number "请输入选择" choice 0 8; then
            continue
        fi
        
        case $choice in
            1)
                echo -e "${YELLOW}执行命令: bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssh/setup-ssh.sh)${NC}"
                echo "----------------------------------------"
                bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssh/setup-ssh.sh)
                echo "----------------------------------------"
                ;;
            2)
                echo -e "${YELLOW}执行命令: bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/samba/samba_setup.sh)${NC}"
                echo "----------------------------------------"
                bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/samba/samba_setup.sh)
                echo "----------------------------------------"
                ;;

            3)
                echo -e "${YELLOW}执行命令: bash <(curl -sL kejilion.sh)${NC}"
                echo "----------------------------------------"
                bash <(curl -sL kejilion.sh)
                echo "----------------------------------------"
                ;;
            4)
                echo -e "${YELLOW}执行命令: wget  -q  -O  /root/pve_source.tar.gz 'https://gitee.com/meimolihan/script/raw/master/sh/pve/pve_source.tar.gz' &&  tar  zxvf  /root/pve_source.tar.gz  &&  /root/./pve_source${NC}"
                echo "----------------------------------------"
wget  -q  -O  /root/pve_source.tar.gz 'https://gitee.com/meimolihan/script/raw/master/sh/pve/pve_source.tar.gz' &&  tar  zxvf  /root/pve_source.tar.gz  &&  /root/./pve_source
                echo "----------------------------------------"
                ;;
            5)
                echo -e "${YELLOW}执行命令: bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/check.sh)${NC}"
                echo "----------------------------------------"
                bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/check.sh)
                echo "----------------------------------------"
                ;;
            6)
                echo -e "${YELLOW}执行命令: sudo systemctl status nginx${NC}"
                echo "----------------------------------------"
                
                echo "----------------------------------------"
                ;;
            7)
                echo -e "${YELLOW}执行命令: cd /etc/nginx/conf.d && ls${NC}"
                echo "----------------------------------------"
                
                echo "----------------------------------------"
                ;;
            8)
                echo -e "${YELLOW}执行命令: bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/clean_system.sh)${NC}"
                echo "----------------------------------------"
                bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/clean_system.sh)
                echo "----------------------------------------"
                ;;

            0)
                break
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -n 1 -s
    done
}

# 主程序
main() {
    # 获取默认菜单
    local default_menu=$(get_default_menu)
    local ip=$(get_internal_ip)

# ================== 欢迎语 ==================
echo -e "\033[1;35m"
cat <<'WELCOME'
                 _            __            
                | |          / _|           
 _ __ ___   ___ | |__  _   _| |_ __ _ _ __  
| '_ ` _ \ / _ \| '_ \| | | |  _/ _` | '_ \ 
| | | | | | (_) | |_) | |_| | || (_| | | | |
|_| |_| |_|\___/|_.__/ \__,_|_| \__,_|_| |_|

WELCOME
echo -e "\033[0m"
# ============================================
    
    case "$default_menu" in
        "pve") 
            echo -e "${YELLOW}根据IP地址，自动进入 PVE 命令合集${NC}"
            echo "----------------------------------------"
            echo -e "${CYAN}2秒后自动进入 PVE 菜单...${NC}"
            echo -e "${CYAN}按任意键跳过等待并选择菜单${NC}"
            echo "========================================"
            
            # 等待2秒，如果用户按键则进入主菜单
            if read -t 2 -n 1; then
                echo -e "\n${YELLOW}跳过自动选择，进入主菜单${NC}"
                sleep 1
                show_main_menu_loop
            else
                show_pve_menu
                show_main_menu_loop
            fi
            ;;
        "fnos")
            echo -e "${YELLOW}根据IP地址，自动进入 FnOS 命令合集${NC}"
            echo "----------------------------------------"
            echo -e "${CYAN}2秒后自动进入 FnOS 菜单...${NC}"
            echo -e "${CYAN}按任意键跳过等待并选择菜单${NC}"
            echo "========================================"
            
            # 等待2秒，如果用户按键则进入主菜单
            if read -t 2 -n 1; then
                echo -e "\n${YELLOW}跳过自动选择，进入主菜单${NC}"
                sleep 1
                show_main_menu_loop
            else
                show_fnos_menu
                show_main_menu_loop
            fi
            ;;
        "nginx")
            echo -e "${YELLOW}根据IP地址，自动进入 Nginx 命令合集${NC}"
            echo "----------------------------------------"
            echo -e "${CYAN}2秒后自动进入 Nginx 菜单...${NC}"
            echo -e "${CYAN}按任意键跳过等待并选择菜单${NC}"
            echo "========================================"
            
            # 等待2秒，如果用户按键则进入主菜单
            if read -t 2 -n 1; then
                echo -e "\n${YELLOW}跳过自动选择，进入主菜单${NC}"
                sleep 1
                show_main_menu_loop
            else
                show_nginx_menu
                show_main_menu_loop
            fi
            ;;
        *)
            echo -e "${YELLOW}未识别到特定系统，进入主菜单${NC}"
            echo "========================================"
            show_main_menu_loop
            ;;
    esac
}

# 函数：显示主菜单循环
show_main_menu_loop() {
    while true; do
        show_main_menu
        
        if ! safe_read_number "请输入选择" main_choice 0 8; then
            continue
        fi
        
        case $main_choice in
            1)
                show_pve_menu
                ;;
            2)
                show_fnos_menu
                ;;
            3)
                show_nginx_menu
                ;;
            4)
                show_linux_menu
                ;;
            5)
                show_linux_file_menu
                ;;
            6)
                show_compress_menu
                ;;
            7)
                show_script_menu
                ;;
            8)
                show_docker_menu
                ;;

            0)
                echo -e "${GREEN}感谢使用，再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                sleep 1
                ;;
        esac
    done
}

# 运行主程序
main
