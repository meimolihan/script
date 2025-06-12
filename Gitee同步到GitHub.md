## 同步 `Gitee` 脚本仓库 >> `GitHub` 脚本仓库

### 1 、 利用 `WSL` Linux 子系统同步（`PowerShell` 或 `Git Bash` 命令）

- **启动默认的 WSL 发行版**

```bash
wsl
```

### 2 、添加排除 `.git` 命令（`PowerShell` 或 `Git Bash` 命令）

```bash
wsl && \
rsync -avhz --progress --delete-delay \
  --exclude='**/.git/' \
  /mnt/c/Users/Administrator/Desktop/Gitee/script/ \
  /mnt/c/Users/Administrator/Desktop/GitHub/script/
```

### 3 、推送 `script` 脚本仓库（`Git Bash` 命令）

- **`Ctrl+D` 退出 `WSL`**

```bash
cd ~/Desktop/GitHub/script && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push.sh)
```