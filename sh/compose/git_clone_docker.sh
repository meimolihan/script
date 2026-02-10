#!/bin/bash

# 颜色变量定义
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# 日志函数定义
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# 无效输入处理
handle_invalid_input() {
    echo -ne "\r${gl_huang}无效的输入,请重新输入! ${gl_zi}1${gl_huang}秒后返回"
    sleep 1
    echo -ne "\r${gl_lv}无效的输入,请重新输入! ${gl_zi}0${gl_lv}秒后返回"
    sleep 0.5
    return 2
}

# 操作完成提示
break_end() {
    echo -e "${gl_lv}操作完成${gl_bai}"
    echo -e "${gl_bai}按任意键继续${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}\c"
    read -r -n 1 -s -r -p ""
    echo ""
    clear
}

# 退出脚本
exit_script() {
    clear
    exit 0
}

# Docker项目克隆函数
# 克隆Docker仓库主函数
git_clone_docker_projects() {
    # 定义所有仓库的数组
    declare -A repositories=(
        [1]="git@gitee.com:meimolihan/1panel.git"
        [2]="git@gitee.com:meimolihan/dpanel.git"
        [3]="git@gitee.com:meimolihan/sun-panel.git"
        [4]="git@gitee.com:meimolihan/sun-panel-helper.git"
        [5]="git@gitee.com:meimolihan/halo.git"
        [6]="git@gitee.com:meimolihan/hexo.git"
        [7]="git@gitee.com:meimolihan/md.git"
        [8]="git@gitee.com:meimolihan/mindoc.git"
        [9]="git@gitee.com:meimolihan/aipan.git"
        [10]="git@gitee.com:meimolihan/libretv.git"
        [11]="git@gitee.com:meimolihan/moontv.git"
        [12]="git@gitee.com:meimolihan/nastools.git"
        [13]="git@gitee.com:meimolihan/emby.git"
        [14]="git@gitee.com:meimolihan/tvhelper.git"
        [15]="git@gitee.com:meimolihan/musicn.git"
        [16]="git@gitee.com:meimolihan/navidrome.git"
        [17]="git@gitee.com:meimolihan/xiaomusic.git"
        [18]="git@gitee.com:meimolihan/xunlei.git"
        [19]="git@gitee.com:meimolihan/qbittorrent.git"
        [20]="git@gitee.com:meimolihan/transmission.git"
        [21]="git@gitee.com:meimolihan/metube.git"
        [22]="git@gitee.com:meimolihan/cloud-saver.git"
        [23]="git@gitee.com:meimolihan/pansou.git"
        [24]="git@gitee.com:meimolihan/openlist.git"
        [25]="git@gitee.com:meimolihan/nginx-file.git"
        [26]="git@gitee.com:meimolihan/dufs.git"
        [27]="git@gitee.com:meimolihan/taosync.git"
        [28]="git@gitee.com:meimolihan/nginx-dock-builder.git"
        [29]="git@gitee.com:meimolihan/it-tools.git"
        [30]="git@gitee.com:meimolihan/random-pic-api.git"
        [31]="git@gitee.com:meimolihan/mind-map.git"
        [32]="git@gitee.com:meimolihan/easyvoice.git"
        [33]="git@gitee.com:meimolihan/reubah.git"
        [34]="git@gitee.com:meimolihan/easynode.git"
        [35]="git@gitee.com:meimolihan/beszel.git"
        [36]="git@gitee.com:meimolihan/istoreos.git"
        [37]="git@gitee.com:meimolihan/kspeeder.git"
        [38]="git@gitee.com:meimolihan/uptime-kuma.git"
        [39]="git@gitee.com:meimolihan/speedtest.git"
        [40]="git@gitee.com:meimolihan/watchtower.git"
        [41]="git@gitee.com:meimolihan/gitea.git"
        [42]="git@gitee.com:meimolihan/webtop-ubuntu.git"
        [43]="git@gitee.com:meimolihan/webtop-alpine.git"
    )

    while true; do
        clear
        echo -e "${gl_zi}>>> Git克隆Docker仓库${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        echo -e "${gl_bai}当前工作目录: ${gl_huang}$(pwd)${gl_bai}"
        echo -e ""
        ls --color=auto -x
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        echo -e ""
        echo -e "${gl_bufan}—————————————————— ${gl_huang}面板管理类${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}1.   ${gl_bai}服务管理1panel         ${gl_bufan}2.   ${gl_bai}容器管理dpanel${gl_bai}"
        echo -e "${gl_bufan}3.   ${gl_bai}导航面板sun-panel      ${gl_bufan}4.   ${gl_bai}导航面板helper${gl_bai}"

        echo -e "${gl_bufan}—————————————————— ${gl_huang}博客与文档${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}5.   ${gl_bai}博客系统halo           ${gl_bufan}6.   ${gl_bai}博客系统hexo${gl_bai}"
        echo -e "${gl_bufan}7.   ${gl_bai}云文档md               ${gl_bufan}8.   ${gl_bai}文档管理mindoc${gl_bai}"

        echo -e "${gl_bufan}—————————————————— ${gl_huang}影视媒体类${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}9.   ${gl_bai}爱盼影视               ${gl_bufan}10.  ${gl_bai}影视聚合libretv${gl_bai}"
        echo -e "${gl_bufan}11.  ${gl_bai}影视聚合moontv         ${gl_bufan}12.  ${gl_bai}影视刮削nastools${gl_bai}"
        echo -e "${gl_bufan}13.  ${gl_bai}媒体服务emby           ${gl_bufan}14.  ${gl_bai}电视助手tvhelper${gl_bai}"

        echo -e "${gl_bufan}—————————————————— ${gl_huang}音乐播放类${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}15.  ${gl_bai}音乐下载musicn         ${gl_bufan}16.  ${gl_bai}音乐播放navidrome${gl_bai}"
        echo -e "${gl_bufan}17.  ${gl_bai}小米音乐xiaomusic"

        echo -e "${gl_bufan}—————————————————— ${gl_huang}下载工具类${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}18.  ${gl_bai}下载器xunlei           ${gl_bufan}19.  ${gl_bai}下载器qbittorrent${gl_bai}"
        echo -e "${gl_bufan}20.  ${gl_bai}下载器transmission     ${gl_bufan}21.  ${gl_bai}视频下载metube${gl_bai}"

        echo -e "${gl_bufan}—————————————————— ${gl_huang}网盘与文件${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}22.  ${gl_bai}网盘搜索cloud-saver    ${gl_bufan}23.  ${gl_bai}网盘搜索pansou${gl_bai}"
        echo -e "${gl_bufan}24.  ${gl_bai}网盘挂载openlist       ${gl_bufan}25.  ${gl_bai}文件服务nginx-file${gl_bai}"
        echo -e "${gl_bufan}26.  ${gl_bai}文件服务dufs           ${gl_bufan}27.  ${gl_bai}云盘同步taosync${gl_bai}"

        echo -e "${gl_bufan}—————————————————— ${gl_huang}实用工具类${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}28.  ${gl_bai}配置编辑               ${gl_bufan}29.  ${gl_bai}工具箱ittools${gl_bai}"
        echo -e "${gl_bufan}30.  ${gl_bai}随机图片random-pic-api ${gl_bufan}31.  ${gl_bai}思维导图mind-map${gl_bai}"
        echo -e "${gl_bufan}32.  ${gl_bai}语音文字easyvoice      ${gl_bufan}33.  ${gl_bai}格式转换reubah${gl_bai}"
        echo -e "${gl_bufan}34.  ${gl_bai}终端工具easynode       ${gl_bufan}35.  ${gl_bai}服务器监控beszel"

        echo -e "${gl_bufan}—————————————————— ${gl_huang}网络与系统${gl_bufan} ——————————————————${gl_bai}"
        echo -e "${gl_bufan}36.  ${gl_bai}路由系统istoreos       ${gl_bufan}37.  ${gl_bai}网络加速kspeeder${gl_bai}"
        echo -e "${gl_bufan}38.  ${gl_bai}网站监控uptime-kuma    ${gl_bufan}39.  ${gl_bai}内网测速speedtest${gl_bai}"
        echo -e "${gl_bufan}40.  ${gl_bai}容器更新watchtower     ${gl_bufan}41.  ${gl_bai}代码托管gitea${gl_bai}"
        echo -e "${gl_bufan}42.  ${gl_bai}远程桌面ubuntu         ${gl_bufan}43.  ${gl_bai}远程桌面alpine${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        echo -e "${gl_bufan}88.  ${gl_bai}自定义仓库克隆         ${gl_bufan}99.  ${gl_bai}克隆全部仓库${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        echo -e "${gl_hong}0.   ${gl_bai}退出脚本${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        
        read -r -e -p "$(echo -e "请输入你要克隆项目的序号: ")" sub_choice

        case $sub_choice in
        1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43)
            clear
            log_info "正在克隆项目 $sub_choice${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            if git clone "${repositories[$sub_choice]}"; then
                log_ok "项目 $sub_choice 克隆成功！"
                echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            else
                log_error "项目 $sub_choice 克隆失败！"
                echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            fi
            break_end
            ;;
        88)
            clear
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            log_info "自定义仓库克隆"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            read -r -rp "$(echo -e "${gl_bai}请输入Git仓库的${gl_bufan}URL${gl_bai}或${gl_bufan}git clone${gl_bai}命令: ")" repoUrl
            if [ -z "$repoUrl" ]; then
                log_error "未输入有效的URL"
                break_end
                continue
            fi
            local cleanUrl=${repoUrl#*git clone }
            cleanUrl=${cleanUrl//[\"\'\']/}
            local repoName=$(basename "$cleanUrl" .git)

            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            log_info "即将克隆仓库: $repoName"
            log_info "仓库地址: $cleanUrl"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"

            if [ -d "$repoName" ]; then
                log_warn "仓库目录 '$repoName' 已存在"
                read -r -rp "$(echo -e "${gl_bufan}是否强制重新克隆? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" overwrite
                if [[ ${overwrite,,} != "y" ]]; then
                    log_info "已取消克隆"
                    break_end
                    continue
                fi
                rm -rf "$repoName"
            fi

            git clone "$cleanUrl"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            if [ $? -ne 0 ]; then
                log_error "仓库 '$repoName' 克隆失败，请检查URL是否正确或网络连接"
            else
                log_ok "仓库 '$repoName' 克隆成功！"
            fi
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            break_end
            ;;
        99)
            log_info "正在克隆全部仓库${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
            log_warn "这可能需要一些时间，请耐心等待${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"

            success_count=0
            fail_count=0

            for i in {1..43}; do
                repo_name=$(basename "${repositories[$i]}" .git)
                echo -n "$(echo -e "${gl_huang}克隆 $repo_name ${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai} ${gl_bai}")"
                if git clone "${repositories[$i]}" 2>/dev/null; then
                    echo -e "${gl_lv}成功${gl_bai}"
                    ((success_count++))
                else
                    echo -e "${gl_hong}失败${gl_bai}"
                    ((fail_count++))
                fi
            done

            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            log_ok "克隆完成: 成功 $success_count, 失败 $fail_count"
            break_end
            ;;
        0|00|000|0000) 
            exit_script ;;
        *) 
            handle_invalid_input ;;
        esac
    done
}


