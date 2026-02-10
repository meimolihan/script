#!/bin/bash
#
# 脚本名称: FnOS 系统安全分析与清理工具
# 针对目标: "trim_https_cgi" / "snd_pcap" / "SazW" / "dockers" 等 Rootkit 变种及自定义威胁
#
# 版本: 2.0.2
#
# 自用脚本，代码全公开 还给你带了注释  怀疑这怀疑那 ~
#
# 更新日志:
# 2026-02-01 17:30 [v2.0.2] 修正误报：移除对 wsdd2 和 sync_server 的默认查杀，防止影响系统正常功能。
# 2026-02-01 01:20 [v2.0.1] 优化漏洞检测：支持 HTTPS(5667) 忽略证书；增加自定义后台 URL 设置；自动去除 URL 末尾斜杠。
# 2026-02-01 00:10 [v2.0.0] 重大更新：集成社区最新情报，增加 SazW/dockers 等变种查杀；新增漏洞检测。

# --- 个人颜色变量定义 ---
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# --- 日志函数 ---
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# --- 公共函数 ---
handle_invalid_input() {
    echo -ne "\r${gl_huang}无效的输入,请重新输入! ${gl_zi} 1 ${gl_huang} 秒后返回"
    sleep 1
    echo -e "\r${gl_lv}无效的输入,请重新输入! ${gl_zi}0${gl_lv} 秒后返回"
    sleep 0.5
    return 2
}

exit_script() {
    clear
    exit 0
}

# --- 脚本手动更新的地址 ---
# UPDATE_URL="https://gitee.com/amdev/sh/raw/master/fn/fnos_xxck1.sh"
UPDATE_URL="https://gitee.com/meimolihan/script/raw/master/fnos/fnos_xxck1.sh"

# --- 恶意特征库定义 (IOC) ---

# [网络] 恶意IP与域名
DEFAULT_MAL_IPS=("45.95.212.102" "151.240.13.91" "43.198.11.122" "103.248.152.136")
DEFAULT_TARGET_PORTS=("57132")

# [文件] 恶意二进制文件/脚本
# 注意：已移除 wsdd2，防止误杀
MAL_FILES=(
    "/usr/bin/nginx"              # 伪装的nginx进程
    "/usr/sbin/gots"              # 替换cat命令的恶意程序
    "/usr/trim/bin/trim_https_cgi" # 核心恶意载荷
    "/lib/modules/$(uname -r)/snd_pcap.ko" # 恶意内核模块
    # v2.0 新增变种文件
    "/usr/bin/dockers"
    "/usr/bin/SazW"
    "/tmp/turmp"
)

# [服务] 恶意 Systemd 服务
# 注意：已移除 sync_server，防止误杀
MAL_SERVICES=(
    "/etc/systemd/system/nginx.service"
    "/etc/systemd/system/trim_https_cgi.service"
    # v2.0 新增变种服务
    "/usr/lib/systemd/system/SazW.service"
    "/usr/lib/systemd/system/dockers.service"
    "/usr/lib/systemd/system/trim_pap.service"
    "/etc/systemd/system/SazW.service"
    "/etc/systemd/system/dockers.service"
    "/etc/systemd/system/trim_pap.service"
)

# [配置] 被篡改的系统配置文件
INFECTED_CONFIGS=(
    "/etc/rc.local"
    "/usr/trim/bin/system_startup.sh"
    "/etc/ld.so.preload"
)

# [正则] 强特征字符串
STRICT_REGEX="45\.95\.212\.102|151\.240\.13\.91|turmp|gots|trim_https_cgi|snd_pcap|killaurasleep|SazW|dockers|trim_pap"

MODULE_NAME="snd_pcap"

# --- 用户自定义特征库 (运行时添加) ---
CUSTOM_IPS=()
CUSTOM_PORTS=()
CUSTOM_FNOS_URL="" # 用户自定义的后台URL

# --- 辅助函数 ---
pause() {
    echo -e "${gl_lv}操作完成${gl_bai}"
    echo -e "${gl_bai}按任意键继续${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai} \c"
    read -r -n 1 -s -r -p ""
    echo ""
    clear
}

