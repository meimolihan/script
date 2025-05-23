#!/bin/bash

# 设置文本颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # 没有颜色

# 定义仓库地址，每行一个
declare -A repo=(
    [1]="git@gitee.com:meimolihan/bat.git"     # 常用批处理
    [2]="git@gitee.com:meimolihan/360.git"     # 360单机软件
    [3]="git@gitee.com:meimolihan/final-shell.git" # 终端工具
    [4]="git@gitee.com:meimolihan/clash.git"   # 翻墙工具
    [5]="git@gitee.com:meimolihan/dism.git"    # Dism++系统优化工具
    [6]="git@gitee.com:meimolihan/youtube.git" # youtube 视频下载
    [7]="git@gitee.com:meimolihan/ffmpeg.git"  # 音视频处理
    [8]="git@gitee.com:meimolihan/bcuninstaller.git" # 卸载软件
    [9]="git@gitee.com:meimolihan/typora.git"  # 文本编辑器
    [10]="git@gitee.com:meimolihan/lx-music-desktop.git" # 落雪音乐
    [11]="git@gitee.com:meimolihan/xsnip.git"  # 截图工具
    [12]="git@gitee.com:meimolihan/image.git"  # 图片处理
    [13]="git@gitee.com:meimolihan/rename.git" # 大笨狗更名器
    [14]="git@gitee.com:meimolihan/wallpaper.git" # windows 壁纸
    [15]="git@gitee.com:meimolihan/trafficmonitor.git" # 显示网速
)

# 获取仓库数量
repo_count=${#repo[@]}

# 显示菜单
show_menu() {
    clear
    echo -e "${GREEN}===============================${NC}"
    echo -e "${GREEN}        Git 项目管理脚本${NC}"
    echo -e "${GREEN}===============================${NC}"
    echo -e " ${GREEN}* 1. 拉取当前仓库更新${NC}"
    echo
    echo -e " ${GREEN}* 2. 提交并推送当前仓库更改${NC}"
    echo
    echo -e " ${GREEN}* 3. 更改当前仓库标签${NC}"
    echo -e "${GREEN}===============================${NC}"
    echo -e " ${GREEN}* 4. 拉取所有仓库更新${NC}"
    echo
    echo -e " ${GREEN}* 5. 提交并推送所有仓库更改${NC}"
    echo
    echo -e " ${GREEN}* 6. 克隆所有仓库菜单${NC}"
    echo -e "${GREEN}===============================${NC}"
    echo -e " ${GREEN}* 0. 退出${NC}"
    echo -e "${GREEN}===============================${NC}"
    read -p "请输入操作编号 (0 - 6): " choice
}

# 拉取当前仓库更新
pull_update() {
    clear
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}         正在从远程仓库拉取更新...${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}当前仓库路径：${NC}$(pwd)"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}正在拉取远程仓库中更新内容至本地仓库...${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo

    git pull
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}拉取成功！本地仓库已是最新版本。${NC}"
    else
        echo -e "${RED}拉取失败！请检查网络或远程仓库地址是否正确。${NC}"
    fi

    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}$(pwd) 仓库的所有操作，已完成。${NC}"
    echo -e "${GREEN}=======================================${NC}"
    read -p "按任意键返回菜单..."
}

# 提交并推送当前仓库更改
commit_push() {
    clear
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}              提交并推送更改${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}当前仓库路径：${NC}$(pwd)"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}正在推送本地仓库中的更新内容至远程仓库...${NC}"
    echo -e "${GREEN}=======================================${NC}"

    read -p "请输入提交信息（直接回车默认为 \"update\"）： " commit_msg
    if [ -z "$commit_msg" ]; then
        commit_msg="update"
    fi

    echo -e "${GREEN}正在添加所有更改到暂存区...${NC}"
    git add .
    echo -e "${GREEN}添加完成！${NC}"

    echo -e "${GREEN}正在提交更改，提交信息为：${commit_msg}${NC}"
    git commit -m "$commit_msg"
    echo -e "${GREEN}提交完成！${NC}"

    echo -e "${GREEN}正在推送更改到远程仓库...${NC}"
    echo -e "${GREEN}=======================================${NC}"

    git push
    echo -e "${GREEN}推送完成！您的更改已成功同步到远程仓库。${NC}"

    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}$(pwd) 仓库的所有操作，已完成。${NC}"
    echo -e "${GREEN}=======================================${NC}"
    read -p "按任意键返回菜单..."
}

