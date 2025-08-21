#!/bin/bash

# 定义颜色变量
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 检查git是否安装
check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}错误：未安装git，请先安装git后再运行脚本${NC}"
        exit 1
    fi
}

# 定义仓库地址和中文注释，索引保持一致
declare -A repo
declare -A comment

# 服务器与容器管理
repo[1]="git@gitee.com:meimolihan/1panel.git"
comment[1]="服务器管理"
repo[2]="git@gitee.com:meimolihan/dpanel.git"
comment[2]="容器管理"

# 博客与文档系统
repo[3]="git@gitee.com:meimolihan/halo.git"
comment[3]="博客系统"
repo[4]="git@gitee.com:meimolihan/hexo.git"
comment[4]="博客系统"
repo[5]="git@gitee.com:meimolihan/md.git"
comment[5]="云文档"

# 影视相关
repo[6]="git@gitee.com:meimolihan/aipan.git"
comment[6]="爱盼影视"
repo[7]="git@gitee.com:meimolihan/libretv.git"
comment[7]="影视聚合"
repo[8]="git@gitee.com:meimolihan/moontv.git"
comment[8]="影视聚合"
repo[9]="git@gitee.com:meimolihan/nastools.git"
comment[9]="影视刮削"
repo[10]="git@gitee.com:meimolihan/emby.git"
comment[10]="媒体服务器"
repo[11]="git@gitee.com:meimolihan/tvhelper.git"
comment[11]="电视助手"

# 音乐相关
repo[12]="git@gitee.com:meimolihan/musicn.git"
comment[12]="音乐下载"
repo[13]="git@gitee.com:meimolihan/navidrome.git"
comment[13]="音乐播放器"
repo[14]="git@gitee.com:meimolihan/xiaomusic.git"
comment[14]="小米音乐"

# 下载工具
repo[15]="git@gitee.com:meimolihan/xunlei.git"
comment[15]="下载器"
repo[16]="git@gitee.com:meimolihan/qbittorrent.git"
comment[16]="下载器"
repo[17]="git@gitee.com:meimolihan/transmission.git"
comment[17]="下载器"
repo[18]="git@gitee.com:meimolihan/metube.git"
comment[18]="视频下载"

# 网盘与文件管理
repo[19]="git@gitee.com:meimolihan/cloud-saver.git"
comment[19]="网盘搜索"
repo[20]="git@gitee.com:meimolihan/pansou.git"
comment[20]="网盘搜索"
repo[21]="git@gitee.com:meimolihan/openlist.git"
comment[21]="网盘挂载"
repo[22]="git@gitee.com:meimolihan/nginx-file-server.git"
comment[22]="文件服务"
repo[23]="git@gitee.com:meimolihan/dufs.git"
comment[23]="文件服务"
repo[24]="git@gitee.com:meimolihan/taosync.git"
comment[24]="云盘同步"

# 导航与工具
repo[25]="git@gitee.com:meimolihan/sun-panel.git"
comment[25]="导航面板"
repo[26]="git@gitee.com:meimolihan/sun-panel-helper.git"
comment[26]="导航面板"
repo[27]="git@gitee.com:meimolihan/it-tools.git"
comment[27]="IT 工具箱"
repo[28]="git@gitee.com:meimolihan/random-pic-api.git"
comment[28]="随机图片"
repo[29]="git@gitee.com:meimolihan/mind-map.git"
comment[29]="思维导图"

# 网络相关
repo[30]="git@gitee.com:meimolihan/istoreos.git"
comment[30]="路由器系统"
repo[31]="git@gitee.com:meimolihan/kspeeder.git"
comment[31]="网络加速器"
repo[32]="git@gitee.com:meimolihan/uptime-kuma.git"
comment[32]="网站监控"
repo[33]="git@gitee.com:meimolihan/speedtest.git"
comment[33]="内网测速"

