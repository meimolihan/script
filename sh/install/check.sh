#!/bin/bash
sh_download() {
    local script_path="/etc/profile.d/linux-check.sh"
    local link_path="/usr/bin/g"
    
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
    
    # 显示系统类型
    if [ "$ISTOREOS" = 1 ]; then
        echo "检测到 iStoreOS 系统"
    else
        echo "检测到非 iStoreOS 系统"
    fi
    
    # 2. 选择下载地址
    if [ "$ISTOREOS" = 1 ]; then
        URL="https://gitee.com/meimolihan/script/raw/master/sh/tool/istoreos-check.sh"
    else
        URL="https://gitee.com/meimolihan/script/raw/master/sh/tool/linux-check.sh"
    fi
    
    # 3. 清理可能存在的旧别名文件
    if [ -f "/etc/profile.d/istoreos-check.sh" ]; then
        echo "清理旧别名文件..."
        rm -f /etc/profile.d/istoreos-check.sh
    fi
    
    # 4. 下载脚本
    echo "正在下载脚本..."
    if ! curl -sS -o "$script_path" "$URL"; then
        echo "错误：下载失败，请检查网络连接"
        return 1
    fi
    
    # 检查下载的文件是否有效
    if [ ! -s "$script_path" ]; then
        echo "错误：下载的文件为空或无效"
        return 1
    fi
    
    chmod +x "$script_path"
    echo "脚本已保存到: $script_path"
    
    # 5. 创建快捷命令（统一使用软链接，更可靠）
    echo "创建快捷命令..."
    
    # 删除可能已存在的软链接
    if [ -L "$link_path" ] || [ -f "$link_path" ]; then
        rm -f "$link_path"
    fi
    
    # 创建软链接
    if ln -sf "$script_path" "$link_path"; then
        echo "快捷命令已创建: 'g' -> $script_path"
    else
        echo "警告：创建软链接失败，尝试其他路径..."
        # 尝试 /usr/local/bin
        if ln -sf "$script_path" "/usr/local/bin/g"; then
            link_path="/usr/local/bin/g"
            echo "快捷命令已创建: '/usr/local/bin/g' -> $script_path"
        else
            echo "错误：无法创建软链接，请手动执行: $script_path"
        fi
    fi
    
    # 6. 检查 PATH 是否包含软链接路径
    local link_dir=$(dirname "$link_path")
    if ! echo "$PATH" | tr ':' '\n' | grep -q "^$(echo "$link_dir" | sed 's/[\/&]/\\&/g')$"; then
        echo "注意：$link_dir 不在 PATH 中，可能需要添加到 PATH 或使用完整路径"
    else
        echo "检查: 'g' 命令已在 PATH 中"
    fi
    
    # 7. 测试命令是否可用
    echo -e "\n测试快捷命令..."
    if command -v g >/dev/null 2>&1; then
        echo "✓ 快捷命令 'g' 已可用"
    else
        echo "⚠  'g' 命令未找到，可能需要重新登录或执行: source /etc/profile"
        echo "   或者直接使用: $script_path"
    fi
    
    # 8. 立即执行一次（参数透传）
    echo -e "\n执行脚本..."
    if [ -x "$script_path" ]; then
        "$script_path" "$@"
    else
        echo "错误：脚本不可执行"
        return 1
    fi
}

# 如果脚本被直接执行，而不是被source
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    sh_download "$@"
fi