#!/usr/bin/env bash
# create_nginx_conf.sh
# 功能：自动生成 Nginx 反向代理配置文件和相关的帮助/错误页面
# 作者：Mobufan
# 版本：1.1

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 输出函数
print_color() {
    echo -e "${2}${1}${NC}"
}

# ========== 预设端口表 ==========
declare -A PRESET_PORTS=(
    [transmission]=9091
    [halo]=8090
    [emby]=8896
    [fntv-302]=8095
    [md]=9900
    [xiaomusic]=8393
    [metube]=8081
    [random-pic-api]=8588
    [easynode]=8082
    [allinssl]=7979
    [ittools]=8088
    [sun-panel]=3002
    [sun-panel-helper]=33002
    [openlist]=5244
    [taosync]=8023
    [xunlei]=2345
    [qbittorrent]=8080
    [musicn]=7478
    [dufs]=5000
    [nastools]=3000
    [jackett]=9117
    [aipan]=5055
    [libretv]=8899
    [moontv]=3133
    [cloud-saver]=8008
    [pansou]=8110
    [panhub]=3020
    [mind-map]=8256
    [easyvoice]=3780
    [dpanel]=8807
    [kspeeder]=5003
    [speedtest]=7878
    [navidrome]=4533
    [uptime-kuma]=3001
    [chinesesubfinder]=19035
    [nginx-file]=18080
    # 想加继续往下写
)

print_separator() {
    echo -e "${CYAN}==================================================${NC}"
}

# 安全的输入函数，支持退格键
safe_input() {
    local prompt="$1"
    local default_value="$2"
    local input_value=""
    
    while true; do
        read -rep "$prompt" input_value
        # 如果用户只按回车，使用默认值
        if [[ -z "$input_value" && -n "$default_value" ]]; then
            echo "$default_value"
            return 0
        elif [[ -n "$input_value" ]]; then
            echo "$input_value"
            return 0
        else
            print_color "输入不能为空，请重新输入" "$YELLOW"
        fi
    done
}

# 智能端口输入：优先匹配预设，回车用预设，无预设则 8888
smart_port_input(){
    local svc="$1"                       # 服务名
    local default_port="${PRESET_PORTS[$svc]:-8888}"  # 取预设，没有就 8888
    local input_port

    read -rep "请输入后端端口（默认端口 ${default_port}）: " input_port
    # 空输入 → 用默认值
    [[ -z "$input_port" ]] && input_port="$default_port"
    echo "$input_port"
}

# URL输入函数（允许为空）
safe_url_input() {
    local prompt="$1"
    local input_value=""
    
    read -rep "$prompt" input_value
    echo "$input_value"
}

# 显示欢迎信息
print_separator
print_color "Nginx 配置生成脚本" "$PURPLE"
print_color "作者: Mobufan" "$BLUE"
print_color "功能: 自动创建Nginx反向代理配置和相关页面" "$GREEN"
print_separator
echo ""

# ========== 1. 服务名称配置 ==========
print_separator
print_color "步骤 1/9: 服务名称配置" "$YELLOW"
SVC_NAME=$(safe_input "请输入服务名称（默认名称 aaaa）: " "aaaa")
print_color "✓ 服务名称: $SVC_NAME" 
print_color "✓ 说明页面 - 路径和名称：/etc/nginx/html/help/${SVC_NAME}_help" "$GREEN"
print_color "✓ 错误页面 - 路径和名称：/etc/nginx/html/error/${SVC_NAME}_error" "$GREEN"
print_color "✓ 配置文件 - 路径和名称：/etc/nginx/conf.d/${SVC_NAME}.conf" "$GREEN"
echo ""

# ========== 2. 子域名前缀 ==========
print_separator
print_color "步骤 2/9: 域名配置" "$YELLOW"
SUB_DOM=$(safe_input "请输入域名前缀（默认前缀 ${SVC_NAME}）：" "$SVC_NAME")
DOMAIN="${SUB_DOM}.mobufan.eu.org"
print_color "✓ 域名: $DOMAIN" "$GREEN"
echo ""

