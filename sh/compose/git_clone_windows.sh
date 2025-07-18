#!/bin/bash

# 定义颜色变量
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 定义仓库地址和中文注释，索引保持一致
repo[1]="git@gitee.com:meimolihan/bat.git"
comment[1]="常用批处理"
repo[2]="git@gitee.com:meimolihan/360.git"
comment[2]="360单机软件"
repo[3]="git@gitee.com:meimolihan/final-shell.git"
comment[3]="终端工具"
repo[4]="git@gitee.com:meimolihan/clash.git"
comment[4]="翻墙工具"
repo[5]="git@gitee.com:meimolihan/dism.git"
comment[5]="Dism++系统优化"
repo[6]="git@gitee.com:meimolihan/youtube.git"
comment[6]="youtube 视频下载"
repo[7]="git@gitee.com:meimolihan/ffmpeg.git"
comment[7]="音视频处理"
repo[8]="git@gitee.com:meimolihan/bcuninstaller.git"
comment[8]="卸载软件"
repo[9]="git@gitee.com:meimolihan/typora.git"
comment[9]="文本编辑器"
repo[10]="git@gitee.com:meimolihan/lx-music-desktop.git"
comment[10]="落雪音乐"
repo[11]="git@gitee.com:meimolihan/xsnip.git"
comment[11]="截图工具"
repo[12]="git@gitee.com:meimolihan/image.git"
comment[12]="图片处理"
repo[13]="git@gitee.com:meimolihan/rename.git"
comment[13]="大笨狗更名器"
repo[14]="git@gitee.com:meimolihan/wallpaper.git"
comment[14]="windows 壁纸"
repo[15]="git@gitee.com:meimolihan/trafficmonitor.git"
comment[15]="显示网速"


menu() {
    clear
    echo -e "${GREEN}请选择要克隆的仓库：${NC}"
    echo -e "${GREEN}========================${NC}"
    # 使用索引遍历所有仓库
    for index in "${!repo[@]}"; do
        repo_url="${repo[$index]}"
        repo_name=$(basename "$repo_url" .git)
        echo -e "${GREEN}$index. ${comment[$index]}--$repo_name${NC}"
    done
    echo -e "${GREEN}========================${NC}"
    echo -e "${GREEN}x. 克隆所有仓库${NC}"
    echo -e "${GREEN}y. 自定义克隆仓库${NC}"
    echo -e "${GREEN}0. 退出${NC}"
    echo -e "${GREEN}========================${NC}"

    read -p "请输入选项: " choice

    # 转换为小写进行大小写不敏感比较
    lc_choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [ "$lc_choice" = "0" ]; then
        echo -e "${GREEN}感谢使用Git克隆仓库管理工具，再见！${NC}"
        exit 0
    fi

    if [ "$lc_choice" = "x" ]; then
        echo -e "${GREEN}正在准备克隆所有仓库...${NC}"
        echo -e "${GREEN}========================${NC}"
        all_success=1
        
        for index in "${!repo[@]}"; do
            repo_url="${repo[$index]}"
            repo_name=$(basename "$repo_url" .git)
            echo -e "${GREEN}正在克隆仓库：${comment[$index]}--$repo_name${NC}"
            git clone "${repo[$index]}"
            if [ $? -ne 0 ]; then
                echo -e "${GREEN}[错误] 克隆仓库：${comment[$index]}--$repo_name 失败${NC}"
                all_success=0
            else
                echo -e "${GREEN}[成功] 克隆仓库：${comment[$index]}--$repo_name 完成${NC}"
            fi
            echo
        done
        
        if [ $all_success -eq 1 ]; then
            echo -e "${GREEN}所有仓库克隆成功！${NC}"
        else
            echo -e "${GREEN}部分仓库克隆失败，请检查网络或仓库地址。${NC}"
        fi
        
        read -p "按回车键继续..."
        menu
    fi

    if [ "$lc_choice" = "y" ]; then
    clear
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}               Git 克隆仓库${NC}"
    echo -e "${GREEN}=======================================${NC}"
    read -p "请输入Git仓库的URL或git clone命令: " repoUrl

    if [ -z "$repoUrl" ]; then
        echo -e "${RED}未输入有效的URL，请重新运行脚本并输入正确的URL。${NC}"
        read -p "按任意键返回克隆菜单..."
        return
    fi

    # 清理URL
    cleanUrl=$repoUrl
    cleanUrl=${cleanUrl#*git clone }
    cleanUrl=${cleanUrl#*git clone=}

    # 提取仓库名称
    repoName=$cleanUrl
    repoName=${repoName##*/}
    repoName=${repoName%.git}

    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}正在克隆仓库 \"${repoName}\", 请稍候...${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}=======================================${NC}"
    git clone "$cleanUrl"
    echo -e "${GREEN}=======================================${NC}"

    if [ $? -ne 0 ]; then
        echo -e "${RED}仓库 \"${repoName}\"，克隆失败，请检查URL是否正确或网络连接。${NC}"
    else
        echo -e "${GREEN}仓库 \"${repoName}\"，克隆成功！${NC}"
    fi
        read -p "按回车键继续..."
        menu
    fi

    # 检查是否为有效数字选项
    if [[ "$choice" =~ ^[1-9][0-9]*$ ]]; then
        if [ -n "${repo[$choice]}" ]; then
            repo_url="${repo[$choice]}"
            repo_name=$(basename "$repo_url" .git)
            echo -e "${GREEN}==================================${NC}"
            echo -e "${GREEN}正在克隆仓库：${comment[$choice]}--$repo_name${NC}"
            echo -e "${GREEN}==================================${NC}"
            git clone "${repo[$choice]}"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}==================================${NC}"
                echo -e "${GREEN}[成功] 克隆仓库：${comment[$choice]}--$repo_name 完成${NC}"
                echo -e "${GREEN}==================================${NC}"
            else
                echo -e "${GREEN}==================================${NC}"
                echo -e "${GREEN}[错误] 克隆仓库：${comment[$choice]}--$repo_name 失败${NC}"
                echo -e "${GREEN}==================================${NC}"
            fi
            read -p "按回车键继续..."
            menu
        else
            echo -e "${GREEN}无效的选项，请重新输入。${NC}"
        fi
    else
        echo -e "${GREEN}无效的选项，请重新输入。${NC}"
    fi

    read -p "按回车键继续..."
    menu
}

menu