# 使用方法

## 压缩

### 压缩为`.zip`文件

- 遍历当前目录下的子目录压缩为`.zip`文件

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/zip/backup-zip.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/backup-zip.sh)
```

### 压缩为`.gz`文件

- 遍历当前目录下的子目录压缩为`.tar.gz`文件

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/zip/backup-gz.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/backup-gz.sh)
```

---

## 解压

### 解压 `.zip` 文件

- 遍历当前目录下的`*.zip`文件,解压到当前目录下

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/zip/unzip.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/unzip.sh)
```

### 解压 `.tar.gz` 文件

- 遍历当前目录下的`*.tar.gz`文件,解压到当前目录下

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/zip/untar.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/untar.sh)
```

## 本地脚本使用方法

```bash
cd /mnt/test # test目录下的子目录压缩为.zip文件

wget -c https://gitee.com/meimolihan/script/raw/master/sh/zip/backup-zip.sh && chmod +x backup-zip.sh && bash backup-zip.sh

sudo apt install dos2unix
dos2unix backup-zip.sh
```

### organize_zips.sh

- **在**`/vol2/1000/backup/`**创建**日期文件夹，**将** `/vol1/1000/home/`下的子目录，**压缩为**：`目录名_yyyymmdd.zip`

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/organize_zips.sh)
```

### daily_backup.sh

- **将**`/vol1/1000/home`目录**压缩为** `compose_yyyymmdd.tar.gz` **保存到** `/vol2/1000/backup` 目录下

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/daily_backup.sh)
```