# --- 功能：手动在线升级脚本 ---
update_script() {
    echo -e "\n${gl_huang}--- 正在检查脚本更新 ---${gl_bai}"

    local CACHE_BUST_URL="${UPDATE_URL}?t=$(date +%s)"

    if [[ "$UPDATE_URL" == *"example.com"* ]]; then
        log_warn "未配置有效的更新地址，请编辑脚本修改 UPDATE_URL 变量。"
        pause
        return
    fi

    CURRENT_SCRIPT="$0"
    TMP_SCRIPT="/tmp/fnos_cleaner_new.sh"

    log_info "正在下载最新版本..."

    if command -v wget >/dev/null 2>&1; then
        wget --no-check-certificate -qO "$TMP_SCRIPT" "$CACHE_BUST_URL"
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL -k -o "$TMP_SCRIPT" "$CACHE_BUST_URL"
    else
        log_error "未找到 wget 或 curl 工具，无法自动升级。"
        pause
        return
    fi

    if [ -s "$TMP_SCRIPT" ]; then
        if grep -q "#!/bin/bash" "$TMP_SCRIPT"; then
            mv "$TMP_SCRIPT" "$CURRENT_SCRIPT"
            chmod +x "$CURRENT_SCRIPT"
            log_ok "脚本升级成功！即将重启脚本..."
            sleep 2
            exec "$CURRENT_SCRIPT"
        else
            log_error "下载的文件似乎不是有效的脚本文件，取消升级。"
            rm -f "$TMP_SCRIPT"
        fi
    else
        log_error "下载失败或文件为空，请检查网络连接或更新地址。"
    fi
    pause
}

# --- 功能：添加自定义目标 ---
add_custom_targets() {
    while true; do
        echo -e "\n${gl_huang}>>> 添加自定义威胁情报${gl_bai}"
        echo "当前自定义 IP  列表: ${CUSTOM_IPS[*]:-无}"
        echo "当前自定义端口 列表: ${CUSTOM_PORTS[*]:-无}"
        echo "当前自定义 URL 列表: ${CUSTOM_FNOS_URL:-默认}"
        echo ""
        echo -e "${gl_bufan}1.  ${gl_bai}添加可疑 IP 地址"
        echo -e "${gl_bufan}2.  ${gl_bai}添加可疑 端口号 (TCP)"
        echo -e "${gl_bufan}3.  ${gl_bai}设置飞牛后台 URL (用于漏洞检测)"
        echo -e "${gl_huang}0.  ${gl_bai}返回主菜单"
        echo ""
        read -r -e -p "请输入你的选择: " sub_choice

        case $sub_choice in
            1)
                read -r -e -p "请输入 IP 地址 (例如 1.1.1.1): " new_ip
                if [[ -n "$new_ip" ]]; then
                    CUSTOM_IPS+=("$new_ip")
                    log_info "已添加 IP: $new_ip"
                fi
                ;;
            2)
                read -r -e -p "请输入端口号 (例如 8888): " new_port
                if [[ "$new_port" =~ ^[0-9]+$ ]]; then
                    CUSTOM_PORTS+=("$new_port")
                    log_info "已添加端口: $new_port"
                else
                    log_warn "无效端口号"
                fi
                ;;
            3)
                echo -e "提示: 如果修改了默认端口，请在此输入。系统默认检测 127.0.0.1:5666/5667"
                read -r -e -p "请输入完整 URL (如 https://192.168.1.5:5667): " new_url
                if [[ -n "$new_url" ]]; then
                    # 自动去除末尾的斜杠
                    new_url="${new_url%/}"
                    CUSTOM_FNOS_URL="$new_url"
                    log_info "已设置自定义检测 URL: $CUSTOM_FNOS_URL"
                fi
                ;;
            0)
                return
                ;;
            *)
                handle_invalid_input
                ;;
        esac
    done
}

# --- 功能：自毁脚本 ---
self_destruct() {
    echo -e "\n${gl_hong}!!! 危险操作：删除本脚本 !!!${gl_bai}"
    echo -e "当前文件路径: $0"
    read -r -e -p "$(echo -e "${gl_bai}你确定要删除本脚本文件吗? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" confirm_del
    if [[ "$confirm_del" =~ ^[Yy]$ ]]; then
        rm -- "$0"
        echo -e "${gl_lv}脚本已自毁。再见。${gl_bai}"
        exit 0
    else
        echo "操作已取消。"
        pause
    fi
}

