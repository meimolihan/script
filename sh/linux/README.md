## 远程使用方法

## wallpaper-directory-stats.sh

- 查看随机壁纸所有目录统计

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper-directory-stats.sh)
```

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
bash <(curl -sL script.meimolihan.eu.org/sh/linux/allinssl_nginx_cert.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/allinssl_nginx_cert.sh)
```

## install_common_packages.sh

- **Linux 系统安装常用软件**

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

- SSL 证书自动续期

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/certbot-mobufan.eu.org.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/certbot-mobufan.eu.org.sh)
```

## rename_webp_pc.sh

- 这个脚本的作用是将当前目录下的所有 `.webp` 文件按照修改时间排序，然后使用用户指定的前缀（默认为 `pc`）和三位数字序号（如 `pc-001.webp`）对它们进行重命名，同时避免覆盖已存在的文件，并在操作完成后显示处理的文件数量。

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/rename_webp_pc.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp_pc.sh)
```

## rename_webp_phone.sh

- 这个脚本的作用是将当前目录下的所有 `.webp` 文件按照修改时间排序，然后使用用户指定的前缀（默认为 `phone`）和三位数字序号（如 `phone-001.webp`）对它们进行重命名，同时避免覆盖已存在的文件，并在操作完成后显示处理的文件数量。

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/linux/rename_webp_phone.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp_phone.sh)
```

## rename_webp-png-jpg_phone.sh

- 这个脚本的作用是：**将当前目录下的所有图片文件（`PNG、JPG、WEBP 等`）按修改时间排序，并批量重命名为用户指定的前缀+三位数字序号格式（如 phone-001.jpg）**。

```bash
cd /vol2/1000/壁纸原图/手机原图 && \
ls -t | head -n 6 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp-png-jpg_phone.sh)
```

## rename_webp-png-jpg_pc.sh

- 这个脚本的作用是：**将当前目录下的所有图片文件（`PNG、JPG、WEBP 等`）按修改时间排序，并批量重命名为用户指定的前缀+三位数字序号格式（如 pc-001.jpg）**。

```bash
cd /vol2/1000/壁纸原图/电脑原图 && \
ls -t | head -n 6 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/rename_webp-png-jpg_pc.sh)
```

## wallpaper_phone_dirs.sh

- 这个脚本用于比较两个指定目录（**`已处理手机壁纸目录`**和**`手机壁纸原图目录`**）的文件数量和总大小，输出详细的对比数据和比率分析，帮助用户了解图片处理前后的变化情况。

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper_phone_dirs.sh)
```

## wallpaper_pc_dirs.sh

- 这个脚本用于比较两个指定目录（**`已处理电脑壁纸目录`**和**`电脑壁纸原图目录`**）的文件数量和总大小，输出详细的对比数据和比率分析，帮助用户了解图片处理前后的变化情况。

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper_pc_dirs.sh)
```

## wallpaper_phone_all.sh

- 该脚本按顺序执行`整理手机壁纸`、备份手机壁纸原图、对手机壁纸和原图排序以及比较指定目录等操作，实现手机壁纸的自动化处理与管理。

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper_phone_all.sh)
```

## wallpaper_pc_all.sh

- 该脚本按顺序执行`整理电脑壁纸`、备份电脑壁纸原图、对电脑壁纸和原图排序以及比较指定目录等操作，实现电脑壁纸的自动化处理与管理。

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/linux/wallpaper_pc_all.sh)
```