# ========== 3. 后端服务配置 ==========
print_separator
print_color "步骤 3/9: 后端服务配置" "$YELLOW"
BACKEND_IP=$(safe_input "请输入后端 IP（默认地址 10.10.10.251）: " "10.10.10.251")
print_color "✓ 后端 IP: $BACKEND_IP" "$GREEN"
echo ""

# ========== 4. 后端端口配置 ==========
print_separator
print_color "步骤 4/9: 后端端口配置" "$YELLOW"
BACKEND_PORT=$(smart_port_input "$SVC_NAME")
print_color "✓ 后端端口: $BACKEND_PORT" "$GREEN"
echo ""

# ========== 5. 生成 Nginx 配置文件 ==========
print_separator
print_color "步骤 5/9: 生成 Nginx 配置文件" "$YELLOW"
CONF_FILE="/etc/nginx/conf.d/${SVC_NAME}.conf"

cat > "${CONF_FILE}" <<EOF
server {
    listen 666 ssl;
    listen [::]:666 ssl;
    http2 on;

    server_name ${DOMAIN};
    ssl_certificate /etc/nginx/keyfile/mobufan.eu.org.pem;
    ssl_certificate_key /etc/nginx/keyfile/mobufan.eu.org.key;
    client_max_body_size 1024G;

    # 定义日志文件路径和格式
    error_log /etc/nginx/log/mobufan.eu.org/${SVC_NAME}_error.log;               # 错误日志
    access_log /etc/nginx/log/mobufan.eu.org/${SVC_NAME}_access.log mobufan_log; # 访问日志

    # 错误页面
    error_page 404 500 502 503 504 /index.html;
    location = /index.html {
        root   /etc/nginx/html/error/${SVC_NAME}_error;
        sub_filter_once on;
        sub_filter '<head>' '<head><link rel="icon" href="/error-favicon.ico" type="image/x-icon">';
    }
    location = /error-favicon.ico {
        alias /etc/nginx/html/error/${SVC_NAME}_error/favicon.ico;
        access_log off;
    }

    location / {
        proxy_pass http://${BACKEND_IP}:${BACKEND_PORT};
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        proxy_set_header Range \$http_range;
        proxy_set_header If-Range \$http_if_range;
        proxy_connect_timeout 30s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        proxy_buffering on;
        proxy_buffer_size 16k;
        proxy_buffers 8 32k;
        proxy_busy_buffers_size 64k;
        proxy_max_temp_file_size 1024m;
        proxy_http_version 1.1;
        proxy_redirect off;
        proxy_cache_bypass \$http_upgrade;
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-XSS-Protection "1; mode=block";
        add_header Referrer-Policy "strict-origin-when-cross-origin";
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
    }

    # 说明页面
    location ^~ /h {
        alias /etc/nginx/html/help/${SVC_NAME}_help;
        index index.html;
        try_files \$uri \$uri/ =404;
        access_log off;
    }
}
EOF

print_color "✓ 已生成配置文件：${CONF_FILE}" "$GREEN"
echo ""

# ========== 6. 创建日志目录 ==========
print_separator
print_color "步骤 6/9: 创建日志目录" "$YELLOW"
# ========== 确保日志目录存在且 nginx 可写 ==========
LOG_DIR="/etc/nginx/log/mobufan.eu.org"
print_color "正在创建日志目录并授权 ..." "$CYAN"

# 1. 创建目录（-p 无则新建，有则跳过）
sudo mkdir -p "$LOG_DIR" || { print_color "✗ 创建日志目录失败！" "$RED"; exit 1; }

# 2. 获取 nginx 运行用户（兼容 Debian/Ubuntu 与 RHEL/CentOS）
NGX_USER=$(nginx -V 2>&1 | grep -oP 'user=\K\w+' || echo "nginx")
# 如果上面没抓到，再读配置文件
[[ -z "$NGX_USER" || "$NGX_USER" == "nginx" ]] && \
    NGX_USER=$(grep -m1 -E '^user[[:space:]]+' /etc/nginx/nginx.conf | awk '{print $2}' | tr -d ';')

