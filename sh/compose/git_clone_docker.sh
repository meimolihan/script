#!/bin/bash
# ==========================================
#   Git 仓库克隆管理工具（大写英文/空格/颜色全对齐版）
# ==========================================

############## 颜色变量 ##############
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

############## 检查 git ##############
check_git() {
    command -v git &>/dev/null || {
        echo -e "${RED}错误：未安装 git，请先安装 git 后再运行脚本${NC}"
        exit 1
    }
}

############## 仓库数据 ##############
declare -A repo comment
# 服务器与容器管理
repo[1]="git@gitee.com:meimolihan/1panel.git";          comment[1]="服务管理"
repo[2]="git@gitee.com:meimolihan/dpanel.git";          comment[2]="容器管理"
# 博客与文档系统
repo[3]="git@gitee.com:meimolihan/halo.git";            comment[3]="博客系统"
repo[4]="git@gitee.com:meimolihan/hexo.git";            comment[4]="博客系统"
repo[5]="git@gitee.com:meimolihan/md.git";              comment[5]="云文档"
repo[6]="git@gitee.com:meimolihan/nginx-dock-builder.git"; comment[6]="配置编辑"
repo[7]="git@gitee.com:meimolihan/mindoc.git";          comment[7]="文档管理"
# 影视相关
repo[8]="git@gitee.com:meimolihan/aipan.git";           comment[8]="爱盼影视"
repo[9]="git@gitee.com:meimolihan/libretv.git";         comment[9]="影视聚合"
repo[10]="git@gitee.com:meimolihan/moontv.git";         comment[10]="影视聚合"
repo[11]="git@gitee.com:meimolihan/nastools.git";       comment[11]="影视刮削"
repo[12]="git@gitee.com:meimolihan/emby.git";           comment[12]="媒体服务"
repo[13]="git@gitee.com:meimolihan/tvhelper.git";       comment[13]="电视助手"
# 音乐相关
repo[14]="git@gitee.com:meimolihan/musicn.git";         comment[14]="音乐下载"
repo[15]="git@gitee.com:meimolihan/navidrome.git";      comment[15]="音乐播放"
repo[16]="git@gitee.com:meimolihan/xiaomusic.git";      comment[16]="小米音乐"
# 下载工具
repo[17]="git@gitee.com:meimolihan/xunlei.git";         comment[17]="下载器"
repo[18]="git@gitee.com:meimolihan/qbittorrent.git";    comment[18]="下载器"
repo[19]="git@gitee.com:meimolihan/transmission.git";   comment[19]="下载器"
repo[20]="git@gitee.com:meimolihan/metube.git";         comment[20]="视频下载"
# 网盘与文件管理
repo[21]="git@gitee.com:meimolihan/cloud-saver.git";    comment[21]="网盘搜索"
repo[22]="git@gitee.com:meimolihan/pansou.git";         comment[22]="网盘搜索"
repo[23]="git@gitee.com:meimolihan/openlist.git";       comment[23]="网盘挂载"
repo[24]="git@gitee.com:meimolihan/nginx-file.git";     comment[24]="文件服务"
repo[25]="git@gitee.com:meimolihan/dufs.git";           comment[25]="文件服务"
repo[26]="git@gitee.com:meimolihan/taosync.git";        comment[26]="云盘同步"
# 导航与工具
repo[27]="git@gitee.com:meimolihan/sun-panel.git";      comment[27]="导航面板"
repo[28]="git@gitee.com:meimolihan/sun-panel-helper.git"; comment[28]="导航面板"
repo[29]="git@gitee.com:meimolihan/it-tools.git";       comment[29]="工具箱"
repo[30]="git@gitee.com:meimolihan/random-pic-api.git"; comment[30]="随机图片"
repo[31]="git@gitee.com:meimolihan/mind-map.git";       comment[31]="思维导图"
# 网络相关
repo[32]="git@gitee.com:meimolihan/istoreos.git";       comment[32]="路由系统"
repo[33]="git@gitee.com:meimolihan/kspeeder.git";       comment[33]="网络加速"
repo[34]="git@gitee.com:meimolihan/uptime-kuma.git";    comment[34]="网站监控"
repo[35]="git@gitee.com:meimolihan/speedtest.git";      comment[35]="内网测速"
# 其他工具
repo[36]="git@gitee.com:meimolihan/easyvoice.git";      comment[36]="语音文字"
repo[37]="git@gitee.com:meimolihan/watchtower.git";     comment[37]="容器更新"
repo[38]="git@gitee.com:meimolihan/reubah.git";         comment[38]="格式转换"
repo[39]="git@gitee.com:meimolihan/gitea.git";          comment[39]="代码托管"
repo[40]="git@gitee.com:meimolihan/webtop-ubuntu.git";  comment[40]="远程桌面"
repo[41]="git@gitee.com:meimolihan/webtop-alpine.git";  comment[41]="远程桌面"
repo[42]="git@gitee.com:meimolihan/easynode.git";       comment[42]="终端工具"

############## 克隆单个仓库 ##############
clone_repo() {
    local repo_url=$1
    local repo_comment=$2
    local repo_name=$(basename "$repo_url" .git)

    if [ -d "$repo_name" ]; then
        echo -e "${YELLOW}警告：仓库目录 '$repo_name' 已存在，跳过克隆${NC}"
        return 1
    fi

    echo -e "${GREEN}正在克隆仓库：${repo_comment} -- ${repo_name}${NC}"
    echo -e "${GREEN}仓库地址：${repo_url}${NC}"
    echo -e "${GREEN}==================================${NC}"
    git clone "$repo_url"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[成功] 克隆仓库：${repo_comment} -- ${repo_name} 完成${NC}"
        return 0
    else
        echo -e "${RED}[错误] 克隆仓库：${repo_comment} -- ${repo_name} 失败${NC}"
        return 1
    fi
}

