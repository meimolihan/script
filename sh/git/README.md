## 远程使用方法

### fnos_docker_push_all.sh

- Win11 `Git Bash` 终端执行该命令

- 进入 `FnOS`服务器，再进入 `/vol1/1000/home`目录执行 `Git` 推送命令

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/fnos_docker_push_all.sh)
```

### git_clone.sh

- 克隆仓库（兼容 URL 或 git clone 命令）

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_clone.sh)
```

### git_ssh_config.sh

- Git SSH 配置脚本

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_ssh_config.sh) && \
git add . ; git commit -m "update" ; git push
```

![](https://file.meimolihan.eu.org/screenshot/git_ssh_config.webp)

### git_https_config.sh

- Git https 配置脚本

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_https_config.sh) && \
git add . ; git commit -m "update" ; git push
```

![](https://file.meimolihan.eu.org/screenshot/git_https_config.webp)

### git_push.sh

- `推送更新` 当前 Git 仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_push.sh)
```

```
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push.sh)
```

### git_update.sh

- `拉取更新` 当前 Git 仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_update.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_update.sh)
```

### git_push+update.sh

- `推送更新+拉取更新` 当前 Git 仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_push+update.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push+update.sh)
```

---

### git_push_all.sh

- `推送所有更新` 当前目录下的所有有效的 Git 仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_push_all.sh)
```

```
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push_all.sh)
```

### git_update_all.sh

- `拉取所有更新` 当前目录下所有有效 Git 仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_update_all.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_update_all.sh)
```

---

### git-manager-tool.sh

- Git 项目管理

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git-manager-tool.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git-manager-tool.sh)
```

### gitee_new_godown.sh

- `Gitee 新仓库推送` 当前目录

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/gitee_new_godown.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/gitee_new_godown.sh)
```

### github_new_godown.sh

- `github 新仓库推送` 当前目录

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/github_new_godown.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/github_new_godown.sh)
```

### github-user-clone-all.sh

- 克隆 `GitHub` 用户所有公开仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/github-user-clone-all.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/github-user-clone-all.sh)
```

### gitee-user-clone-all.sh

- 克隆 `Gitee` 用户所有公开仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/gitee-user-clone-all.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/gitee-user-clone-all.sh)
```

### git_rm_cached.sh

- 遍历指定目录下的所有子目录中的有效 Git 仓库，对每个仓库执行 git rm --cached -r . 命令以清除缓存文件。

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_rm_cached.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_rm_cached.sh)
```

## 本地脚本（`Git Bash 下载命令`）

```bash
cd /mnt/test # 进入仓库目录
curl -O https://gitee.com/meimolihan/script/raw/master/sh/git/git_clone_docker.sh && chmod +x git_clone_docker.sh && bash git_clone_docker.sh

sudo apt install dos2unix
dos2unix git_clone_docker.sh
```