# ==================== 检测模块 ====================

# [v2.0.1 优化] 漏洞检测模块
check_vulnerability() {
    echo -e ""
    echo -e "${gl_huang}>>> 执行全盘快速扫描检测 (含漏洞/病毒)${gl_bai}"
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    echo -e "\n${gl_huang}--- [0/6] FnOS 系统漏洞检测 ---${gl_bai}"

    # 定义检测目标列表
    local TARGET_URLS=("http://127.0.0.1:5666" "https://127.0.0.1:5667")

    # 如果用户设置了自定义URL，加入列表
    if [[ -n "$CUSTOM_FNOS_URL" ]]; then
        TARGET_URLS+=("$CUSTOM_FNOS_URL")
    fi

    # 漏洞利用路径
    local PAYLOAD="/app-center-static/serviceicon/myapp/%7B0%7D/?size=../../../../etc/passwd"
    local VULN_FOUND=0

    if ! command -v curl >/dev/null 2>&1; then
        log_warn "缺少 curl 命令，跳过漏洞检测"
        return 0
    fi

    for base_url in "${TARGET_URLS[@]}"; do
        # 确保去除斜杠 (双重保险)
        base_url="${base_url%/}"
        local full_url="${base_url}${PAYLOAD}"

        # -s: 静默模式
        # -k: 忽略 SSL 证书验证
        # --max-time: 超时控制
        if curl -s -k --max-time 3 "$full_url" | grep -q "root:x:0:0"; then
            log_error "严重漏洞：目标 [ $base_url ] 存在路径穿越漏洞！"
            VULN_FOUND=1
        fi
    done

    if [ $VULN_FOUND -eq 1 ]; then
        echo -e "${gl_hong}      警告：黑客可利用此漏洞直接读取系统文件。${gl_bai}"
        echo -e "${gl_hong}      建议：请立即更新 FnOS 系统至最新版本，或限制公网访问。${gl_bai}"
        return 1
    else
        log_ok "路径穿越漏洞检测通过 (默认端口及自定义端口)"
        return 0
    fi
}

