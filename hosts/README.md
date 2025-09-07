# 🌟 TMDB Hosts 自动更新与同步脚本集

![](https://file.meimolihan.eu.org/img/tmdb-01.webp)

本文介绍一套用于自动更新 TMDB 相关域名的 DNS 解析记录，并将其同步到常用媒体服务（如 Emby、Nastools）的脚本工具集。所有脚本均配备完整的日志记录与错误处理功能，支持通过计划任务自动执行。

---

## 📖 目录导航

- [✨ 脚本特点与功能](#features)
- [🔧 DnsParse.py 详解](#dnsparse)
- [🔄 nastools-sync-hosts.sh 详解](#nastools-sync)
- [🔄 emby-sync-hosts.sh 详解](#emby-sync)
- [⏰ 计划任务设置](#crontab-setup)
- [📋 查看同步日志](#view-logs)

---

<a id="features"></a>

## ✨ 脚本特点与功能

- **🌐 多 DNS 提供商支持**：使用多个公共 DNS 解析服务获取最新的 IP 地址，提高解析成功率。
- **🏓 智能 IP 筛选**：自动 Ping 测试所有解析到的 IP，仅保留可连通的高质量 IP。
- **💾 无损更新 Hosts**：采用标记块（`###start###` 与 `###end###`）方式更新，保留原有 hosts 内容。
- **📂 多服务同步**：支持将更新后的 hosts 文件自动同步到 Emby 和 Nastools 的 Docker 配置目录。
- **📝 详细日志记录**：所有操作均有详细的中文日志，方便排查问题与查看执行状态。
- **⏰ 自动化部署**：提供一键执行命令与 crontab 计划任务配置，实现完全自动化。

---

<a id="dnsparse"></a>

## 🔧 DnsParse.py 详解

该脚本通过 DNS 解析获取指定域名（`api.themoviedb.org`, `image.tmdb.org`, `www.themoviedb.org`）的 IP 地址，测试它们的连通性，并将可用的 IP 地址写入系统 hosts 文件（`/etc/hosts`）以优化访问速度。

### 一键执行命令

```bash
# 从主站点下载执行
curl -sL script.meimolihan.eu.org/hosts/DnsParse.py | python3 -

# 或从 Gitee 镜像下载执行
curl -sL gitee.com/meimolihan/script/raw/master/hosts/DnsParse.py | python3 -
```

### 验证更新结果

```bash
cat /etc/hosts
```

---

<a id="nastools-sync"></a>

## 🔄 nastools-sync-hosts.sh 详解

此脚本用于将系统的 hosts 文件（`/etc/hosts`）自动同步到 Nastools 配置目录（`/vol1/1000/compose/nastools/config/hosts`），并记录详细的中文日志。

### 一键执行命令

```bash
# 从主站点下载执行
bash <(curl -sL script.meimolihan.eu.org/hosts/nastools-sync-hosts.sh)

# 或从 Gitee 镜像下载执行
bash <(curl -sL gitee.com/meimolihan/script/raw/master/hosts/nastools-sync-hosts.sh)
```

### 验证同步结果

```bash
cat /vol1/1000/compose/nastools/config/hosts
```

---

<a id="emby-sync"></a>

## 🔄 emby-sync-hosts.sh 详解

此脚本用于将系统的 hosts 文件（`/etc/hosts`）自动同步到 Emby 配置目录（`/vol1/1000/compose/emby/config/hosts`），并记录详细的中文日志。

### 一键执行命令

```bash
# 从主站点下载执行
bash <(curl -sL script.meimolihan.eu.org/hosts/emby-sync-hosts.sh)

# 或从 Gitee 镜像下载执行
bash <(curl -sL gitee.com/meimolihan/script/raw/master/hosts/emby-sync-hosts.sh)
```

### 验证同步结果

```bash
cat /vol1/1000/compose/emby/config/hosts
```

---

<a id="crontab-setup"></a>

## ⏰ 计划任务设置

以下 crontab 配置可实现每天自动更新 hosts 并同步到相关服务：

```bash
# 创建或更新计划任务
cat > /var/spool/cron/crontabs/$USER <<'EOF'
# 添加更新hosts文件定时任务，每天凌晨一点十分执行（日志：tmdb-hosts.log）
10 1 * * * curl -sL gitee.com/meimolihan/script/raw/master/hosts/DnsParse.py | python3 - >> /var/log/cron-tasks/tmdb-hosts.log 2>&1

# hosts文件-同步到 emby，每天凌晨一点十五分执行（日志：emby-hosts.log）
15 1 * * * bash <(curl -sL gitee.com/meimolihan/script/raw/master/hosts/emby-sync-hosts.sh)

# hosts文件-同步到 nastools，每天凌晨一点二十分执行（日志：nastools-hosts.log）
20 1 * * * bash <(curl -sL gitee.com/meimolihan/script/raw/master/hosts/nastools-sync-hosts.sh)
EOF

# 应用计划任务
crontab /var/spool/cron/crontabs/$USER

# 查看已设置的计划任务
crontab -l
```

<a id="view-logs"></a>

## 📋 查看同步日志

所有同步操作均有详细日志记录，可通过以下命令查看：

```bash
# 查看 nastools 同步日志
cat /var/log/cron-tasks/nastools-hosts.log

# 查看 emby 同步日志
cat /var/log/cron-tasks/emby-hosts.log

# 查看 DNS 解析更新日志
cat /var/log/cron-tasks/tmdb-hosts.log
```

---

> **💡 提示**：确保脚本有执行权限，并且相关目录存在。首次运行前可手动执行脚本测试功能是否正常。
