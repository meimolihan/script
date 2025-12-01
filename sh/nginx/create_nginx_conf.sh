#!/usr/bin/env bash
# create_nginx_conf.sh
# 功能：自动生成 Nginx 反向代理配置文件（按域名命名）及相关帮助/错误页面
# 作者：Mobufan
# 版本：1.4  修复数组下标、local/(( 作用域、颜色引号、模板缺失

set -e

# ============================== 颜色变量 ==============================
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'
# ====================================================================

###### 跨Linux发行版的通用软件包安装函数，能够自动检测并适配不同系统的包管理器进行软件安装。
install() {
    [[ $# -eq 0 ]] && {
        log_error "未提供软件包参数!"
        return 1
    }

    local pkg mgr ver
    for pkg in "$@"; do
        ver=""
        if command -v "$pkg" &>/dev/null; then
            ver=$("$pkg" --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
        fi
        if [[ -z "$ver" ]]; then
            if command -v dpkg-query &>/dev/null; then
                ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null) || true
            elif command -v rpm &>/dev/null; then
                ver=$(rpm -q --qf '%{VERSION}' "$pkg" 2>/dev/null) || true
            fi
        fi
        if [[ -n "$ver" ]]; then
            printf '%b%s%b %b已安装%b %b版本%b %b%s%b\n' \
                   "$gl_huang" "$pkg" "$gl_bai" \
                   "$gl_lv" "$gl_bai" \
                   "$gl_bai" "$gl_bai" \
                   "$gl_lv" "$ver" "$gl_bai"
            continue
        fi
        printf '%b正在安装 %s...%b\n' "$gl_huang" "$pkg" "$gl_bai"
        for mgr in dnf yum apt apk pacman zypper opkg pkg; do
            case $mgr in
            dnf) command -v dnf &>/dev/null && {
                dnf -y update
                dnf install -y epel-release
                dnf install -y "$pkg"
                continue 2
            } ;;
            yum) command -v yum &>/dev/null && {
                yum -y update
                yum install -y epel-release
                yum install -y "$pkg"
                continue 2
            } ;;
            apt) command -v apt &>/dev/null && {
                apt update -y
                apt install -y "$pkg"
                continue 2
            } ;;
            apk) command -v apk &>/dev/null && {
                apk update
                apk add "$pkg"
                continue 2
            } ;;
            pacman) command -v pacman &>/dev/null && {
                pacman -Syu --noconfirm
                pacman -S --noconfirm "$pkg"
                continue 2
            } ;;
            zypper) command -v zypper &>/dev/null && {
                zypper refresh
                zypper install -y "$pkg"
                continue 2
            } ;;
            opkg) command -v opkg &>/dev/null && {
                opkg update
                opkg install "$pkg"
                continue 2
            } ;;
            pkg) command -v pkg &>/dev/null && {
                pkg update
                pkg install -y "$pkg"
                continue 2
            } ;;
            esac
        done
    done
}


# 安全的输入函数，支持退格键
safe_input() {
    local prompt="$1" default_value="$2" input_value=""
    while true; do
        read -rep "$prompt" input_value
        if [[ -z "$input_value" && -n "$default_value" ]]; then
            echo "$default_value"; return 0
        elif [[ -n "$input_value" ]]; then
            echo "$input_value"; return 0
        else
            echo -e "${gl_huang}输入不能为空，请重新输入${gl_bai}"
        fi
    done
}

# 智能端口输入：优先匹配预设，回车用预设，无预设则 8888
smart_port_input(){
    local svc="$1"
    # 转小写、去空格，避免关联数组下标报错
    svc="${svc,,}"
    svc="${svc// /}"
    local default_port="${PRESET_PORTS[$svc]:-8888}" input_port
    read -r -e -p "$(echo -e "${gl_bai}请输入后端端口（默认端口 ${gl_huang}${default_port}${gl_bai}) : ")" input_port
    [[ -z "$input_port" ]] && input_port="$default_port"
    echo "$input_port"
}

# URL输入函数（允许为空）
safe_url_input() {
    local prompt="$1" input_value=""
    read -rep "$prompt" input_value
    echo "$input_value"
}

# ========== 预设端口表 ==========
declare -A PRESET_PORTS=(
    [transmission]=9091 [halo]=8090 [emby]=8896 [fntv-302]=8095 [md]=9900
    [xiaomusic]=8393 [metube]=8081 [random-pic-api]=8588 [easynode]=8082
    [allinssl]=7979 [ittools]=8088 [sun-panel]=3002 [sun-panel-helper]=33002
    [openlist]=5244 [taosync]=8023 [xunlei]=2345 [qbittorrent]=8080
    [musicn]=7478 [dufs]=5000 [nastools]=3000 [jackett]=9117
    [aipan]=5055 [libretv]=8899 [moontv]=3133 [cloud-saver]=8008
    [pansou]=8110 [panhub]=3020 [mind-map]=8256 [easyvoice]=3780
    [dpanel]=8807 [kspeeder]=5003 [speedtest]=7878 [navidrome]=4533
    [uptime-kuma]=3001 [chinesesubfinder]=19035 [nginx-file]=18080
    [bbbb]=3777
)

