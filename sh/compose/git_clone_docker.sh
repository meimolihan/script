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

menu() {
    clear
    echo "请选择要克隆的仓库："
    echo "========================"
    # 使用索引遍历所有仓库
    for index in "${!repo[@]}"; do
        repo_url="${repo[$index]}"
        repo_name=$(basename "$repo_url" .git)
        echo "$index. ${comment[$index]}--$repo_name"
    done
    echo "========================"
    echo "a. 自定义克隆仓库地址"
    echo "x. 克隆所有仓库"
    echo "0. 退出"
    echo "========================"

    read -p "请输入选项: " choice

    # 转换为小写进行大小写不敏感比较
    lc_choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [ "$lc_choice" = "0" ]; then
        echo -e "${GREEN}感谢使用Git克隆仓库管理工具，再见！${NC}"
        exit 0
    fi

    if [ "$lc_choice" = "x" ]; then
        echo "正在准备克隆所有仓库..."
        echo "========================"
        all_success=1
        
        for index in "${!repo[@]}"; do
            repo_url="${repo[$index]}"
            repo_name=$(basename "$repo_url" .git)
            echo "正在克隆仓库：${comment[$index]}--$repo_name"
            git clone "${repo[$index]}"
            if [ $? -ne 0 ]; then
                echo "[错误] 克隆仓库：${comment[$index]}--$repo_name 失败"
                all_success=0
            else
                echo "[成功] 克隆仓库：${comment[$index]}--$repo_name 完成"
            fi
            echo
        done
        
        if [ $all_success -eq 1 ]; then
            echo "所有仓库克隆成功！"
        else
            echo "部分仓库克隆失败，请检查网络或仓库地址。"
        fi
        
        read -p "按回车键继续..."
        menu
    fi

    if [ "$lc_choice" = "a" ]; then
        read -p "请输入自定义仓库克隆地址: " custom_repo
        read -p "请输入仓库中文注释: " custom_comment
        repo_name=$(basename "$custom_repo" .git)
        echo "正在克隆仓库：${custom_comment}--$repo_name"
        git clone "$custom_repo"
        if [ $? -eq 0 ]; then
            echo "[成功] 克隆仓库：${custom_comment}--$repo_name 完成"
        else
            echo "[错误] 克隆仓库：${custom_comment}--$repo_name 失败"
        fi
        read -p "按回车键继续..."
        menu
    fi

    # 检查是否为有效数字选项
    if [[ "$choice" =~ ^[1-9][0-9]*$ ]]; then
        if [ -n "${repo[$choice]}" ]; then
            repo_url="${repo[$choice]}"
            repo_name=$(basename "$repo_url" .git)
            echo "正在克隆仓库：${comment[$choice]}--$repo_name"
            git clone "${repo[$choice]}"
            if [ $? -eq 0 ]; then
                echo "[成功] 克隆仓库：${comment[$choice]}--$repo_name 完成"
            else
                echo "[错误] 克隆仓库：${comment[$choice]}--$repo_name 失败"
            fi
            read -p "按回车键继续..."
            menu
        else
            echo "无效的选项，请重新输入。"
        fi
    else
        echo "无效的选项，请重新输入。"
    fi

    read -p "按回车键继续..."
    menu
}

menu