## 远程使用方法

### docker-compose-update.sh

- 该脚本用于遍历指定目录下的子目录（过滤隐藏目录且检查 docker-compose.yml 存在性），依次对每个子目录执行容器停止、拉取最新镜像、后台重启容器及清理无用镜像的操作。

```bash
cd /vol1/1000/home && bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/docker-compose-update.sh)
```

### gitee-clone-docker.sh

![](https://file.meimolihan.eu.org/screenshot/git-clone-docker-001.webp)

- 克隆 `docker`  全部项目

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/git_clone_docker.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/git_clone_docker.sh)
```

### git_clone_windows.sh

![](https://file.meimolihan.eu.org/screenshot/git_clone_windows-001.webp) 

- 克隆 `windows` 全部项目

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/git_clone_windows.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/git_clone_windows.sh)
```

### start_compose.sh

- 遍历当前目录（所有子目录）下的 docker-compose.yml 文件，构建并启动

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/start_compose.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/start_compose.sh)
```

### stop_compose.sh

- 遍历当前目录（所有子目录）下的 docker-compose.yml 文件，停止并删除

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/stop_compose.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/stop_compose.sh)
```

### docker_load_all_images.sh

- 自动遍历当前目录下的所有`.tar`和`.tar.gz`文件，使用`docker load`命令加载 Docker 镜像，并显示加载结果和统计信息。

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/compose/docker_load_all_images.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/docker_load_all_images.sh)
```

### docker-compose-down-all.sh

- 用于批量停止（当前目录） Docker 服务的脚本，通过配置列表管理多个服务，支持选择性启用 / 禁用，并提供详细的日志输出和错误处理。

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/compose/docker-compose-down-all.sh)
```