# 显示欢迎信息
clear
echo ""
echo -e "${gl_zi}>>> Nginx 配置生成脚本${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"

install wget
install nginx
echo ""

echo -e "${gl_bufan}------------------------${gl_bai}"

# ========== 下载依赖（存在则跳过） ==========
mkdir -p /etc/nginx/html/error/test-xxx_error /etc/nginx/html/help/test-xxx_help

# 错误页依赖
for f in index.html favicon.ico; do
    if [[ ! -f "/etc/nginx/html/error/test-xxx_error/$f" ]]; then
        wget -q -c "https://gitee.com/meimolihan/script/raw/master/nginx/test-xxx_error/$f" \
             -O "/etc/nginx/html/error/test-xxx_error/$f"
        echo -e "${gl_lv}✓ ${gl_bai}错误页 ${gl_huang}/etc/nginx/html/error/test-xxx_error/$f ${gl_lv}已下载${gl_bai}"
    else
        echo -e "${gl_hui}○ ${gl_bai}错误页 ${gl_huang}/etc/nginx/html/error/test-xxx_error/$f ${gl_bai}已存在，${gl_huang}跳过${gl_bai}"
    fi
done

# 帮助页依赖
for f in index.html favicon.ico; do
    if [[ ! -f "/etc/nginx/html/help/test-xxx_help/$f" ]]; then
        wget -q -c "https://gitee.com/meimolihan/script/raw/master/nginx/test-xxx_help/$f" \
             -O "/etc/nginx/html/help/test-xxx_help/$f"
        echo -e "${gl_lv}✓ ${gl_bai}帮助页 ${gl_huang}/etc/nginx/html/help/test-xxx_help/$f ${gl_lv}已下载${gl_bai}"
    else
        echo -e "${gl_hui}○ ${gl_bai}帮助页 ${gl_huang}/etc/nginx/html/help/test-xxx_help/$f ${gl_bai}已存在，${gl_huang}跳过${gl_bai}"
    fi
done
echo ""

# ========== 1. 服务名称配置 ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}1${gl_hong}/${gl_huang}9${gl_bai}): 服务名称配置"
read -r -e -p "$(echo -e "${gl_bai}请输入服务名称（默认名称 ${gl_huang}aaaa${gl_bai}) : ")" SVC_NAME
SVC_NAME=${SVC_NAME:-aaaa}
echo -e "${gl_lv}✓ ${gl_bai}服务名称: ${gl_lv}$SVC_NAME${gl_bai}"
echo ""

# ========== 2. 子域名前缀 ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}2${gl_hong}/${gl_huang}9${gl_bai}): 域名配置"
read -r -e -p "$(echo -e "${gl_bai}请输入域名前缀（默认前缀 ${gl_huang}${SVC_NAME}${gl_bai}) : ")" SUB_DOM
SUB_DOM=${SUB_DOM:-$SVC_NAME}
DOMAIN="${SUB_DOM}.mobufan.eu.org"
echo -e "${gl_lv}✓ ${gl_bai}当前域名: ${gl_lv}$DOMAIN${gl_bai}"
echo ""

# ========== 3. 后端服务配置 ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}3${gl_hong}/${gl_huang}9${gl_bai}): 后端服务配置"
read -r -e -p "$(echo -e "${gl_bai}请输入后端 IP（默认地址 ${gl_huang}10.10.10.251${gl_bai}) : ")" BACKEND_IP
BACKEND_IP=${BACKEND_IP:-10.10.10.251}
echo -e "${gl_lv}✓ ${gl_bai}后端 IP: ${gl_lv}$BACKEND_IP${gl_bai}"
echo ""

# ========== 4. 后端端口配置 ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}4${gl_hong}/${gl_huang}9${gl_bai}): 后端端口配置"
BACKEND_PORT=$(smart_port_input "$SVC_NAME")
echo -e "${gl_lv}✓ ${gl_bai}后端端口: ${gl_lv}$BACKEND_PORT${gl_bai}"
echo ""

# ========== 5. 生成 Nginx 配置文件（按域名命名） ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}5${gl_hong}/${gl_huang}9${gl_bai}): 生成 Nginx 配置文件"
CONF_FILE="/etc/nginx/conf.d/${DOMAIN}.conf"

