## 远程使用方法
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

- `推送更新` 当前Git仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_push.sh)
```

```
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push.sh)
```

### git_update.sh

- `拉取更新` 当前Git仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_update.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_update.sh)
```

### git_push+update.sh

- `推送更新+拉取更新` 当前Git仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_push+update.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push+update.sh)
```

---


### git_push_all.sh

- `推送所有更新` 当前目录下的所有有效的Git仓库

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/git/git_push_all.sh)
```

```
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git/git_push_all.sh)
```

### git_update_all.sh

- `拉取所有更新` 当前目录下所有有效Git仓库

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



## 本地使用方法

```bash
cd /mnt/test # 进入仓库目录
wget -c https://gitee.com/meimolihan/script/raw/master/sh/git/git_clone_docker.sh && chmod +x git_clone_docker.sh && bash git_clone_docker.sh

sudo apt install dos2unix
dos2unix git_clone_docker.sh
```