# 其他工具
repo[34]="git@gitee.com:meimolihan/easyvoice.git"
comment[34]="语音转文字"
repo[35]="git@gitee.com:meimolihan/watchtower.git"
comment[35]="容器更新"
repo[36]="git@gitee.com:meimolihan/reubah.git"
comment[36]="格式转换"
repo[37]="git@gitee.com:meimolihan/gitea.git"
comment[37]="代码托管"
repo[38]="git@gitee.com:meimolihan/webtop-ubuntu.git"
comment[38]="ubuntu 桌面"
repo[39]="git@gitee.com:meimolihan/webtop-alpine.git"
comment[39]="alpine 桌面"

# 克隆单个仓库
clone_repo() {
    local repo_url=$1
    local repo_comment=$2
    
    # 提取仓库名称
    local repo_name=$(basename "$repo_url" .git)
    
    # 检查目录是否已存在
    if [ -d "$repo_name" ]; then
        echo -e "${YELLOW}警告：仓库目录 '$repo_name' 已存在，跳过克隆${NC}"
        return 1
    fi
    
    echo -e "${GREEN}正在克隆仓库：${repo_comment} -- ${repo_name}${NC}"
    echo -e "${GREEN}仓库地址：${repo_url}${NC}"
    echo -e "${GREEN}==================================${NC}"
    
    # 执行克隆命令
    git clone "$repo_url"
    
    # 检查克隆结果
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[成功] 克隆仓库：${repo_comment} -- ${repo_name} 完成${NC}"
        return 0
    else
        echo -e "${RED}[错误] 克隆仓库：${repo_comment} -- ${repo_name} 失败${NC}"
        return 1
    fi
}