cat > "${CONF_FILE}" <<EOF
server {
    listen 666 ssl;
    listen [::]:666 ssl;
    http2 on;

    server_name ${DOMAIN};
    ssl_certificate /etc/nginx/keyfile/mobufan.eu.org.pem;
    ssl_certificate_key /etc/nginx/keyfile/mobufan.eu.org.key;
    client_max_body_size 1024G;

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

echo -e "${gl_lv}✓ ${gl_bai}已生成配置文件：${gl_lv}${CONF_FILE}${gl_bai}"
echo ""

# ========== 6. 创建日志目录 ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}6${gl_hong}/${gl_huang}9${gl_bai}): 创建日志目录"
LOG_DIR="/etc/nginx/log/mobufan.eu.org"
sudo mkdir -p "$LOG_DIR" || { echo -e "${gl_hong}✗ 创建日志目录失败！${gl_bai}"; exit 1; }

NGX_USER=$(nginx -V 2>&1 | grep -oP 'user=\K\w+' || echo "nginx")
[[ -z "$NGX_USER" || "$NGX_USER" == "nginx" ]] && \
    NGX_USER=$(grep -m1 -E '^user[[:space:]]+' /etc/nginx/nginx.conf | awk '{print $2}' | tr -d ';')

sudo chown -R "$NGX_USER:$NGX_USER" "$LOG_DIR"
sudo chmod 755 "$LOG_DIR"
printf '%b✓ %b日志目录已创建/授权：%b%s （user: %s）%b\n' "$gl_lv" "$gl_bai" "$gl_lv" "$LOG_DIR" "$NGX_USER" "$gl_bai"
echo ""

# ========== 7. 复制并替换说明/错误页面模板（含成功提示） ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}7${gl_hong}/${gl_huang}9${gl_bai}): 生成帮助和错误页面"
HELP_SRC="/etc/nginx/html/help/test-xxx_help"
HELP_DST="/etc/nginx/html/help/${SVC_NAME}_help"
ERROR_SRC="/etc/nginx/html/error/test-xxx_error"
ERROR_DST="/etc/nginx/html/error/${SVC_NAME}_error"

# 若全局模板不存在，现场生成一套最小模板
if [[ ! -d "$HELP_SRC" ]]; then
    sudo mkdir -p "$HELP_SRC" "$ERROR_SRC"
    sudo tee "$HELP_SRC/index.html" >/dev/null <<'EOF'
<!doctype html><html><head><meta charset="utf-8"><title>Help</title></head>
<body><h1>Help Page</h1><p>请编辑 /etc/nginx/help/ 目录下对应文件。</p></body></html>
EOF
    sudo tee "$ERROR_SRC/index.html" >/dev/null <<'EOF'
<!doctype html><html><head><meta charset="utf-8"><title>Error</title></head>
<body><h1>Error Page</h1><p>请编辑 /etc/nginx/error/ 目录下对应文件。</p></body></html>
EOF
fi

# 复制并打印结果
if sudo rsync -a --delete "$HELP_SRC"/ "$HELP_DST"/ 2>/dev/null; then
    printf '%b✓ %b帮助页面模板已复制：%b%s → %s%b\n' "$gl_lv" "$gl_bai" "$gl_huang" "$HELP_SRC" "$HELP_DST" "$gl_bai"
else
    printf '%b✗ %b帮助页面模板复制失败！%b\n' "$gl_hong" "$gl_bai" "$gl_bai"
fi

if sudo rsync -a --delete "$ERROR_SRC"/ "$ERROR_DST"/ 2>/dev/null; then
    printf '%b✓ %b错误页面模板已复制：%b%s → %s%b\n' "$gl_lv" "$gl_bai" "$gl_huang" "$ERROR_SRC" "$ERROR_DST" "$gl_bai"
else
    printf '%b✗ %b错误页面模板复制失败！%b\n' "$gl_hong" "$gl_bai" "$gl_bai"
fi

# 替换变量并打印结果
replaced=0
if sudo sed -i "s/test-xxx/${SVC_NAME}/g" "$HELP_DST/index.html" 2>/dev/null; then
    printf '%b✓ %b帮助页变量替换完成：%b%s%b\n' "$gl_lv" "$gl_bai" "$gl_huang" "$HELP_DST/index.html" "$gl_bai"
    replaced=$((replaced + 1))
else
    printf '%b✗ %b帮助页变量替换失败！%b\n' "$gl_hong" "$gl_bai" "$gl_bai"
fi

if sudo sed -i "s/test-xxx/${SVC_NAME}/g" "$ERROR_DST/index.html" 2>/dev/null; then
    printf '%b✓ %b错误页变量替换完成：%b%s%b\n' "$gl_lv" "$gl_bai" "$gl_huang" "$ERROR_DST/index.html" "$gl_bai"
    replaced=$((replaced + 1))
else
    printf '%b✗ %b错误页变量替换失败！%b\n' "$gl_hong" "$gl_bai" "$gl_bai"
fi

if sudo sed -i "s/test-yyy/${SUB_DOM}/g" "$ERROR_DST/index.html" 2>/dev/null; then
    printf '%b✓ %b子域名变量替换完成：%b%s%b\n' "$gl_lv" "$gl_bai" "$gl_huang" "$ERROR_DST/index.html" "$gl_bai"
    replaced=$((replaced + 1))
else
    printf '%b✗ %b子域名变量替换失败！%b\n' "$gl_hong" "$gl_bai" "$gl_bai"
fi

if [[ $replaced -eq 3 ]]; then
    printf '%b✓ %b所有模板变量已替换完成！%b\n' "$gl_lv" "$gl_bai" "$gl_bai"
else
    printf '%b⚠ %b部分变量替换失败，请手动检查！%b\n' "$gl_huang" "$gl_bai" "$gl_bai"
fi
echo ""

# ========== 8. 修改帮助文档 URL（可选） ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}8${gl_hong}/${gl_huang}9${gl_bai}): 修改帮助文档 URL（按回车跳过设置）"
read -r -e -p "$(echo -e "${gl_bai}请输入 ${gl_huang}Hexo${gl_bai} 地址: ")" HEXO_URL
read -r -e -p "$(echo -e "${gl_bai}请输入 ${gl_huang}Hugo${gl_bai} 地址: ")" HUGO_URL  
read -r -e -p "$(echo -e "${gl_bai}请输入 ${gl_huang}Halo${gl_bai} 地址: ")" HALO_URL

if [[ -n "$HEXO_URL" || -n "$HUGO_URL" || -n "$HALO_URL" ]]; then
    sudo sed -i -e "s|hexourl|${HEXO_URL}|g" -e "s|hugourl|${HUGO_URL}|g" -e "s|halourl|${HALO_URL}|g" "$HELP_DST/index.html"
    echo -e "${gl_lv}✓ URL 配置已更新${gl_bai}"
else
    echo -e "${gl_huang}⚠ 未设置URL，使用模板默认值${gl_bai}"
fi
echo ""

# ========== 9. 检查 Nginx 语法并重载 ==========
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${gl_zi}>>> 步骤 ${gl_bai}(${gl_huang}9${gl_hong}/${gl_huang}9${gl_bai}): 检查 Nginx 语法并重载服务"

if sudo nginx -t; then
    echo -e "${gl_lv}✓ 语法检测通过，正在重载 Nginx ...${gl_bai}"
    sudo systemctl reload nginx && \
        echo -e "${gl_lv}✓ Nginx 已重载，新配置生效！${gl_bai}" || \
        { echo -e "${gl_hong}✗ 重载失败，请手动排查！${gl_bai}"; exit 1; }
else
    echo -e "${gl_hong}✗ 语法有误，已中止重载，请修正后再试！${gl_bai}"
    exit 1
fi
echo ""


echo -e "${gl_bufan}------------------------------------------------${gl_bai}"
echo -e "${gl_lv}✓ ${gl_bai}访问地址：${gl_lv}https://$DOMAIN:666${gl_bai}"
echo -e "${gl_lv}✓ ${gl_bai}帮助页面：${gl_lv}https://$DOMAIN:666/h${gl_bai}"
echo -e "${gl_bufan}------------------------------------------------${gl_bai}"
echo -e "${gl_lv}✓ ${gl_bai}说明页面：${gl_huang}/etc/nginx/html/help/${SVC_NAME}_help${gl_bai}"
echo -e "${gl_lv}✓ ${gl_bai}错误页面：${gl_huang}/etc/nginx/html/error/${SVC_NAME}_error${gl_bai}"
echo -e "${gl_lv}✓ ${gl_bai}配置文件：${gl_huang}/etc/nginx/conf.d/${DOMAIN}.conf${gl_bai}"
echo -e "${gl_bufan}------------------------------------------------${gl_bai}"
echo -e "${gl_huang}⚠ ${gl_bai}重载配置：${gl_huang}sudo nginx -t && sudo nginx -s reload${gl_bai}"
echo -e "${gl_huang}⚠ ${gl_bai}重启服务：${gl_huang}sudo nginx -t && sudo systemctl restart nginx${gl_bai}"
echo -e "${gl_huang}⚠ ${gl_bai}删除配置：${gl_huang}rm -rf $HELP_DST $ERROR_DST $CONF_FILE${gl_bai}"
echo -e "${gl_bufan}------------------------------------------------${gl_bai}"