check_network() {
    echo -e "\n${gl_huang}--- [1/6] 网络连接与端口扫描 ---${gl_bai}"
    local found=0

    local ALL_IPS=("${DEFAULT_MAL_IPS[@]}" "${CUSTOM_IPS[@]}")
    local ALL_PORTS=("${DEFAULT_TARGET_PORTS[@]}" "${CUSTOM_PORTS[@]}")

    local net_cmd=""
    local port_cmd=""

    if command -v ss >/dev/null 2>&1; then
        net_cmd="ss -n"
        port_cmd="ss -tuln"
    elif command -v netstat >/dev/null 2>&1; then
        net_cmd="netstat -an"
        port_cmd="netstat -tuln"
    else
        log_warn "未找到 ss 或 netstat 命令，跳过网络检测！"
        return 0
    fi

    if [ ${#ALL_IPS[@]} -eq 0 ]; then
        log_info "没有配置需要检测的 IP。"
    else
        for ip in "${ALL_IPS[@]}"; do
            if $net_cmd 2>/dev/null | grep -q "$ip"; then
                log_error "发现连接到恶意/可疑服务器: $ip"
                found=1
            else
                log_ok "未发现连接到 IP: $ip"
            fi
        done
    fi

    if [ ${#ALL_PORTS[@]} -eq 0 ]; then
        log_info "没有配置需要检测的端口。"
    else
        for port in "${ALL_PORTS[@]}"; do
            if $port_cmd 2>/dev/null | grep -q ":$port "; then
                log_error "端口 $port 处于监听状态 (可能是木马/后门)"
                found=1
            else
                log_ok "端口 $port 正常 (未被占用)"
            fi
        done
    fi

    return $found
}

check_files() {
    echo -e "\n${gl_huang}--- [2/6] 关键文件完整性扫描 ---${gl_bai}"
    local found=0

    for f in "${MAL_FILES[@]}"; do
        if [ -f "$f" ]; then
            if lsattr "$f" 2>/dev/null | grep -q "\-i-"; then
                log_error "发现被锁定(+i)的恶意文件: $f"
            else
                log_error "发现恶意文件: $f"
            fi
            found=1
        else
            log_ok "文件未感染: $f"
        fi
    done
    return $found
}

check_module() {
    echo -e "\n${gl_huang}--- [3/6] 内核模块扫描 ---${gl_bai}"
    if lsmod | grep -q "$MODULE_NAME"; then
        log_error "警告：检测到恶意内核模块已加载 ($MODULE_NAME)"
        return 1
    else
        log_ok "内核模块检查正常"
        return 0
    fi
}

check_persistence() {
    echo -e "\n${gl_huang}--- [4/6] 服务与启动项扫描 ---${gl_bai}"
    local found=0

    # Systemd 服务检查
    for svc in "${MAL_SERVICES[@]}"; do
        if [ -f "$svc" ]; then
            log_error "发现恶意服务文件: $svc"
            found=1
        fi
    done

    # 扫描哈希命名的服务 (如 8f222...service)
    find /etc/systemd/system/ -name "*.service" 2>/dev/null | while read -r svc; do
        base=$(basename "$svc")
        if [[ "$base" =~ ^[0-9a-f]{64}\.service$ ]]; then
            log_error "发现可疑哈希命名服务: $base"
            found=1
        fi
    done

    # rc.local 检查
    if grep -qE "gots|SazW" /etc/rc.local 2>/dev/null; then
        log_error "已感染: /etc/rc.local (包含恶意启动项)"
        found=1
    fi

    # system_startup.sh 检查
    if grep -qE "turmp|151\.240\.13\.91" /usr/trim/bin/system_startup.sh 2>/dev/null; then
        log_error "已感染: /usr/trim/bin/system_startup.sh (含恶意下载指令)"
        found=1
    fi

    if [ $found -eq 0 ]; then
        log_ok "常用持久化项目检查通过"
    fi
    return $found
}

# [v2.0 新增] 定时任务与SSH扫描
check_cron_ssh() {
    echo -e "\n${gl_huang}--- [5/6] 深度 Cron & SSH 扫描 ---${gl_bai}"
    local found=0

    # 1. 扫描 Cron
    SYS_CRON_FILES="/etc/crontab /etc/cron.d/* /var/spool/cron/crontabs/*"
    if grep -RqsE "$STRICT_REGEX" $SYS_CRON_FILES 2>/dev/null; then
        log_error "在 Crontab (定时任务) 中发现恶意特征！"
        grep -RE "$STRICT_REGEX" $SYS_CRON_FILES 2>/dev/null | awk -F: '{print "   -> " $1}' | head -n 3
        found=1
    else
        log_ok "Crontab 定时任务检查正常"
    fi

    # 2. 扫描 SSH Authorized Keys
    local ssh_hit=0
    find /root /home -name "authorized_keys" 2>/dev/null | while read -r keyfile; do
        if grep -qsE "$STRICT_REGEX" "$keyfile"; then
            log_error "在 SSH 公钥文件中发现恶意特征: $keyfile"
            ssh_hit=1
        fi
    done

    if [ $ssh_hit -eq 0 ]; then
        log_ok "SSH 公钥文件检查正常"
    else
        found=1
    fi

    return $found
}

# ==================== 修复模块 ====================

apply_fix() {
    local ALL_IPS=("${DEFAULT_MAL_IPS[@]}" "${CUSTOM_IPS[@]}")
    local ALL_PORTS=("${DEFAULT_TARGET_PORTS[@]}" "${CUSTOM_PORTS[@]}")

    echo -e "\n${gl_hong}!!! 正在启动修复程序 (v2.0) !!!${gl_bai}"
    echo "警告：此过程将修改系统配置、阻断相关IP并清理进程。"
    read -r -e -p "$(echo -e "${gl_bai}请输入 'YES' (大写) 确认开始自动修复: ")" confirm
    if [ "$confirm" != "YES" ]; then
        echo "用户取消操作。"
        return
    fi

    # 1. 备份
    echo -e "\n${gl_zi}>>> 阶段 1: 配置文件备份${gl_bai}"
    read -r -e -p "$(echo -e "${gl_bai}是否在修改前备份受感染的配置文件? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" bk_opt
    if [[ "$bk_opt" =~ ^[Yy]$ ]]; then
        for file in "${INFECTED_CONFIGS[@]}"; do
            if [ -f "$file" ]; then
                cp "$file" "${file}.bak_$(date +%s)"
                log_info "已备份文件: $file -> ${file}.bak_..."
            fi
        done
        cp /etc/crontab "/etc/crontab.bak_$(date +%s)" 2>/dev/null
    fi

    # 2. 网络阻断
    echo -e "\n${gl_zi}>>> 阶段 2: 防火墙隔离 (含自定义IP)${gl_bai}"
    log_info "正在阻断以下 IP: ${ALL_IPS[*]}"

    if command -v nft >/dev/null 2>&1; then
        log_info "使用 nftables 添加规则..."
        nft add table inet fnos_guard 2>/dev/null
        nft add chain inet fnos_guard output { type filter hook output priority 0 \; } 2>/dev/null
        for ip in "${ALL_IPS[@]}"; do
            nft add rule inet fnos_guard output ip daddr "$ip" drop 2>/dev/null
        done
        log_ok "nftables 规则已更新"
    elif command -v iptables >/dev/null 2>&1; then
        log_info "使用 iptables 添加规则..."
        for ip in "${ALL_IPS[@]}"; do
            iptables -D OUTPUT -d "$ip" -j DROP 2>/dev/null # 防止重复
            iptables -I OUTPUT -d "$ip" -j DROP
        done
        log_ok "iptables 规则已更新"
    else
        log_warn "未找到防火墙！请手动在路由器拦截: ${ALL_IPS[*]}"
        pause
    fi

    # 3. 进程清理 (增强版)
    echo -e "\n${gl_zi}>>> 阶段 3: 终止恶意进程${gl_bai}"
    # 杀端口
    for port in "${ALL_PORTS[@]}"; do
        if lsof -i :$port >/dev/null 2>&1 || ss -nlp | grep -q ":$port "; then
             fuser -k -9 $port/tcp >/dev/null 2>&1
             log_ok "已清理占用端口 $port 的进程"
        fi
    done

    # 杀名称 (暴力查杀)
    # 注意：已移除 wsdd2 和 sync_server，防止误杀
    KILL_LIST=("nginx" "trim_https_cgi" "gots" "SazW" "dockers" "trim_pap")
    for proc in "${KILL_LIST[@]}"; do
         pkill -9 -f "$proc" 2>/dev/null && log_ok "已尝试终止进程: $proc"
    done
    # 特征查杀
    pkill -9 -f "killaurasleep" 2>/dev/null
    log_ok "进程清理动作完成"

    # 4. 内核模块
    echo -e "\n${gl_zi}>>> 阶段 4: 卸载恶意内核模块${gl_bai}"
    if lsmod | grep -q "$MODULE_NAME"; then
        rmmod "$MODULE_NAME" || log_warn "模块卸载失败 (可能正被占用)，稍后将强制删除文件"
    fi
    if [ -f "/lib/modules/$(uname -r)/snd_pcap.ko" ]; then
        rm -f "/lib/modules/$(uname -r)/snd_pcap.ko"
        depmod -a
        log_ok "恶意驱动文件已删除，内核依赖已刷新"
    fi

    # 5. 文件与服务清理 (批量去锁 + 删除)
    echo -e "\n${gl_zi}>>> 阶段 5: 清理恶意文件与服务${gl_bai}"

    # 停止服务
    systemctl stop SazW nginx dockers trim_pap 2>/dev/null
    systemctl disable SazW nginx dockers trim_pap 2>/dev/null

    # 合并所有要删除的文件和服务
    ALL_TRASH=("${MAL_FILES[@]}" "${MAL_SERVICES[@]}")

    for file in "${ALL_TRASH[@]}"; do
        if [ -f "$file" ]; then
            chattr -i "$file" 2>/dev/null
            rm -f "$file"
            log_ok "已删除: $file"
        fi
    done

    # 扫描并删除哈希服务
    find /etc/systemd/system/ -name "*.service" 2>/dev/null | while read -r svc; do
        base=$(basename "$svc")
        if [[ "$base" =~ ^[0-9a-f]{64}\.service$ ]]; then
             systemctl stop "$base" 2>/dev/null
             chattr -i "$svc" 2>/dev/null
             rm -f "$svc"
             log_ok "已删除哈希服务: $svc"
        fi
    done

    # 6. 配置修复 (增强版)
    echo -e "\n${gl_zi}>>> 阶段 6: 净化系统配置${gl_bai}"

    # 修复 rc.local
    if [ -f "/etc/rc.local" ]; then
        chattr -i "/etc/rc.local" 2>/dev/null
        if grep -qE "gots|SazW" /etc/rc.local; then
             sed -i -E '/(gots|SazW)/d' /etc/rc.local
             log_ok "已清理 /etc/rc.local"
        fi
    fi

    # 修复 system_startup.sh
    startup_script="/usr/trim/bin/system_startup.sh"
    if [ -f "$startup_script" ]; then
        chattr -i "$startup_script" 2>/dev/null
        if grep -qE "151\.240\.13\.91|turmp" "$startup_script"; then
            sed -i -E '/(151\.240\.13\.91|turmp)/d' "$startup_script"
            log_ok "已清理 $startup_script"
        fi
    fi

    # 修复 Crontab
    if grep -qE "$STRICT_REGEX" /etc/crontab; then
        chattr -i /etc/crontab 2>/dev/null
        sed -i -E "/$STRICT_REGEX/d" /etc/crontab
        log_ok "已清理 /etc/crontab"
    fi

    systemctl daemon-reload
    log_info "Systemd 守护进程配置已重载"

    # 7. 日志
    echo -e "\n${gl_zi}>>> 阶段 7: 服务恢复${gl_bai}"
    read -r -e -p "$(echo -e "${gl_bai}是否尝试重启日志相关服务? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" log_opt
    if [[ "$log_opt" =~ ^[Yy]$ ]]; then
        systemctl restart rsyslog 2>/dev/null
        systemctl restart systemd-journald 2>/dev/null
        systemctl restart auditd 2>/dev/null
        systemctl restart cron 2>/dev/null
        log_ok "已发送日志与Cron服务重启指令"
    fi

    echo -e "\n${gl_lv}=== 修复流程执行完毕 ===${gl_bai}"
    echo "提示：自定义添加的 IP 已加入防火墙拦截规则。"
    echo "强烈建议您立即【重启系统】以确保清理彻底。"
    pause
}

manual_fix_guide() {
    echo -e "\n${gl_zi}=== 手动修复操作指南 (v2.0) ===${gl_bai}"
    echo "1. 漏洞: 升级 FnOS 系统或限制公网访问端口 5666。"
    echo "2. 网络: 封禁 IP 45.95.212.102, 151.240.13.91, 103.248.152.136。"
    echo "3. 进程: kill 掉 SazW, dockers, nginx(伪装), gots, trim_https_cgi。"
    echo "4. 文件: 必须先 chattr -i 解锁，再删除 /usr/bin/SazW 等恶意文件。"
    echo "5. 配置: 检查 /etc/rc.local, /etc/crontab, /usr/trim/bin/system_startup.sh。"
    pause
}

# --- 主逻辑循环 ---

main_menu() {
    while true; do
        clear
        echo -e "${gl_zi}>>> FnOS 系统安全分析与清理工具 (v2.0.2)${gl_bai}"
        echo -e "${gl_bai}当前系统 : ${gl_lv}$(uname -n) / $(uname -r)${gl_bai}"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        # 针对目标
        echo -e "${gl_lv}针对目标:${gl_bai} trim_https_cgi / SazW / dockers / Cron后门 / 漏洞检测"
        # 检测逻辑说明
        echo -e "${gl_lv}检测逻辑:${gl_bai} 漏洞 -> 网络 -> 文件(+i锁) -> 内核 -> 持久化 -> Cron/SSH"
        # 流程提示
        echo -e "${gl_huang}流程提示:${gl_bai} 建议先执行 [1] 全盘扫描，若发现问题再执行 [2] 添加自定义或修复 。"
        # 流程提示
        echo -e "${gl_huang}流程提示:${gl_bai} 如果改了飞牛默认IP，请执行[2]修改，此项用于检测路径穿越漏洞"
        # 操作流程
        echo -e "${gl_huang}操作提示:${gl_bai} 执行 [1] 扫描检测，如发现风险提示是否修复, 或者根据 [3] 手动修 复指南"
        # 操作流程
        echo -e "${gl_huang}操作提示:${gl_bai} 自用脚本，免费开源。"
        echo ""
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        echo -e "${gl_bufan}1.  ${gl_bai}执行全盘快速扫描检测 (含漏洞/病毒)"
        echo -e "${gl_bufan}2.  ${gl_bai}飞牛官方紧急验证查杀脚本"
        echo -e "${gl_bufan}3.  ${gl_bai}添加自定义威胁情报 (IP/端口/URL)"
        echo -e "${gl_bufan}4.  ${gl_bai}查看手动修复指南"
        echo -e "${gl_bufan}5.  ${gl_bai}查看本脚本源代码"
        echo -e "${gl_bufan}6.  ${gl_bai}删除本脚本"
        echo -e "${gl_bufan}7.  ${gl_bai}手动更新脚本"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        echo -e "${gl_hong}0.  ${gl_bai}退出脚本"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        read -r -e -p "请输入你的选择 : " choice

        case $choice in
            1)
                DETECTED=0
                # v2.0 检测流程
                check_vulnerability || DETECTED=1
                check_network || DETECTED=1
                check_files || DETECTED=1
                check_module || DETECTED=1
                check_persistence || DETECTED=1
                check_cron_ssh || DETECTED=1

                echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
                if [ $DETECTED -eq 1 ]; then
                    echo -e "${gl_hong}警告：系统检测到活跃威胁或高危漏洞！${gl_bai}"
                    read -r -e -p "$(echo -e "${gl_bai}是否立即进入自动修复/清理菜单? (${gl_lv}y${gl_bai}/${gl_hong}N${gl_bai}): ")" fix_now
                    if [[ "$fix_now" =~ ^[Yy]$ ]]; then
                        apply_fix
                    fi
                else
                    echo -e "${gl_lv}恭喜：系统状态正常 (未发现已知 IOC)。${gl_bai}"
                    if [ ${#CUSTOM_IPS[@]} -gt 0 ] || [ ${#CUSTOM_PORTS[@]} -gt 0 ]; then
                         echo " (已扫描您手动添加的自定义威胁)"
                    fi
                    pause
                fi
                ;;
            2)
                clear
                echo -e "${gl_zi}>>> 飞牛官方紧急验证查杀脚本${gl_bai}"
                echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
                curl -L https://static2.fnnas.com/aptfix/trim-sec -o trim-sec && chmod +x trim-sec && ./trim-sec
                echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
                pause
                ;;
            3)
                add_custom_targets
                ;;
            4)
                manual_fix_guide
                ;;
            5)
                REMOTE_URL="https://gitee.com/meimolihan/script/raw/master/fnos/fnos_xxck1.sh"
                echo -e "${gl_bai}正在从 Gitee 获取最新源码${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
            
                local tmp_file="/tmp/fnos_remote_$$.sh"
            
                # 下载（带进度显示）
                if command -v curl >/dev/null 2>&1; then
                    curl -fSL -k --progress-bar --max-time 15 -o "$tmp_file" "$REMOTE_URL"
                elif command -v wget >/dev/null 2>&1; then
                    wget --no-check-certificate --show-progress -qO "$tmp_file" "$REMOTE_URL"
                else
                    echo -e "${gl_huang}缺少 curl/wget${gl_bai}"
                    pause
                    return
                fi
            
                if [ -s "$tmp_file" ]; then
                    echo -e "${gl_lv}下载成功！行数: $(wc -l < "$tmp_file")${gl_bai}"
                    echo -e "${gl_huang}提示: 按 'q' 退出，按 '/' 可搜索${gl_bai}"
                    sleep 1
                    less -N "$tmp_file"
                    rm -f "$tmp_file"
                else
                    echo -e "${gl_hong}下载失败或文件为空${gl_bai}"
                    rm -f "$tmp_file"
                    pause
                fi
                ;;
            6)
                self_destruct
                ;;
            7)
                update_script
                ;;
            0)
                exit_script
                ;;
            *)
                handle_invalid_input
                ;;
        esac
    done
}

# --- 脚本入口 ---
main_menu








