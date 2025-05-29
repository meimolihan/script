## 远程使用方法

## wallpaper-directory-stats.sh

- 查看随机壁纸所有目录统计

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper-directory-stats.sh)
```

## allinssl_nginx_cert.sh

- 将 `allinssl` 生成的证书同步到 `nginx`
- 检查到`/etc/nginx/keyfile/cert.pem`证书到期不足（18天）自动同步

```
# 这是脚本的作用
cp /mnt/mydisk/home/allinssl/data/mobufan.eu.org.pem /etc/nginx/keyfile/cert.pem
cp /mnt/mydisk/home/allinssl/data/mobufan.eu.org.key /etc/nginx/keyfile/key.pem
sudo systemctl restart nginx
```

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/allinssl_nginx_cert.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/allinssl_nginx_cert.sh)
```



## install_common_packages.sh

- **Linux系统安装常用软件**

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/install_common_packages.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/install_common_packages.sh)
```



## ping_based_host_finder.sh

- 测试 10.10.10.0/24 整个网段中哪些主机处于开机状态,哪些主机处于关机状态

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/ping_based_host_finder.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/ping_based_host_finder.sh)
```



## time_based_greeting.sh

- 根据系统时间显示问候语

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/time_based_greeting.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/time_based_greeting.sh)
```

## file_stats.sh

- 首先安装 `bc`

```bash
sudo apt update && sudo apt install bc -y
```

- 统计当前目录文件个数（普通文件和隐藏文件）
- 统计当前目录文件大小

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/file_stats.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/file_stats.sh)
```

## certbot-mobufan.eu.org.sh

- SSL证书自动续期

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/certbot-mobufan.eu.org.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/certbot-mobufan.eu.org.sh)
```