############## 对齐打印辅助 ##############
# 去掉字符串里的颜色转义序列（再计算宽度）
strip_color() {
    sed -E 's/\x1B\[[0-9;]*[mK]//g' <<<"$*"
}

# 计算显示宽度：全角=2，半角=1，空格=1
str_width() {
    local s=$(strip_color "$1") len=0 i ch
    for ((i=0;i<${#s};i++)); do
        ch=${s:i:1}
        # 空格或 ASCII 可见字符
        if [[ $ch == ' ' ]] || [[ $ch =~ ^[\x20-\x7E]$ ]]; then
            ((len++))
        else
            ((len+=2))   # 全角
        fi
    done
    echo $len
}

# 生成 n 个空格
spaces() { printf '%*s' "$1" ''; }

# 打印一行对齐的 “编号. 注释 -- 仓库名”
print_line() {
    local idx=$1
    local note=${comment[$idx]}
    local repo_name=$(basename "${repo[$idx]}" .git)
    local note_width=$(str_width "$note")
    local pad_cnt=$(( max_width - note_width ))
    # 先拼内容，再整体上色，避免转义序列干扰宽度
    local line=$(printf '%2d. %s%s -- %s' \
                  "$idx" "$note" "$(spaces "$pad_cnt")" "$repo_name")
    echo -e "${GREEN}${line}${NC}"
}

############## 菜单 ##############
menu() {
    clear
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}        Git仓库克隆管理工具        ${NC}"
    echo -e "${GREEN}==================================${NC}"

    # 计算最大注释宽度（去掉颜色）
    max_width=0
    for idx in "${!repo[@]}"; do
        w=$(str_width "${comment[$idx]}")
        (( w > max_width )) && max_width=$w
    done

    echo -e "${GREEN}------ 服务器与容器管理 ------${NC}"
    for i in 1 2; do print_line $i; done

    echo -e "\n${GREEN}------ 博客与文档系统 ------${NC}"
    for i in 3 4 5 6 7; do print_line $i; done

    echo -e "\n${GREEN}------ 影视相关 ------${NC}"
    for i in 8 9 10 11 12 13; do print_line $i; done

    echo -e "\n${GREEN}------ 音乐相关 ------${NC}"
    for i in 14 15 16; do print_line $i; done

    echo -e "\n${GREEN}------ 下载工具 ------${NC}"
    for i in 17 18 19 20; do print_line $i; done

    echo -e "\n${GREEN}------ 网盘与文件管理 ------${NC}"
    for i in 21 22 23 24 25 26; do print_line $i; done

    echo -e "\n${GREEN}------ 导航与工具 ------${NC}"
    for i in 27 28 29 30 31; do print_line $i; done

    echo -e "\n${GREEN}------ 网络相关 ------${NC}"
    for i in 32 33 34 35; do print_line $i; done

    echo -e "\n${GREEN}------ 其他工具 ------${NC}"
    for i in 36 37 38 39 40 41 42; do print_line $i; done

    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}当前工作目录：$(pwd)${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}x. 克隆所有仓库${NC}"
    echo -e "${GREEN}y. 自定义克隆仓库${NC}"
    echo -e "${GREEN}0. 退出${NC}"
    echo -e "${GREEN}==================================${NC}"

    read -rp "请输入选项: " choice
    local lc_choice=${choice,,}   # 转小写

    case $lc_choice in
        0)
            echo -e "${GREEN}感谢使用Git克隆仓库管理工具，再见！${NC}"
            exit 0
            ;;
        x)
            echo -e "${YELLOW}警告：即将克隆所有 ${#repo[@]} 个仓库，可能需要较长时间和较多存储空间${NC}"
            read -rp "确定要继续吗? (y/n) " confirm
            [[ ${confirm,,} != "y" ]] && {
                echo -e "${GREEN}已取消克隆所有仓库${NC}"
                read -p "按回车键返回菜单..."
                menu
                return
            }
            local all_success=1
            echo -e "${GREEN}正在准备克隆所有仓库...${NC}"
            echo -e "${GREEN}==================================${NC}"
            for index in $(seq 1 ${#repo[@]}); do
                if [ -n "${repo[$index]}" ]; then
                    echo -e "\n${GREEN}----- 处理仓库 $index -----${NC}"
                    clone_repo "${repo[$index]}" "${comment[$index]}" || all_success=0
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
            read -rp "请输入Git仓库的URL或git clone命令: " repoUrl
            if [ -z "$repoUrl" ]; then
                echo -e "${RED}错误：未输入有效的URL${NC}"
                read -p "按任意键返回菜单..."
                menu
                return
            fi
            local cleanUrl=${repoUrl#*git clone }
            cleanUrl=${cleanUrl//[\"\'\']/}
            local repoName=$(basename "$cleanUrl" .git)

            echo -e "${GREEN}==================================${NC}"
            echo -e "${GREEN}即将克隆仓库: $repoName${NC}"
            echo -e "${GREEN}仓库地址: $cleanUrl${NC}"
            echo -e "${GREEN}==================================${NC}"

            if [ -d "$repoName" ]; then
                echo -e "${YELLOW}警告：仓库目录 '$repoName' 已存在${NC}"
                read -rp "是否强制重新克隆? (y/n) " overwrite
                if [[ ${overwrite,,} != "y" ]]; then
                    echo -e "${GREEN}已取消克隆${NC}"
                    read -p "按回车键返回菜单..."
                    menu
                    return
                fi
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

############## 主程序入口 ##############
check_git
menu