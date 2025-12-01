#!/usr/bin/env bash
# 文件：/usr/local/bin/cert_check
# 用法：cert_check <证书文件路径>

# ---------- 颜色变量 ----------
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# ---------- 日志函数 ----------
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# ---------- 参数检查 ----------
cert=${1:-}
[[ -z $cert ]] && { log_error "用法：$0 <证书文件路径>"; exit 1; }
[[ ! -f $cert ]] && { log_error "文件 $cert 不存在！"; exit 2; }

# ---------- 获取证书起止时间 ----------
start_sec=$(openssl x509 -in "$cert" -noout -startdate | cut -d= -f2 | xargs -I{} date -d "{}" +%s)
end_sec=$(openssl x509 -in "$cert" -noout -enddate   | cut -d= -f2 | xargs -I{} date -d "{}" +%s)

start_str=$(date -d "@$start_sec" +"%Y年%m月%d日 %H:%M:%S")
end_str=$(date -d "@$end_sec"   +"%Y年%m月%d日 %H:%M:%S")

now_sec=$(date +%s)
left_days=$(( (end_sec - now_sec) / 86400 ))

# ---------- 根据剩余天数决定颜色 ----------
if (( left_days < 0 )); then
    COLOR=$gl_hong; STATUS='【已过期】'
elif (( left_days <= 30 )); then
    COLOR=$gl_huang; STATUS='【即将到期】'
else
    COLOR=$gl_lv; STATUS='【正常】'
fi

# ---------- 输出 ----------
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${COLOR}证书文件：$cert${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"
echo -e "${COLOR}生效时间：$start_str${gl_bai}"
echo -e "${COLOR}到期时间：$end_str${gl_bai}"
echo -e "${COLOR}剩余天数：$left_days 天 $STATUS${gl_bai}"
echo -e "${gl_bufan}------------------------${gl_bai}"