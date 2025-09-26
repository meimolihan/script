#!/usr/bin/env bash
set -euo pipefail          # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'               # No Color

# 统一颜色：这里随便选一个，也可以改成 $GREEN / $YELLOW
color=$GREEN

# ── Nginx 证书详情 ───────────────────────────────────────────────
echo -e "${color}==============================${NC}"
echo "      Nginx 证书详情"
bash <(curl -sL https://gitee.com/meimolihan/script/raw/master/sh/ssl/cert_check.sh) \
     /etc/nginx/keyfile/cert.pem

echo  -e ""

# ── AllinSSL 证书详情 ────────────────────────────────────────────
echo -e "${color}==============================${NC}"
echo "      AllinSSL 证书详情"
bash <(curl -sL https://gitee.com/meimolihan/script/raw/master/sh/ssl/cert_check.sh) \
     /mnt/compose/allinssl/data/mobufan.eu.org.pem

echo  -e ""

echo -e "${color}==============================${NC}"
echo "      手动更新证书命令"
echo -e "${color}==============================${NC}"
echo -e "${color}cp -f /mnt/compose/allinssl/data/mobufan.eu.org.pem /etc/nginx/keyfile/cert.pem${NC}"
echo -e "${color}cp -f /mnt/compose/allinssl/data/mobufan.eu.org.key /etc/nginx/keyfile/key.pem${NC}"
echo -e "${color}==============================${NC}"
