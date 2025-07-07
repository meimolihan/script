#!/bin/bash

# 检测是否为root用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用root用户运行此脚本" >&2
    exit 1
fi

# 设置变量
CCAT_VERSION="1.1.0"
CCAT_BINARY="/usr/local/bin/ccat"
HTML_OUTPUT_DIR="/var/www/html"

# 安装函数
install_ccat() {
    echo "正在下载ccat v$CCAT_VERSION..."
    wget -q "https://github.com/owenthereal/ccat/releases/download/v$CCAT_VERSION/linux-amd64-$CCAT_VERSION.tar.gz" -O /tmp/ccat.tar.gz
    
    if [ $? -ne 0 ]; then
        echo "下载失败，请检查网络连接或版本号" >&2
        return 1
    fi
    
    echo "正在解压文件..."
    tar -zxf /tmp/ccat.tar.gz -C /tmp
    
    echo "正在安装ccat到系统路径..."
    cp "/tmp/linux-amd64-$CCAT_VERSION/ccat" "$CCAT_BINARY"
    chmod +x "$CCAT_BINARY"
    
    # 清理临时文件
    rm -rf /tmp/ccat.tar.gz /tmp/linux-amd64-$CCAT_VERSION
    
    echo "ccat安装完成！"
    return 0
}

# 验证安装
verify_install() {
    if [ -x "$CCAT_BINARY" ]; then
        echo "验证通过：$(ls -l $CCAT_BINARY)"
        return 0
    else
        echo "安装失败，未找到ccat二进制文件" >&2
        return 1
    fi
}

# 替换系统cat
replace_cat() {
    echo "正在配置系统别名..."
    # 创建一个在/etc/profile.d/目录下的脚本文件
    ALIAS_SCRIPT="/etc/profile.d/ccat_alias.sh"
    echo '#!/bin/bash' > "$ALIAS_SCRIPT"
    echo "alias cat='$CCAT_BINARY'" >> "$ALIAS_SCRIPT"
    chmod +x "$ALIAS_SCRIPT"
    
    echo "已创建别名脚本：$ALIAS_SCRIPT"
    echo "下次登录时将自动生效"
    echo "若要立即生效，请运行：source $ALIAS_SCRIPT"
    return 0
}

# 生成HTML示例
generate_html() {
    echo "正在生成HTML示例..."
    
    # 创建输出目录
    mkdir -p "$HTML_OUTPUT_DIR"
    
    # 生成示例HTML
    ccat --html /etc/fstab /etc/os-release > "$HTML_OUTPUT_DIR/ccat_example.html"
    
    if [ $? -eq 0 ]; then
        echo "HTML示例已生成：$HTML_OUTPUT_DIR/ccat_example.html"
        
        # 检测Web服务器
        if command -v httpd &>/dev/null || command -v nginx &>/dev/null; then
            echo "Web服务器已安装，可通过浏览器访问："
            echo "http://$(hostname -I | awk '{print $1}')/ccat_example.html"
        else
            echo "警告：未检测到Web服务器，请先安装Apache或Nginx以查看HTML输出"
        fi
        return 0
    else
        echo "生成HTML失败" >&2
        return 1
    fi
}

# 主函数
main() {
    echo "===== 开始安装ccat ====="
    
    install_ccat && \
    verify_install && \
    replace_cat && \
    generate_html
    
    if [ $? -eq 0 ]; then
        echo "===== ccat安装配置完成 ====="
        echo "使用方法："
        echo "  1. 直接使用: ccat filename"
        echo "  2. 使用别名: cat filename (需重启会话或执行 source /etc/profile.d/ccat_alias.sh)"
        echo "  3. 生成HTML: ccat --html file1 file2 > output.html"
    else
        echo "===== 安装过程中出现错误 ====="
        exit 1
    fi
}

# 执行主函数
main