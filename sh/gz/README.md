# 使用方法

### 压缩为`.gz`文件

- 遍历当前目录下的子目录压缩为`.tar.gz`文件

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/gz/backup-gz.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/gz/backup-gz.sh)
```

## 

### 解压 `.tar.gz` 文件

- 遍历当前目录下的`*.tar.gz`文件,解压到当前目录下

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/gz/untar.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/gz/untar.sh)
```



## 本地脚本使用方法

```bash
cd /mnt/test # test目录下的子目录压缩为.zip文件

wget -c https://gitee.com/meimolihan/script/raw/master/sh/zip/backup-zip.sh && chmod +x backup-zip.sh && bash backup-zip.sh

sudo apt install dos2unix
dos2unix backup-zip.sh
```
