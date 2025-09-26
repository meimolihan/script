#!/bin/bash

# ==========================================
#            Linux 一键清理脚本
# ==========================================
# 颜色变量
BLUE='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m'

# 清理系统垃圾函数
clean_system() {
    clear
    echo -e "${BLUE}==================================${NC}"
    echo -e "${YELLOW}          系统清理工具          ${NC}"
    echo -e "${BLUE}==================================${NC}"
    
    # 需要root权限
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}请使用root权限运行此命令${NC}"
        read -n 1
        return 1
    fi
    
    # 清理前已用空间（字节）
    before=$(df -B1 / | awk 'NR==2{print $3}')

    echo -e "\n${YELLOW}准备开始清理系统...${NC}\n"
    
    # 1. 清理临时目录
    echo -e "${GREEN}[1/4] 清理临时文件目录:${NC}"
    echo -e "清理临时文件 (${BLUE}/tmp/*${NC})"
    rm -rf /tmp/* 2>/dev/null
    echo -e "清理临时文件 (${BLUE}/var/tmp/*${NC})"
    rm -rf /var/tmp/* 2>/dev/null
    
    # 2. 清理软件包缓存（针对不同的Linux发行版）
    echo -e "\n${GREEN}[2/4] 清理软件包缓存:${NC}"
    if command -v apt-get &> /dev/null; then
        # Ubuntu/Debian系统
        echo -e "检测到 ${YELLOW}Ubuntu/Debian${NC} 系统"
        echo -e "清理已卸载的软件包 (${BLUE}apt-get autoremove${NC})"
        apt-get autoremove -y
        echo -e "清理APT缓存 (${BLUE}apt-get clean${NC})"
        apt-get clean
        echo -e "清理不需要的配置文件 (${BLUE}apt-get autoclean${NC})"
        apt-get autoclean
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL系统
        echo -e "检测到 ${YELLOW}CentOS/RHEL${NC} 系统"
        echo -e "清理YUM缓存 (${BLUE}yum clean all${NC})"
        yum clean all
        echo -e "清理已卸载的软件包 (${BLUE}yum autoremove${NC})"
        yum autoremove -y
    elif command -v dnf &> /dev/null; then
        # Fedora/新版CentOS系统
        echo -e "检测到 ${YELLOW}Fedora/CentOS Stream${NC} 系统"
        echo -e "清理DNF缓存 (${BLUE}dnf clean all${NC})"
        dnf clean all
        echo -e "清理已卸载的软件包 (${BLUE}dnf autoremove${NC})"
        dnf autoremove -y
    elif command -v pacman &> /dev/null; then
        # Arch Linux系统
        echo -e "检测到 ${YELLOW}Arch Linux${NC} 系统"
        echo -e "清理pacman缓存 (${BLUE}pacman -Scc${NC})"
        pacman -Scc --noconfirm
    else
        echo -e "${YELLOW}未检测到支持的包管理器，跳过软件包缓存清理${NC}"
    fi
    
    # 3. 清理日志文件
    echo -e "\n${GREEN}[3/4] 清理系统日志:${NC}"
    if command -v journalctl &> /dev/null; then
        echo -e "清理系统日志文件 (${BLUE}journalctl --vacuum-time=3d${NC})"
        journalctl --vacuum-time=3d
        echo -e "限制日志大小 (${BLUE}journalctl --vacuum-size=100M${NC})"
        journalctl --vacuum-size=100M
    else
        echo -e "清理系统日志文件 (${BLUE}/var/log/${NC})"
        find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
        find /var/log -type f -name "*.gz" -delete
    fi
    
    # 4. 清理用户缓存
    echo -e "\n${GREEN}[4/4] 清理用户缓存:${NC}"
    echo -e "清理浏览器缓存、应用程序缓存等 (${BLUE}~/.cache/*${NC})"
    rm -rf ~/.cache/* 2>/dev/null

    # 计算释放空间
    after=$(df -B1 / | awk 'NR==2{print $3}')
    freed_bytes=$((before - after))
    if [ "$freed_bytes" -ge 1073741824 ]; then
        freed=$(awk "BEGIN{printf \"%.2f\", $freed_bytes/1073741824}")" GB"
    elif [ "$freed_bytes" -ge 1048576 ]; then
        freed=$(awk "BEGIN{printf \"%.2f\", $freed_bytes/1048576}")" MB"
    elif [ "$freed_bytes" -ge 1024 ]; then
        freed=$(awk "BEGIN{printf \"%.2f\", $freed_bytes/1024}")" KB"
    else
        freed="${freed_bytes} B"
    fi
    
    # 结果报告
    echo -e "\n${GREEN}系统清理完成！${NC}"
    echo -e "${BLUE}==================================${NC}"
    echo -e "本次共释放磁盘空间：${YELLOW}${freed}${NC}"
    echo -e "清理项目包括:"
    echo -e "1. 临时文件 (/tmp/*, /var/tmp/*)"
    echo -e "2. 软件包缓存 (因系统而异)"
    echo -e "3. 系统日志 (journalctl 或 /var/log/)"
    echo -e "4. 用户缓存 (~/.cache/*)"
    echo -e "${BLUE}==================================${NC}"
    
    exit 0
} 
clean_system