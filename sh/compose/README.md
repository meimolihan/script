## 远程使用方法

### gitee-clone-docker.sh

- 克隆 docker 项目

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/git_clone_docker.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/git_clone_docker.sh)
```


### start_compose.sh

- 遍历当前目录（所有子目录）下的docker-compose.yml文件，构建并启动

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/start_compose.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/start_compose.sh)
```

### stop_compose.sh

- 遍历当前目录（所有子目录）下的docker-compose.yml文件，停止并删除

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/stop_compose.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/stop_compose.sh)
```

