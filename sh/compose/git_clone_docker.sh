#!/bin/bash

# 颜色定义
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_bai='\033[0m'
gl_zi='\033[35m'
gl_bufan='\033[96m'

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
        [29]="git@gitee.com:meimolihan/ittools.git"
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
        echo -e "${gl_zi}"
        cat <<'WELCOME'
 _____             _             
|  __ \           | |            
| |  | | ___   ___| | _____ _ __ 
| |  | |/ _ \ / __| |/ / _ \ '__|
| |__| | (_) | (__|   <  __/ |   
|_____/ \___/ \___|_|\_\___|_|      
WELCOME
        echo -e "${gl_bai}"
        # ============================================
        echo -e "${gl_bai}"
        echo -e "${gl_zi}>>> Git 克隆 Docker 项目${gl_bai}"
        echo -e "${gl_bufan}------------------------${gl_bai}"
        echo -e "${gl_huang}1.   ${gl_bai}服务管理1panel               ${gl_huang}2.   ${gl_bai}容器管理dpanel"
        echo -e "${gl_huang}3.   ${gl_bai}博客系统halo                 ${gl_huang}4.   ${gl_bai}博客系统hexo"
        echo -e "${gl_huang}5.   ${gl_bai}云文档md                     ${gl_huang}6.   ${gl_bai}配置编辑"
        echo -e "${gl_huang}7.   ${gl_bai}文档管理mindoc               ${gl_huang}8.   ${gl_bai}爱盼影视"
        echo -e "${gl_huang}9.   ${gl_bai}影视聚合libretv              ${gl_huang}10.  ${gl_bai}影视聚合moontv"
        echo -e "${gl_huang}11.  ${gl_bai}影视刮削nastools             ${gl_huang}12.  ${gl_bai}媒体服务emby"
        echo -e "${gl_huang}13.  ${gl_bai}电视助手tvhelper             ${gl_huang}14.  ${gl_bai}音乐下载musicn"
        echo -e "${gl_huang}15.  ${gl_bai}音乐播放navidrome            ${gl_huang}16.  ${gl_bai}小米音乐xiaomusic"
        echo -e "${gl_huang}17.  ${gl_bai}下载器xunlei                 ${gl_huang}18.  ${gl_bai}下载器qbittorrent"
        echo -e "${gl_huang}19.  ${gl_bai}下载器transmission           ${gl_huang}20.  ${gl_bai}视频下载metube"
        echo -e "${gl_huang}21.  ${gl_bai}网盘搜索cloud-saver          ${gl_huang}22.  ${gl_bai}网盘搜索pansou"
        echo -e "${gl_huang}23.  ${gl_bai}网盘挂载openlist             ${gl_huang}24.  ${gl_bai}文件服务nginx-file"
        echo -e "${gl_huang}25.  ${gl_bai}文件服务dufs                 ${gl_huang}26.  ${gl_bai}云盘同步taosync"
        echo -e "${gl_huang}27.  ${gl_bai}导航面板sun-panel            ${gl_huang}28.  ${gl_bai}导航面板helper"
        echo -e "${gl_huang}29.  ${gl_bai}工具箱ittools                ${gl_huang}30.  ${gl_bai}随机图片random-pic-api"
        echo -e "${gl_huang}31.  ${gl_bai}思维导图mind-map             ${gl_huang}32.  ${gl_bai}路由系统istoreos"
        echo -e "${gl_huang}33.  ${gl_bai}网络加速kspeeder             ${gl_huang}34.  ${gl_bai}网站监控uptime-kuma"
        echo -e "${gl_huang}35.  ${gl_bai}内网测速speedtest            ${gl_huang}36.  ${gl_bai}语音文字easyvoice"
        echo -e "${gl_huang}37.  ${gl_bai}容器更新watchtower           ${gl_huang}38.  ${gl_bai}格式转换reubah"
        echo -e "${gl_huang}39.  ${gl_bai}代码托管gitea                ${gl_huang}40.  ${gl_bai}远程桌面ubuntu"
        echo -e "${gl_huang}41.  ${gl_bai}远程桌面alpine               ${gl_huang}42.  ${gl_bai}终端工具easynode"
        echo -e "${gl_bufan}------------------------${gl_bai}"
        echo -e "${gl_huang}88.  ${gl_bai}自定义仓库克隆${gl_bai}"
        echo -e "${gl_huang}99.  ${gl_bai}克隆全部仓库${gl_bai}"
        echo -e "${gl_huang}0.   ${gl_bai}退出${gl_bai}"
        echo -e "${gl_bufan}------------------------${gl_bai}"
        read -e -p "$(echo -e "${gl_bufan}请输入你的选择: ${gl_bai}")" sub_choice

        case $sub_choice in
            1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42)
                echo -e "${gl_huang}正在克隆项目 $sub_choice...${gl_bai}"
                if git clone "${repositories[$sub_choice]}"; then
                    echo -e "${gl_lv}项目 $sub_choice 克隆成功！${gl_bai}"
                else
                    echo -e "${gl_hong}项目 $sub_choice 克隆失败！${gl_bai}"
                fi
                read -p "$(echo -e "${gl_bufan}按任意键继续...${gl_bai}")"
                ;;
            88)
                clear
                echo -e "${gl_bufan}------------------------${gl_bai}"
                echo -e "${gl_bufan}自定义仓库克隆${gl_bai}"
                echo -e "${gl_bufan}------------------------${gl_bai}"
                read -rp "$(echo -e "${gl_bufan}请输入Git仓库的URL或git clone命令: ${gl_bai}")" repoUrl
                if [ -z "$repoUrl" ]; then
                    echo -e "${gl_hong}错误：未输入有效的URL${gl_bai}"
                    read -p "$(echo -e "${gl_bufan}按任意键继续...${gl_bai}")"
                    continue
                fi
                local cleanUrl=${repoUrl#*git clone }
                cleanUrl=${cleanUrl//[\"\'\']/}
                local repoName=$(basename "$cleanUrl" .git)

                echo -e "${gl_bufan}------------------------${gl_bai}"
                echo -e "${gl_bufan}即将克隆仓库: $repoName${gl_bai}"
                echo -e "${gl_bufan}仓库地址: $cleanUrl${gl_bai}"
                echo -e "${gl_bufan}------------------------${gl_bai}"

                if [ -d "$repoName" ]; then
                    echo -e "${gl_huang}警告：仓库目录 '$repoName' 已存在${gl_bai}"
                    read -rp "$(echo -e "${gl_bufan}是否强制重新克隆? (y/n) ${gl_bai}")" overwrite
                    if [[ ${overwrite,,} != "y" ]]; then
                        echo -e "${gl_lv}已取消克隆${gl_bai}"
                        read -p "$(echo -e "${gl_bufan}按任意键继续...${gl_bai}")"
                        continue
                    fi
                    rm -rf "$repoName"
                fi

                git clone "$cleanUrl"
                echo -e "${gl_bufan}------------------------${gl_bai}"
                if [ $? -ne 0 ]; then
                    echo -e "${gl_hong}仓库 '$repoName' 克隆失败，请检查URL是否正确或网络连接。${gl_bai}"
                else
                    echo -e "${gl_lv}仓库 '$repoName' 克隆成功！${gl_bai}"
                fi
                read -p "$(echo -e "${gl_bufan}按任意键继续...${gl_bai}")"
                ;;
            99)
                echo -e "${gl_huang}正在克隆全部仓库...${gl_bai}"
                echo -e "${gl_huang}这可能需要一些时间，请耐心等待...${gl_bai}"
                echo -e "${gl_bufan}----------------------------------------${gl_bai}"
                
                success_count=0
                fail_count=0
                
                for i in {1..42}; do
                    repo_name=$(basename "${repositories[$i]}" .git)
                    echo -n "$(echo -e "${gl_huang}克隆 $repo_name ... ${gl_bai}")"
                    if git clone "${repositories[$i]}" 2>/dev/null; then
                        echo -e "${gl_lv}成功${gl_bai}"
                        ((success_count++))
                    else
                        echo -e "${gl_hong}失败${gl_bai}"
                        ((fail_count++))
                    fi
                done
                
                echo -e "${gl_bufan}------------------------${gl_bai}"
                echo -e "克隆完成: ${gl_lv}成功 $success_count${gl_bai}, ${gl_hong}失败 $fail_count${gl_bai}"
                read -p "$(echo -e "${gl_bufan}按任意键继续...${gl_bai}")"
                ;;
            0)
                echo -e "${gl_huang}退出程序...${gl_bai}"
                exit 0
                ;;
            *)
                echo -e "${gl_hong}无效选择，请重新输入！${gl_bai}"
                read -p "$(echo -e "${gl_bufan}按任意键继续...${gl_bai}")"
                ;;
        esac
    done
}

# 调用函数
git_Settings