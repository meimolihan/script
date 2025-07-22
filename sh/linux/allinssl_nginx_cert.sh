#!/bin/bash

# Nginx证书自动更新脚本
# 当证书剩余有效期少于18天时，自动更新证书并重启Nginx

# 定义源文件和目标文件路径
CERT_SOURCE="/mnt/compose/allinssl/data/mobufan.eu.org.pem"
CERT_TARGET="/etc/nginx/keyfile/cert.pem"
KEY_SOURCE="/mnt/compose/allinssl/data/mobufan.eu.org.key"
KEY_TARGET="/etc/nginx/keyfile/key.pem"

# 定义日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查文件是否存在
if [ ! -f "$CERT_TARGET" ]; then
    log "错误: 当前证书文件 $CERT_TARGET 不存在，直接更新"
    UPDATE_REQUIRED=true
else
    # 检查证书文件是否有效
    if ! openssl x509 -noout -text -in "$CERT_TARGET" &> /dev/null; then
        log "错误: 当前证书文件 $CERT_TARGET 格式无效，直接更新"
        UPDATE_REQUIRED=true
    else
        # 获取证书过期日期
        EXPIRY_DATE=$(openssl x509 -noout -dates -in "$CERT_TARGET" | grep "notAfter" | cut -d= -f2)
        EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
        CURRENT_TIMESTAMP=$(date +%s)

        # 计算剩余天数
        DAYS_LEFT=$(( (EXPIRY_TIMESTAMP - CURRENT_TIMESTAMP) / 86400 ))

        # 显示结果
        echo
        echo =================================================
        log "  证书信息:"
        echo =================================================
        log "  当前证书文件: $CERT_TARGET"
        log "  过期日期: $EXPIRY_DATE"
        log "  剩余天数: $DAYS_LEFT 天"
        echo =================================================
        # 判断是否需要更新
        if [ $DAYS_LEFT -le 30 ]; then
            log "⚠️ 警告: 证书即将过期(剩余$DAYS_LEFT天)，需要更新"
            UPDATE_REQUIRED=true
        else
            log "✅ 证书状态良好，距离过期还有较长时间($DAYS_LEFT天)，无需更新"
            UPDATE_REQUIRED=false
        fi
    fi
fi

# 如果需要更新，则执行更新操作
if [ "$UPDATE_REQUIRED" = true ]; then
    log "开始更新Nginx证书..."

    # 检查源文件是否存在
    if [ ! -f "$CERT_SOURCE" ] || [ ! -f "$KEY_SOURCE" ]; then
        log "错误: 源证书或密钥文件不存在，更新失败"
        exit 1
    fi

    # 复制证书文件
    if cp "$CERT_SOURCE" "$CERT_TARGET"; then
        log "证书文件复制成功"
    else
        log "错误: 证书文件复制失败"
        exit 1
    fi

    # 复制密钥文件
    if cp "$KEY_SOURCE" "$KEY_TARGET"; then
        log "密钥文件复制成功"
    else
        log "错误: 密钥文件复制失败"
        exit 1
    fi

    # 设置正确的权限
    chmod 600 "$KEY_TARGET"
    log "已设置正确的密钥文件权限"

    # 重启Nginx服务
    if sudo systemctl restart nginx; then
        log "Nginx服务重启成功"
    else
        log "错误: Nginx服务重启失败"
        exit 1
    fi

    log "证书更新完成!"
fi

exit 0
