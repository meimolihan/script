#!/usr/bin/env bash
# 文件：/usr/local/bin/cert_check
# 用法：cert_check <证书文件路径>

cert=${1:-}
[[ -z $cert ]] && { echo "用法：$0 <证书文件路径>"; exit 1; }
[[ ! -f $cert ]] && { echo "错误：文件 $cert 不存在！"; exit 2; }

# ---------- 获取证书起止时间 ----------
start_sec=$(openssl x509 -in "$cert" -noout -startdate | cut -d= -f2 | xargs -I{} date -d "{}" +%s)
end_sec=$(openssl x509 -in "$cert" -noout -enddate   | cut -d= -f2 | xargs -I{} date -d "{}" +%s)

start_str=$(date -d "@$start_sec" +"%Y年%m月%d日 %H:%M:%S")
end_str=$(date -d "@$end_sec"   +"%Y年%m月%d日 %H:%M:%S")

now_sec=$(date +%s)
left_days=$(( (end_sec - now_sec) / 86400 ))

# ---------- 根据剩余天数决定颜色 ----------
if (( left_days < 0 )); then
    COLOR='\033[31m'; STATUS='【已过期】'
elif (( left_days <= 30 )); then
    COLOR='\033[33m'; STATUS='【即将到期】'
else
    COLOR='\033[32m'; STATUS='【正常】'
fi
RESET='\033[0m'

# ---------- 输出 ----------
echo -e "${COLOR}==============================${RESET}"
echo -e "${COLOR}证书文件：$cert${RESET}"
echo -e "${COLOR}==============================${RESET}"
echo -e "${COLOR}生效时间：$start_str${RESET}"
echo -e "${COLOR}到期时间：$end_str${RESET}"
echo -e "${COLOR}剩余天数：$left_days 天 $STATUS${RESET}"
echo -e "${COLOR}==============================${RESET}"