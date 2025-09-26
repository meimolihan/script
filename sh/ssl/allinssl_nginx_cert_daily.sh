#!/bin/bash
# 每日强制更新 Nginx 证书并重启
# 计划任务：0 3 * * * bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/allinssl_nginx_cert_daily.sh) >>/var/log/nginx/cert_update.log 2>&1

set -euo pipefail
log() { echo "[$(date '+%F %T')] $*"; }

SRC_CERT="/mnt/compose/allinssl/data/mobufan.eu.org.pem"
SRC_KEY="/mnt/compose/allinssl/data/mobufan.eu.org.key"
DST_CERT="/etc/nginx/keyfile/cert.pem"
DST_KEY="/etc/nginx/keyfile/key.pem"

# 确保源文件存在
[[ -f $SRC_CERT && -f $SRC_KEY ]] || { log "❌ 源证书或密钥缺失"; exit 1; }

# 目标目录存在
mkdir -pm 755 /etc/nginx/keyfile
echo ""
echo =================================================
echo "      AllinSSL & Nginx 证书同步"
echo =================================================
# 复制并设置权限
cp -f "$SRC_CERT" "$DST_CERT"
cp -f "$SRC_KEY"  "$DST_KEY"
chmod 600 "$DST_KEY"
log "✅ 证书/密钥已覆盖"

# 重启 Nginx
if systemctl is-active --quiet nginx; then
    systemctl reload nginx && log "✅ Nginx reload 成功" \
    || { log "❌ Nginx reload 失败"; exit 2; }
else
    systemctl start nginx && log "✅ Nginx 已启动" \
    || { log "❌ Nginx 启动失败"; exit 2; }
fi
echo =================================================