# 显示菜单并处理用户选择
menu() {
    clear
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}        Git仓库克隆管理工具        ${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}请选择要克隆的仓库：${NC}"
    echo -e "${GREEN}==================================${NC}"
    
    # 服务器与容器管理
    echo -e "${GREEN}--- 服务器与容器管理 ---${NC}"
    for index in 1 2; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 博客与文档系统
    echo -e "\n${GREEN}--- 博客与文档系统 ---${NC}"
    for index in 3 4 5; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 影视相关
    echo -e "\n${GREEN}--- 影视相关 ---${NC}"
    for index in 6 7 8 9 10 11; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 音乐相关
    echo -e "\n${GREEN}--- 音乐相关 ---${NC}"
    for index in 12 13 14; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 下载工具
    echo -e "\n${GREEN}--- 下载工具 ---${NC}"
    for index in 15 16 17 18; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 网盘与文件管理
    echo -e "\n${GREEN}--- 网盘与文件管理 ---${NC}"
    for index in 19 20 21 22 23 24; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 导航与工具
    echo -e "\n${GREEN}--- 导航与工具 ---${NC}"
    for index in 25 26 27 28 29; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 网络相关
    echo -e "\n${GREEN}--- 网络相关 ---${NC}"
    for index in 30 31 32 33; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    # 其他工具
    echo -e "\n${GREEN}--- 其他工具 ---${NC}"
    for index in 34 35 36 37 38 39; do
        if [ -n "${repo[$index]}" ]; then
            printf "${GREEN}%2d. %-20s -- %s${NC}\n" \
                "$index" \
                "${comment[$index]}" \
                "$(basename "${repo[$index]}" .git)"
        fi
    done
    
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}x. 克隆所有仓库${NC}"
    echo -e "${GREEN}y. 自定义克隆仓库${NC}"
    echo -e "${GREEN}0. 退出${NC}"
    echo -e "${GREEN}==================================${NC}"

    read -p "请输入选项: " choice

    # 转换为小写进行大小写不敏感比较
    local lc_choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    case $lc_choice in
        0)
            echo -e "${GREEN}感谢使用Git克隆仓库管理工具，再见！${NC}"
            exit 0
            ;;
        x)
            echo -e "${YELLOW}警告：即将克隆所有 ${#repo[@]} 个仓库，可能需要较长时间和较多存储空间${NC}"
            read -p "确定要继续吗? (y/n) " confirm
            if [ "$(echo "$confirm" | tr '[:upper:]' '[:lower:]')" != "y" ]; then
                echo -e "${GREEN}已取消克隆所有仓库${NC}"
                read -p "按回车键返回菜单..."
                menu
                return
            fi
            
            echo -e "${GREEN}正在准备克隆所有仓库...${NC}"
            echo -e "${GREEN}==================================${NC}"
            local all_success=1
            
            for index in $(seq 1 ${#repo[@]}); do
                if [ -n "${repo[$index]}" ]; then
                    echo -e "\n${GREEN}----- 处理仓库 $index -----${NC}"
                    clone_repo "${repo[$index]}" "${comment[$index]}"
                    if [ $? -ne 0 ]; then
                        all_success=0
                    fi
                fi
            done
            
            echo -e "\n${GREEN}==================================${NC}"
            if [ $all_success -eq 1 ]; then
                echo -e "${GREEN}所有仓库克隆成功！${NC}"
            else
                echo -e "${YELLOW}部分仓库克隆失败，请检查错误信息。${NC}"
            fi
            
            read -p "按回车键继续..."
            menu
            ;;
        y)
            clear
            echo -e "${GREEN}==================================${NC}"
            echo -e "${GREEN}        自定义仓库克隆        ${NC}"
            echo -e "${GREEN}==================================${NC}"
            read -p "请输入Git仓库的URL或git clone命令: " repoUrl

            if [ -z "$repoUrl" ]; then
                echo -e "${RED}错误：未输入有效的URL${NC}"
                read -p "按任意键返回菜单..."
                menu
                return
            fi

            # 清理URL，支持完整的git clone命令
            local cleanUrl=$repoUrl
            cleanUrl=${cleanUrl#*git clone }
            cleanUrl=${cleanUrl//\"/}  # 移除可能的引号
            cleanUrl=${cleanUrl//\'}   # 移除可能的单引号

            # 提取仓库名称
            local repoName=$(basename "$cleanUrl" .git)

            echo -e "${GREEN}==================================${NC}"
            echo -e "${GREEN}即将克隆仓库: $repoName${NC}"
            echo -e "${GREEN}仓库地址: $cleanUrl${NC}"
            echo -e "${GREEN}==================================${NC}"
            
            # 检查目录是否已存在
            if [ -d "$repoName" ]; then
                echo -e "${YELLOW}警告：仓库目录 '$repoName' 已存在${NC}"
                read -p "是否强制重新克隆? (y/n) " overwrite
                if [ "$(echo "$overwrite" | tr '[:upper:]' '[:lower:]')" != "y" ]; then
                    echo -e "${GREEN}已取消克隆${NC}"
                    read -p "按回车键返回菜单..."
                    menu
                    return
                fi
                echo -e "${GREEN}删除现有目录...${NC}"
                rm -rf "$repoName"
            fi

            git clone "$cleanUrl"
            echo -e "${GREEN}==================================${NC}"

            if [ $? -ne 0 ]; then
                echo -e "${RED}仓库 '$repoName' 克隆失败，请检查URL是否正确或网络连接。${NC}"
            else
                echo -e "${GREEN}仓库 '$repoName' 克隆成功！${NC}"
            fi
            
            read -p "按回车键继续..."
            menu
            ;;
        [1-9]|[1-9][0-9])
            if [ -n "${repo[$choice]}" ]; then
                clone_repo "${repo[$choice]}" "${comment[$choice]}"
                read -p "按回车键继续..."
                menu
            else
                echo -e "${RED}错误：无效的选项，请重新输入。${NC}"
                read -p "按回车键继续..."
                menu
            fi
            ;;
        *)
            echo -e "${RED}错误：无效的选项，请重新输入。${NC}"
            read -p "按回车键继续..."
            menu
            ;;
    esac
}

# 主程序入口
check_git
menu