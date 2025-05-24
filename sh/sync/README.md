## 使用方法

## fnos-sync-aliyun-script.sh

**可以在 Win11  `Git Bash` 终端，执行 `docker-compose` 仓库 `推送命令`**

**脚本使用 `rsync工具` 将 `/vol2/1000/阿里云盘/` 目录的内容同步到 `/vol1/1000/smb_win11/` 目录，`保留所有文件属性并压缩传输`，同时`显示进度条`，且会在`同步完成后延迟删除目标目录中源目录不存在的文件。`**

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/sync/fnos-sync-aliyun-script.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/sync/fnos-sync-aliyun-script.sh)
```

- 本地脚本

```bash
wget -c https://gitee.com/meimolihan/script/raw/master/sh/sync/fnos-sync-aliyun-script.sh
```

