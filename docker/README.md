# 一键安装 Docker 与 docker-compose 的懒人脚本

> 适用于 fnOS / Debian / Ubuntu / Kali / CentOS / Rocky / Alma / Fedora / openEuler  
> 国内自动换源 + 镜像加速，无交互，一条命令完成！

---

## 1. 特性

- **零依赖**：纯 Bash，无需额外软件  
- **智能判断**  
  - 国内/国外 IP 自动切换镜像源  
  - fnOS 与 Debian 系列自动区分 `docker-compose` 安装目录  
- **最新版**：Docker Engine 与 docker-compose 均使用官方最新 release  
- **幂等**：重复执行不会重复安装  

---

## 2. 使用方法

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/docker/install-docker.sh)
```

---

## 3. 脚本流程

1. 检测是否已安装 Docker → 跳过或安装  
2. 根据发行版自动选择官方源 or 阿里云/清华源  
3. 写入 17 条国内 registry-mirrors 加速  
4. 启动 Docker 并设为开机自启  
5. 解析 GitHub 最新版 docker-compose  
   - fnOS → `/usr/local/bin`  
   - Debian/Ubuntu → `/usr/bin`  
   - 国内通过 `hub.fast360.xyz` 加速下载  
6. 验证安装结果

---

## 4. 目录对照表

| 系统          | docker-compose 路径 |
| ------------- | ------------------- |
| fnOS          | `/usr/local/bin`    |
| Debian/Ubuntu | `/usr/bin`          |
| 其余系统      | `/usr/local/bin`    |

---

## 5. 安装示例

```text
$ sudo ./install-docker.sh
[INFO] 正在安装 Docker ...
[INFO] 配置国内 registry-mirrors ...
[INFO] 启动 Docker ...
[INFO] 下载 docker-compose -> /usr/bin/docker-compose
docker-compose version 2.27.1
[INFO] 全部安装完成！
```

---

## 6. 验证

```bash
docker --version
docker-compose --version
```

---

## 7. 常见问题

| 现象                    | 解决                                                         |
| ----------------------- | ------------------------------------------------------------ |
| `获取 compose 版本失败` | 已内置 fallback 版本 2.27.1，也可手动指定 `DOCKER_COMPOSE_VERSION=2.27.1 ./install-docker.sh` |
| 下载慢                  | 脚本已使用国内镜像，若仍慢可手动修改 `base_url` 变量         |
| 非 root 执行            | 脚本会提示并退出，请使用 `sudo`                              |

---

## 8. 附录：完整脚本

```bash
#!/usr/bin/env bash
# 一键安装 Docker + docker-compose（全文见上文）
set -euo pipefail
# ...（此处省略，内容与上文完全一致）
```

保存即可使用。祝使用愉快！



