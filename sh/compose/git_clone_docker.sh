#!/bin/bash

# 颜色定义
gl_kjlan="\033[36m"    # 青色
gl_bai="\033[37m"      # 白色
gl_reset="\033[0m"     # 重置颜色
GREEN="\033[32m"       # 绿色
RED="\033[31m"         # 红色
YELLOW="\033[33m"      # 黄色
NC="\033[0m"           # 重置颜色

git_Settings() {
    # 定义所有仓库的数组
    declare -A repositories=(
        [1]="git@gitee.com:meimolihan/1panel.git"
        [2]="git@gitee.com:meimolihan/dpanel.git"
        [3]="git@gitee.com:meimolihan/halo.git"
        [4]="git@gitee.com:meimolihan/hexo.git"
        [5]="git@gitee.com:meimolihan/md.git"
        [6]="git@gitee.com:meimolihan/nginx-dock-builder.git"
        [7]="git@gitee.com:meimolihan/mindoc.git"
        [8]="git@gitee.com:meimolihan/aipan.git"
        [9]="git@gitee.com:meimolihan/libretv.git"
        [10]="git@gitee.com:meimolihan/moontv.git"
        [11]="git@gitee.com:meimolihan/nastools.git"
        [12]="git@gitee.com:meimolihan/emby.git"
        [13]="git@gitee.com:meimolihan/tvhelper.git"
        [14]="git@gitee.com:meimolihan/musicn.git"
        [15]="git@gitee.com:meimolihan/navidrome.git"
        [16]="git@gitee.com:meimolihan/xiaomusic.git"
        [17]="git@gitee.com:meimolihan/xunlei.git"
        [18]="git@gitee.com:meimolihan/qbittorrent.git"
        [19]="git@gitee.com:meimolihan/transmission.git"
        [20]="git@gitee.com:meimolihan/metube.git"
        [21]="git@gitee.com:meimolihan/cloud-saver.git"
        [22]="git@gitee.com:meimolihan/pansou.git"
        [23]="git@gitee.com:meimolihan/openlist.git"
        [24]="git@gitee.com:meimolihan/nginx-file.git"
        [25]="git@gitee.com:meimolihan/dufs.git"
        [26]="git@gitee.com:meimolihan/taosync.git"
        [27]="git@gitee.com:meimolihan/sun-panel.git"
        [28]="git@gitee.com:meimolihan/sun-panel-helper.git"
        [29]="git@gitee.com:meimolihan/it-tools.git"
        [30]="git@gitee.com:meimolihan/random-pic-api.git"
        [31]="git@gitee.com:meimolihan/mind-map.git"
        [32]="git@gitee.com:meimolihan/istoreos.git"
        [33]="git@gitee.com:meimolihan/kspeeder.git"
        [34]="git@gitee.com:meimolihan/uptime-kuma.git"
        [35]="git@gitee.com:meimolihan/speedtest.git"
        [36]="git@gitee.com:meimolihan/easyvoice.git"
        [37]="git@gitee.com:meimolihan/watchtower.git"
        [38]="git@gitee.com:meimolihan/reubah.git"
        [39]="git@gitee.com:meimolihan/gitea.git"
        [40]="git@gitee.com:meimolihan/webtop-ubuntu.git"
        [41]="git@gitee.com:meimolihan/webtop-alpine.git"
        [42]="git@gitee.com:meimolihan/easynode.git"
    )

    while true; do
        clear
        # ================== 欢迎语 ==================
        echo -e "\033[1;35m"
        cat <<'WELCOME'
 _____             _             
|  __ \           | |            
| |  | | ___   ___| | _____ _ __ 
| |  | |/ _ \ / __| |/ / _ \ '__|
| |__| | (_) | (__|   <  __/ |   
|_____/ \___/ \___|_|\_\___|_|      

WELCOME
        echo -e "\033[0m"
        # ============================================
        echo -e "${gl_kjlan}========================================${gl_reset}"
        echo -e "Git 克隆 Docker 项目"
        echo -e "${gl_kjlan}========================================${gl_reset}"
        echo -e "${gl_kjlan}1.   ${gl_bai}服务管理1panel               ${gl_kjlan}2.   ${gl_bai}容器管理dpanel${gl_reset}"
        echo -e "${gl_kjlan}3.   ${gl_bai}博客系统halo                 ${gl_kjlan}4.   ${gl_bai}博客系统hexo${gl_reset}"
        echo -e "${gl_kjlan}5.   ${gl_bai}云文档md                     ${gl_kjlan}6.   ${gl_bai}配置编辑${gl_reset}"
        echo -e "${gl_kjlan}7.   ${gl_bai}文档管理mindoc               ${gl_kjlan}8.   ${gl_bai}爱盼影视${gl_reset}"
        echo -e "${gl_kjlan}9.   ${gl_bai}影视聚合libretv              ${gl_kjlan}10.  ${gl_bai}影视聚合moontv${gl_reset}"
        echo -e "${gl_kjlan}11.  ${gl_bai}影视刮削nastools             ${gl_kjlan}12.  ${gl_bai}媒体服务emby${gl_reset}"
        echo -e "${gl_kjlan}13.  ${gl_bai}电视助手tvhelper             ${gl_kjlan}14.  ${gl_bai}音乐下载musicn${gl_reset}"
        echo -e "${gl_kjlan}15.  ${gl_bai}音乐播放navidrome            ${gl_kjlan}16.  ${gl_bai}小米音乐xiaomusic${gl_reset}"
        echo -e "${gl_kjlan}17.  ${gl_bai}下载器xunlei                 ${gl_kjlan}18.  ${gl_bai}下载器qbittorrent${gl_reset}"
        echo -e "${gl_kjlan}19.  ${gl_bai}下载器transmission           ${gl_kjlan}20.  ${gl_bai}视频下载metube${gl_reset}"
        echo -e "${gl_kjlan}21.  ${gl_bai}网盘搜索cloud-saver          ${gl_kjlan}22.  ${gl_bai}网盘搜索pansou${gl_reset}"
        echo -e "${gl_kjlan}23.  ${gl_bai}网盘挂载openlist             ${gl_kjlan}24.  ${gl_bai}文件服务nginx-file${gl_reset}"
        echo -e "${gl_kjlan}25.  ${gl_bai}文件服务dufs                 ${gl_kjlan}26.  ${gl_bai}云盘同步taosync${gl_reset}"
        echo -e "${gl_kjlan}27.  ${gl_bai}导航面板sun-panel            ${gl_kjlan}28.  ${gl_bai}导航面板helper${gl_reset}"
        echo -e "${gl_kjlan}29.  ${gl_bai}工具箱it-tools               ${gl_kjlan}30.  ${gl_bai}随机图片random-pic-api${gl_reset}"
        echo -e "${gl_kjlan}31.  ${gl_bai}思维导图mind-map             ${gl_kjlan}32.  ${gl_bai}路由系统istoreos${gl_reset}"
        echo -e "${gl_kjlan}33.  ${gl_bai}网络加速kspeeder             ${gl_kjlan}34.  ${gl_bai}网站监控uptime-kuma${gl_reset}"
        echo -e "${gl_kjlan}35.  ${gl_bai}内网测速speedtest            ${gl_kjlan}36.  ${gl_bai}语音文字easyvoice${gl_reset}"
        echo -e "${gl_kjlan}37.  ${gl_bai}容器更新watchtower           ${gl_kjlan}38.  ${gl_bai}格式转换reubah${gl_reset}"
        echo -e "${gl_kjlan}39.  ${gl_bai}代码托管gitea                ${gl_kjlan}40.  ${gl_bai}远程桌面ubuntu${gl_reset}"
        echo -e "${gl_kjlan}41.  ${gl_bai}远程桌面alpine               ${gl_kjlan}42.  ${gl_bai}终端工具easynode${gl_reset}"
        echo -e "${gl_kjlan}------------------------${gl_reset}"
        echo -e "${gl_kjlan}88.  ${gl_bai}自定义仓库克隆${gl_reset}"
        echo -e "${gl_kjlan}99.  ${gl_bai}克隆全部仓库${gl_reset}"
        echo -e "${gl_kjlan}0.   ${gl_bai}退出${gl_reset}"
        echo -e "${gl_kjlan}========================================${gl_reset}"
        read -e -p "请输入你的选择: " sub_choice

        case $sub_choice in
            1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42)
                echo "正在克隆项目 $sub_choice..."
                if git clone "${repositories[$sub_choice]}"; then
                    echo "项目 $sub_choice 克隆成功！"
                else
                    echo "项目 $sub_choice 克隆失败！"
                fi
                read -p "按任意键继续..."
                ;;
            88)
                clear
                echo -e "${GREEN}==================================${NC}"
                echo -e "${GREEN}        自定义仓库克隆        ${NC}"
                echo -e "${GREEN}==================================${NC}"
                read -rp "请输入Git仓库的URL或git clone命令: " repoUrl
                if [ -z "$repoUrl" ]; then
                    echo -e "${RED}错误：未输入有效的URL${NC}"
                    read -p "按任意键继续..."
                    continue
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
                        read -p "按任意键继续..."
                        continue
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
                read -p "按任意键继续..."
                ;;
            99)
                echo "正在克隆全部仓库..."
                echo "这可能需要一些时间，请耐心等待..."
                echo "----------------------------------------"
                
                success_count=0
                fail_count=0
                
                for i in {1..42}; do
                    repo_name=$(basename "${repositories[$i]}" .git)
                    echo -n "克隆 $repo_name ... "
                    if git clone "${repositories[$i]}" 2>/dev/null; then
                        echo -e "\033[32m成功\033[0m"
                        ((success_count++))
                    else
                        echo -e "\033[31m失败\033[0m"
                        ((fail_count++))
                    fi
                done
                
                echo "----------------------------------------"
                echo -e "克隆完成: \033[32m成功 $success_count\033[0m, \033[31m失败 $fail_count\033[0m"
                read -p "按任意键继续..."
                ;;
            0)
                echo "退出程序..."
                exit 0
                ;;
            *)
                echo "无效选择，请重新输入！"
                read -p "按任意键继续..."
                ;;
        esac
    done
}

# 调用函数
git_Settings