# 更改当前仓库标签
update_git_tag() {
    clear

    # 检查是否为有效的Git仓库
    if [ ! -d ".git" ]; then
        echo -e "${RED}错误：当前目录 $(pwd) 不是一个有效的Git仓库。${NC}"
        read -p "按任意键返回菜单..."
        return
    fi

    # 添加所有更改并提交
    echo
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}            正在添加所有更改...${NC}"
    echo -e "${GREEN}当前仓库路径：${NC}$(pwd)"
    echo -e "${GREEN}=======================================${NC}"
    echo

    git add .
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}正在提交更改，提交信息为 \"update\"...${NC}"
    git commit -m "update"
    echo -e "${GREEN}=======================================${NC}"

    # 推送提交到远程仓库
    echo -e "${GREEN}正在将提交推送到远程仓库...${NC}"
    git push
    echo -e "${GREEN}=======================================${NC}"

    # 删除本地标签 v1.0.0
    echo -e "${GREEN}正在删除本地标签 v1.0.0...${NC}"
    git tag -d v1.0.0
    echo -e "${GREEN}=======================================${NC}"

    # 删除远程标签 v1.0.0
    echo -e "${GREEN}正在删除远程标签 v1.0.0...${NC}"
    git push origin :refs/tags/v1.0.0
    echo -e "${GREEN}=======================================${NC}"

    # 检查标签是否删除成功
    echo -e "${GREEN}检查标签 v1.0.0 是否删除成功...${NC}"
    if git tag -l | grep -q "v1.0.0"; then
        echo -e "${RED}远程标签 v1.0.0 删除失败，请手动检查。${NC}"
    else
        echo -e "${GREEN}远程标签 v1.0.0 删除成功。${NC}"
    fi
    echo -e "${GREEN}=======================================${NC}"

    # 创建新标签
    read -p "请输入新标签名（直接回车默认标签名为 v1.0.0）: " tag_name
    if [ -z "$tag_name" ]; then
        tag_name="v1.0.0"
    fi
    echo -e "${GREEN}正在创建新标签 ${tag_name}，标签信息为 \"为最新提交的重新创建标签\"...${NC}"
    git tag -a "$tag_name" -m "Recreate tags for the latest submission"
    echo -e "${GREEN}=======================================${NC}"

    # 推送新标签到远程仓库
    echo -e "${GREEN}正在将新的标签 ${tag_name} 推送到远程仓库...${NC}"
    git push origin "$tag_name"
    echo -e "${GREEN}=======================================${NC}"

    # 检查标签是否推送成功
    echo -e "${GREEN}检查标签 ${tag_name} 是否推送成功...${NC}"
    if git tag -l | grep -q "$tag_name"; then
        echo -e "${GREEN}标签 ${tag_name} 推送成功。${NC}"
    else
        echo -e "${RED}标签 ${tag_name} 推送失败，请手动检查。${NC}"
    fi

    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}$(pwd) 仓库的所有操作，已完成。${NC}"
    echo -e "${GREEN}=======================================${NC}"
    read -p "按任意键返回菜单..."
}

# 拉取所有仓库更新
git_update_all() {
    clear
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}正在扫描目录及子目录中的 Git 仓库...${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}目标目录：${NC}$(pwd)"
    echo -e "${GREEN}=======================================${NC}"

    # 遍历当前目录及子目录
    find . -type d -name ".git" | while read -r git_dir; do
        repo_dir=$(dirname "$git_dir")
        echo
        echo -e "${GREEN}=======================================${NC}"
        echo -e "${GREEN}检测到 Git 仓库：${NC}$repo_dir"
        cd "$repo_dir" || continue
        echo -e "${GREEN}正在拉取远程更新...${NC}"
        git pull
        echo
        echo -e "${GREEN}拉取完成：${NC}$repo_dir"
        echo -e "${GREEN}=======================================${NC}"
    done

    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}$(pwd) 子目录中的所有仓库，拉取更新操作已完成。${NC}"
    echo -e "${GREEN}=======================================${NC}"
    read -p "按任意键返回菜单..."
}

