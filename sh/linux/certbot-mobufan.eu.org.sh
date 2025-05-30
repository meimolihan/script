# 定义证书存储目录
certs_directory="/etc/letsencrypt/live/"

days_before_expiry=5  # 设置在证书到期前几天触发续签

# 遍历所有证书文件
for cert_dir in $certs_directory*; do
    # 获取域名
    domain=$(basename "$cert_dir")

    # 忽略 README 目录
    if [ "$domain" = "README" ]; then
        continue
    fi

    # 输出正在检查的证书信息
    echo "检查证书过期日期： ${domain}"

    # 获取fullchain.pem文件路径
    cert_file="${cert_dir}/fullchain.pem"

    # 获取证书过期日期
    expiration_date=$(openssl x509 -enddate -noout -in "${cert_file}" | cut -d "=" -f 2-)

    # 输出证书过期日期
    echo "过期日期： ${expiration_date}"

    # 将日期转换为时间戳
    expiration_timestamp=$(date -d "${expiration_date}" +%s)
    current_timestamp=$(date +%s)

    # 计算距离过期还有几天
    days_until_expiry=$(( ($expiration_timestamp - $current_timestamp) / 86400 ))

    # 检查是否需要续签（在满足续签条件的情况下）
    if [ $days_until_expiry -le $days_before_expiry ]; then
        echo "证书将在${days_before_expiry}天内过期，正在进行自动续签。"

        # 停止 Nginx
        systemctl stop nginx

        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -F
    
        ip6tables -P INPUT ACCEPT
        ip6tables -P FORWARD ACCEPT
        ip6tables -P OUTPUT ACCEPT
        ip6tables -F

        # 续签证书
        certbot certonly --standalone -d $domain --email 496338740@qq.com --agree-tos --no-eff-email --force-renewal

        # 同步证书到 nginx
        cp /etc/letsencrypt/live/mobufan.eu.org/fullchain.pem /etc/nginx/keyfile/cert.pem && cp /etc/letsencrypt/live/mobufan.eu.org/privkey.pem /etc/nginx/keyfile/key.pem

        # 启动 Nginx
        systemctl restart nginx

        echo "证书已成功续签。"
    else
        # 若未满足续签条件，则输出证书仍然有效
        echo "证书仍然有效，距离过期还有 ${days_until_expiry} 天。"
    fi

    # 输出分隔线
    echo "--------------------------"
done