# 3. 赋予目录权限
sudo chown -R "$NGX_USER:$NGX_USER" "$LOG_DIR"
sudo chmod 755 "$LOG_DIR"

print_color "✓ 日志目录已创建/授权：$LOG_DIR （user: $NGX_USER）" "$GREEN"
echo ""

# ========== 7. 复制并替换说明/错误页面模板 ==========
print_separator
print_color "步骤 7/9: 生成帮助和错误页面" "$YELLOW"
HELP_SRC="/etc/nginx/html/help/test-xxx_help"
HELP_DST="/etc/nginx/html/help/${SVC_NAME}_help"
ERROR_SRC="/etc/nginx/html/error/test-xxx_error"
ERROR_DST="/etc/nginx/html/error/${SVC_NAME}_error"

# 拷贝模板
print_color "正在复制模板文件..." "$CYAN"
sudo rsync -a --delete "$HELP_SRC"/ "$HELP_DST"/
sudo rsync -a --delete "$ERROR_SRC"/ "$ERROR_DST"/

# 批量替换模板里的占位符
print_color "正在替换模板变量..." "$CYAN"
sudo sed -i "s/test-xxx/${SVC_NAME}/g" "$HELP_DST/index.html"
sudo sed -i "s/test-xxx/${SVC_NAME}/g" "$ERROR_DST/index.html"
sudo sed -i "s/test-yyy/${SUB_DOM}/g" "$ERROR_DST/index.html"
echo ""

# ========== 8. 修改帮助文档 URL ==========
print_separator
print_color "步骤 8/9: 修改帮助文档 URL（按回车跳过设置）" "$YELLOW"
HEXO_URL=$(safe_url_input "请输入 Hexo 地址: ")
HUGO_URL=$(safe_url_input "请输入 Hugo 地址: ")
HALO_URL=$(safe_url_input "请输入 Halo 地址: ")

if [[ -n "$HEXO_URL" || -n "$HUGO_URL" || -n "$HALO_URL" ]]; then
    sudo sed -i \
      -e "s|hexourl|${HEXO_URL}|g" \
      -e "s|hugourl|${HUGO_URL}|g" \
      -e "s|halourl|${HALO_URL}|g" \
      "$HELP_DST/index.html"
    print_color "✓ URL 配置已更新" "$GREEN"
else
    print_color "⚠ 未设置URL，使用模板默认值" "$YELLOW"
fi
echo ""

# ========== 9. 检查 Nginx 语法并重启服务 ==========
print_separator
print_color "步骤 9/9: 检查 Nginx 语法并重启服务" "$YELLOW"
print_color "正在检查 Nginx 语法并重启服务 ..." "$YELLOW"

if sudo nginx -t; then
    print_color "✓ 语法检测通过，正在重启 Nginx ..." "$GREEN"
    sudo systemctl restart nginx && \
        print_color "✓ Nginx 已重启，新配置生效！" "$GREEN" || \
        { print_color "✗ 重启失败，请手动排查！" "$RED"; exit 1; }
else
    print_color "✗ 语法有误，已中止重启，请修正后再试！" "$RED"
    exit 1
fi
echo ""

print_separator
print_color "说明页面：$HELP_DST" "$BLUE"
print_color "错误页面：$ERROR_DST" "$BLUE"
print_color "配置文件：$CONF_FILE" "$BLUE"
print_color "访问地址：https://$DOMAIN:666" "$PURPLE"
print_color "帮助页面：https://$DOMAIN:666/h" "$PURPLE"
print_separator
print_color "重新加载配置：sudo nginx -t && sudo nginx -s reload" "$CYAN"
print_color "重启   Nginx：sudo nginx -t && sudo systemctl restart nginx" "$CYAN"
print_color "删除重新配置：rm -rf $HELP_DST $ERROR_DST $CONF_FILE" "$CYAN"
print_separator

