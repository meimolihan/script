## 远程使用方法

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


## 本地使用方法

```bash
cd /mnt/test # 进入仓库目录
wget -c https://gitee.com/meimolihan/script/raw/master/sh/git/git_clone_docker.sh && chmod +x git_clone_docker.sh && bash git_clone_docker.sh

sudo apt install dos2unix
dos2unix git_clone_docker.sh
```



