## 使用方法

## fnos-sync-aliyun-script.sh

**可以在 Win11 `Git Bash` 终端，执行 `docker-compose` 仓库 `推送命令`**

- **脚本使用 `rsync工具` 将 `/vol2/1000/阿里云盘/` 目录的内容同步到 `/vol1/1000/smb_win11/` 目录，`保留所有文件属性并压缩传输`，同时`显示进度条`，且会在`同步完成后延迟删除目标目录中源目录不存在的文件。`**

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/sync/fnos-sync-aliyun-script.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/sync/fnos-sync-aliyun-script.sh)
```

- 本地脚本（`Git Bash 下载命令`）

```bash
curl -O https://script.meimolihan.eu.org/sh/sync/fnos-sync-aliyun-script.sh
```

## sync_usb-1024g_to_win11-r.sh

- 该脚本用于将 USB 设备挂载目录（`/vol2/1000/mydisk/usb_1024g/`）的文件增量同步到 Windows 共享目录（`/vol2/1000/samba/win11-R/`），会自动排除 Windows 系统特殊目录，同步时显示新增 / 更新内容及删除的冗余文件，并通过中文提示清晰反馈执行过程与结果。

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/sync/sync_usb-1024g_to_win11-r.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/sync/sync_usb-1024g_to_win11-r.sh)
```

- 本地脚本（`Git Bash 下载命令`）

```bash
curl -O https://script.meimolihan.eu.org/sh/sync/sync_usb-1024g_to_win11-r.sh
```