# 主程序入口
main() {
    clear
    echo -e ""
    echo -e "${gl_bai}当前工作目录: ${gl_huang}$(pwd)${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    ls --color=auto -x
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"

    # 获取工作目录
    read -r -e -p "$(echo -e "${gl_bai}请输入工作目录 (回车当前目录克隆，输入${gl_bufan}0${gl_bai}退出): ")" work_dir

    # 处理输入
    if [[ "$work_dir" == "0" ]]; then
        log_warn "已取消操作"
        exit_script
    elif [[ -z "$work_dir" ]]; then
        work_dir="."
        log_info "使用当前目录: ${gl_huang}$(pwd)${gl_bai}"
    elif [[ ! -d "$work_dir" ]]; then
        # 路径不存在，询问是否创建
        log_warn "目录不存在: $work_dir"
        read -r -e -p "$(echo -e "${gl_bai}是否创建此目录? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" create_choice

        case "$create_choice" in
        y|Y|yes|YES)
            mkdir -p "$work_dir"
            if [ $? -eq 0 ]; then
                log_ok "目录创建成功: $work_dir"
            else
                log_error "目录创建失败: $work_dir"
                exit_script
            fi
            ;;
        *)
            log_warn "已取消操作"
            exit_script
            ;;
        esac
    fi

    # 切换到工作目录
    cd "$work_dir" || {
        log_error "无法切换到目录: $work_dir"
        exit_script
    }
    
    # 执行克隆
    git_clone_docker_projects
}

# 执行主程序
main