#!/bin/bash
sh_download() {
    local script_path="/etc/profile.d/linux-check.sh"

    # 1. 判断系统类型
    if [ -s /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            istoreos) ISTOREOS=1 ;;
            *)        ISTOREOS=0 ;;
        esac
    else
        ISTOREOS=0
    fi

    # 2. 选择下载地址
    if [ "$ISTOREOS" = 1 ]; then
        URL="https://gitee.com/meimolihan/script/raw/master/sh/istoreos/linux-check.sh"
    else
        URL="https://gitee.com/meimolihan/script/raw/master/sh/linux/linux-check.sh"
    fi

    # 3. 下载脚本
    # echo "Downloading linux-check.sh for ${ID:-linux} ..."
    curl -sS -o "$script_path" "$URL"
    chmod +x "$script_path"

    # 4. 根据系统类型创建快捷命令
    if [ "$ISTOREOS" = 1 ]; then
        # iStoreOS：alias 方式，写入 /etc/profile.d/istoreos-m.sh 保证登录自动生效
        echo "alias m='$script_path'" > /etc/profile.d/istoreos-m.sh
        chmod +x /etc/profile.d/istoreos-m.sh
        # 当前 shell 立即生效
        alias m="$script_path"
    else
        # 非 iStoreOS：软链到 /usr/local/bin
        ln -sf "$script_path" /usr/local/bin/m
    fi

    # 5. 立即执行一次（参数透传）
    "$script_path" "$@"
}

sh_download "$@"