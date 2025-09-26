## 远程使用方法

## allinssl_nginx_cert.sh

- 将 `allinssl` 生成的证书同步到 `nginx`
- 检查到`/etc/nginx/keyfile/cert.pem`证书到期不足（18 天）自动同步

```
# 这是脚本的作用
cp /mnt/mydisk/home/allinssl/data/mobufan.eu.org.pem /etc/nginx/keyfile/cert.pem
cp /mnt/mydisk/home/allinssl/data/mobufan.eu.org.key /etc/nginx/keyfile/key.pem
sudo systemctl restart nginx
```

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/ssl/allinssl_nginx_cert.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssl/allinssl_nginx_cert.sh)
```



## certbot-mobufan.eu.org.sh

### ✅ **脚本功能简介**

1. **定时检查证书有效期**
   遍历 `/etc/letsencrypt/live/` 目录下的所有域名证书，检查每个证书的过期时间。
2. **提前续签机制**
   如果某个证书将在 **5 天内过期**（可自定义），则触发自动续签流程。
3. **自动续签流程**
   - 停止 Nginx 服务（释放 80 端口）
   - 清空防火墙规则（防止拦截验证请求）
   - 使用 `certbot --standalone` 模式重新签发证书
   - 将新证书复制到 Nginx 指定目录
   - 重启 Nginx 服务

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/ssl/certbot-mobufan.eu.org.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssl/certbot-mobufan.eu.org.sh)
```

## cert_check.sh

把证书文件路径当参数扔给它，它就能告诉你：

- 证书什么时候生效、什么时候作废
- 还剩多少天到期
- 用颜色给你打标签：
  – 绿色：安心
  – 黄色：30 天内要续费/续签
  – 红色：已经过期

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/ssl/cert_check.sh) /etc/nginx/keyfile/cert.pem
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssl/cert_check.sh) /etc/nginx/keyfile/cert.pem
```

## check-ssl.sh  弃用有问题

- 查看 Debian13 Nginx 服务器 ssl 证书到期时间

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/ssl/check-ssl.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssl/check-ssl.sh)
```

## setup-check-ssl.sh

- 用于远程下载 `check-ssl.sh` 脚本，开机显示证书详情

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/ssl/setup-check-ssl.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssl/setup-check-ssl.sh)
```

## allinssl_nginx_cert_daily.sh

- 直接复制 AllinSSL 证书到 Nginx

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/ssl/allinssl_nginx_cert_daily.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssl/allinssl_nginx_cert_daily.sh)
```

