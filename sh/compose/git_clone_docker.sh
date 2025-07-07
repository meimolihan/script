#!/bin/bash

# 定义颜色变量
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 定义仓库地址和中文注释，索引保持一致
repo[1]="git@gitee.com:meimolihan/1panel.git"
comment[1]="服务器管理"
repo[2]="git@gitee.com:meimolihan/aipan.git"
comment[2]="爱盼影视"
repo[3]="git@gitee.com:meimolihan/alist.git"
comment[3]="云盘目录程序"
repo[4]="git@gitee.com:meimolihan/docker-manage.git"
comment[4]="Docker管理工具"
repo[5]="git@gitee.com:meimolihan/emby.git"
comment[5]="媒体服务器"
repo[6]="git@gitee.com:meimolihan/halo.git"
comment[6]="博客系统"
repo[7]="git@gitee.com:meimolihan/istoreos.git"
comment[7]="路由器系统"
repo[8]="git@gitee.com:meimolihan/it-tools.git"
comment[8]="IT工具箱"
repo[9]="git@gitee.com:meimolihan/kspeeder.git"
comment[9]="网络加速器"
repo[10]="git@gitee.com:meimolihan/nastools.git"
comment[10]="影视刮削"
repo[11]="git@gitee.com:meimolihan/random-pic-api.git"
comment[11]="随机图片API"
repo[12]="git@gitee.com:meimolihan/sun-panel.git"
comment[12]="导航面板"
repo[13]="git@gitee.com:meimolihan/tvhelper.git"
comment[13]="电视助手"
repo[14]="git@gitee.com:meimolihan/uptime-kuma.git"
comment[14]="网站监控器"
repo[15]="git@gitee.com:meimolihan/xiaomusic.git"
comment[15]="小米音乐"
repo[16]="git@gitee.com:meimolihan/xunlei.git"
comment[16]="迅雷下载"
repo[17]="git@gitee.com:meimolihan/md.git"
comment[17]="Markdown工具"
repo[18]="git@gitee.com:meimolihan/easyvoice.git"
comment[18]="语音转文字"
repo[19]="git@gitee.com:meimolihan/dpanel.git"
comment[19]="Docker面板"
repo[20]="git@gitee.com:meimolihan/libretv.git"
comment[20]="影视"
repo[21]="git@gitee.com:meimolihan/metube.git"
comment[21]="视频下载"
repo[22]="git@gitee.com:meimolihan/taoSync.git"
comment[22]="云盘同步"
repo[23]="git@gitee.com:meimolihan/speedtest.git"
comment[23]="内网测速"
repo[24]="git@gitee.com:meimolihan/watchtower.git"
comment[24]="容器自动更新"
repo[25]="git@gitee.com:meimolihan/reubah.git"
comment[25]="图片文档格式转换"
repo[26]="git@gitee.com:meimolihan/navidrome.git"
comment[26]="网页音乐播放器"
repo[27]="git@gitee.com:meimolihan/openlist.git"
comment[27]="网盘挂载"
repo[28]="git@gitee.com:meimolihan/musicn.git"
comment[28]="音乐下载"
repo[29]="git@gitee.com:meimolihan/nginx-file-server.git"
comment[29]="nginx 文件服务"
repo[30]="git@gitee.com:meimolihan/moontv.git"
comment[30]="影视聚合播放器"
repo[31]="git@gitee.com:meimolihan/hexo.git"
comment[31]="Hexo 博客"


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