# 提交并推送所有仓库更新
git_push_all() {
    clear
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}正在扫描目录及子目录中的 Git 仓库...${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}目标目录：${NC}$(pwd)"
    echo -e "${GREEN}=======================================${NC}"

    # 遍历当前目录及子目录
    find . -type d -name ".git" | while read -r git_dir; do
        repo_dir=$(dirname "$git_dir")
        echo
        echo -e "${GREEN}=======================================${NC}"
        echo -e "${GREEN}正在处理仓库：${NC}$(basename "$repo_dir")"
        cd "$repo_dir" || continue
        echo -e "${GREEN}=======================================${NC}"

        # 添加所有更改
        git add .

        # 提交更改
        git commit -m "update"

        # 拉取远程更改并变基
        git pull --rebase

        # 推送更改
        git push

        echo
        echo -e "${GREEN}仓库 $(basename "$repo_dir") 处理完成${NC}"
        echo -e "${GREEN}=======================================${NC}"
    done

    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${GREEN}$(pwd) 子目录中的所有仓库，推送更新操作已完成。${NC}"
    echo -e "${GREEN}=======================================${NC}"
    read -p "按任意键返回菜单..."
}

# 克隆所有仓库菜单
git_clone_all_menu() {
    while true; do
        clear
        echo -e "${GREEN}=======================================${NC}"
        echo -e "${GREEN}             请选择要克隆的仓库${NC}"
        echo -e "${GREEN}=======================================${NC}"
        for i in $(seq 1 $repo_count); do
            url=${repo[$i]}
            name=$(basename "$url" .git)
            echo -e "${GREEN}$i. 克隆仓库：${name}${NC}"
        done
        echo -e "${GREEN}=======================================${NC}"
        echo -e "${GREEN}x. 克隆所有仓库${NC}"
        echo -e "${GREEN}y. 克隆新的仓库${NC}"
        echo -e "${GREEN}=======================================${NC}"
        echo -e "${GREEN}z. 返回到主菜单${NC}"
        echo -e "${GREEN}0. 退出${NC}"
        echo -e "${GREEN}=======================================${NC}"

        read -p "请输入操作编号: " choice

        case $choice in
            [1-${repo_count}])
                url=${repo[$choice]}
                name=$(basename "$url" .git)
                clear
                echo -e "${GREEN}=======================================${NC}"
                echo -e "${GREEN}      正在克隆仓库：${name}${NC}"
                echo -e "${GREEN}=======================================${NC}"
                git clone "$url" || echo -e "${RED}克隆仓库：$name 失败${NC}"
                echo
                echo -e "${GREEN}=======================================${NC}"
                echo -e "${GREEN}仓库：$name，所有操作已完成。${NC}"
                echo -e "${GREEN}=======================================${NC}"
                read -p "按任意键返回克隆菜单..."
                ;;
            x|X)
                git_clone_all
                ;;
            y|Y)
                git_clone_new
                ;;
            z|Z)
                return
                ;;
            0)
                exit_script
                ;;
            *)
                echo -e "${RED}无效的选项，请重新输入。${NC}"
                read -p "按任意键返回克隆菜单..."
                ;;
        esac
    done
}

# 克隆所有仓库
git_clone_all() {
    clear
    echo -e "${GREEN}正在准备克隆所有仓库...${NC}"
    echo -e "${GREEN}=======================================${NC}"
    all_success=1

    for i in "${!repo[@]}"; do
        url=${repo[$i]}
        name=$(basename "$url" .git)
        echo -e "${GREEN}正在克隆仓库：${name}${NC}"
        git clone "$url" || {
            echo -e "${RED}[错误] 克隆仓库：${name} 失败${NC}"
            all_success=0
        }
        echo -e "${GREEN}=======================================${NC}"
    done

    if [ $all_success -eq 1 ]; then
        echo -e "${GREEN}所有仓库克隆成功！${NC}"
    else
        echo -e "${RED}部分仓库克隆失败，请检查网络或仓库地址。${NC}"
    fi

    echo -e "${GREEN}=======================================${NC}"
    read -p "按任意键返回克隆菜单..."
}

# 克隆新的仓库
git_clone_new() {
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

    read -p "按任意键返回克隆菜单..."
}

# 退出脚本
exit_script() {
    clear
    echo
    echo
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}         感谢使用，再见！${NC}"
    echo -e "${GREEN}=======================================${NC}"
    exit 0
}

# 主程序
while true; do
    show_menu

    case $choice in
        1)
            pull_update
            ;;
        2)
            commit_push
            ;;
        3)
            update_git_tag
            ;;
        4)
            git_update_all
            ;;
        5)
            git_push_all
            ;;
        6)
            git_clone_all_menu
            ;;
        0)
            exit_script
            ;;
        *)
            echo -e "${RED}无效选项，请重新选择...${NC}"
            read -p "按任意键返回菜单..."
            ;;
    esac
done