# Samba 共享管理脚本使用指南 🚀

本文详细介绍两个高效管理 Samba 共享的 Bash 脚本：`samba_setup.sh`（服务器端配置脚本）和 `samba_mount.sh`（客户端挂载脚本），并补充完整的 Samba 命令手册和使用技巧，帮助您轻松实现跨平台文件共享。

## 📖 导航目录
- [📌 脚本概述](#script-overview)
  - [🔧 samba_setup.sh - Samba 服务器配置脚本](#samba-setup-script)
  - [🔗 samba_mount.sh - Samba 客户端挂载脚本](#samba-mount-script)
- [🛠️ 补充 Samba 相关命令](#samba-commands)
  - [📊 服务器端管理命令](#server-commands)
  - [💻 客户端连接命令](#client-commands)
  - [🔍 故障排查命令](#troubleshooting-commands)
- [🎯 使用示例](#usage-examples)
  - [🚀 示例 1：完整部署 Samba 共享](#example-1)
  - [📂 示例 2：手动挂载 Samba 共享](#example-2)
  - [⚙️ 示例 3：配置开机自动挂载](#example-3)
- [❓ 常见问题解决](#common-issues)
- [🔒 安全建议](#security-tips)
- [📝 总结](#summary)

<a id="script-overview"></a>
## 📌 脚本概述

Samba 是在 Linux 和 UNIX 系统上实现 SMB/CIFS 协议的开源软件，允许与 Windows 系统进行文件与打印机共享。下面介绍的两个脚本极大简化了 Samba 的配置和管理流程。✨

<a id="samba-setup-script"></a>
### 🔧 samba_setup.sh - Samba 服务器配置脚本

此脚本用于自动化安装和配置 Samba 服务器，创建共享目录并设置用户权限，特别适合快速部署和批量配置场景。🎯

**主要功能特点：**
- ✅ 自动检测系统包管理器（APT/YUM/DNF）并安装 Samba
- ✅ 创建可自定义的共享目录并设置正确的文件和权限
- ✅ 交互式设置 Samba 用户和密码，支持密码强度检查
- ✅ 智能配置 Samba 共享权限，支持匿名和认证访问模式
- ✅ 自动重启 Samba 服务并提供清晰的连接信息展示
- ✅ 错误处理和日志记录功能，便于排查问题

**使用方法：**
```bash
# Vercel 仓库
bash <(curl -sL script.meimolihan.eu.org/sh/samba/samba_setup.sh)

# Gitee 仓库
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/samba/samba_setup.sh)
```

<a id="samba-mount-script"></a>
### 🔗 samba_mount.sh - Samba 客户端挂载脚本

此脚本用于在客户端挂载远程 Samba 共享，提供友好的交互界面，支持多种挂载方式和自动发现功能。🌐

**主要功能特点：**
- ✅ 自动检测并安装必需的 CIFS 工具包
- ✅ 扫描网络中的 Samba 共享服务器，支持手动输入IP
- ✅ 交互式选择可用共享，显示共享详细信息
- ✅ 支持多种认证方式（用户名密码/匿名访问）
- ✅ 可配置本地挂载点和开机自动挂载选项
- ✅ 提供挂载测试和错误诊断功能

**使用方法：**

```bash
# Vercel 仓库
bash <(curl -sL script.meimolihan.eu.org/sh/samba/samba_mount.sh)

# Gitee 仓库
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/samba/samba_mount.sh)
```

<a id="samba-commands"></a>
## 🛠️ 补充 Samba 相关命令

除了使用脚本外，掌握以下 Samba 命令将帮助您更灵活地管理共享服务。📚

<a id="server-commands"></a>
### 📊 服务器端管理命令

```bash
# 查看 Samba 服务状态
sudo systemctl status smbd
sudo systemctl status nmbd

# 启动/停止/重启 Samba 服务
sudo systemctl start smbd nmbd
sudo systemctl stop smbd nmbd
sudo systemctl restart smbd nmbd

# 查看 Samba 配置语法是否正确
testparm

# 查看当前连接的 Samba 客户端和文件使用情况
smbstatus

# 添加 Samba 用户（需先存在系统用户）
sudo smbpasswd -a username

# 删除 Samba 用户
sudo smbpasswd -x username

# 启用/禁用 Samba 用户
sudo smbpasswd -e username
sudo smbpasswd -d username

# 查看 Samba 用户列表
pdbedit -L

# 修改 Samba 用户密码
sudo smbpasswd username
```

<a id="client-commands"></a>
### 💻 客户端连接命令

```bash
# 查看服务器可用共享
smbclient -L //server_ip -U username

# 交互式连接共享（类似FTP）
smbclient //server_ip/sharename -U username

# 挂载 Samba 共享（临时挂载）
sudo mount -t cifs //server_ip/sharename /mnt/share -o username=user,password=pass,vers=3.0

# 使用凭据文件挂载（更安全）
sudo mount -t cifs //server_ip/sharename /mnt/share -o credentials=/path/to/credentials,vers=3.0

# 卸载共享
sudo umount /mnt/share

# 强制卸载（当设备忙时）
sudo umount -f /mnt/share

# 查看已挂载的 CIFS 共享
mount | grep cifs
df -h | grep cifs

# 检查共享是否可访问
smbclient -U username //server_ip/sharename -c "ls"
```

<a id="troubleshooting-commands"></a>
### 🔍 故障排查命令

```bash
# 检查网络连通性
ping server_ip

# 检查 Samba 端口是否开放
nmap -p 139,445 server_ip

# 查看 Samba 详细日志
tail -f /var/log/samba/log.smbd
tail -f /var/log/samba/log.nmbd

# 查看所有日志文件
tail -f /var/log/samba/*

# 测试配置文件语法
testparm -s

# 调试模式启动 Samba（前台运行）
smbd -i -d 3

# 检查共享权限和可见性
smbclient -L localhost -U username

# 查看详细的 Samba 配置
testparm -v
```

<a id="usage-examples"></a>
## 🎯 使用示例

<a id="example-1"></a>
### 🚀 示例 1：完整部署 Samba 共享

1. **在服务器上运行配置脚本：**
   ```bash
   sudo ./samba_setup.sh
   ```
   按照提示输入共享目录名称（如`myshare`）、用户名和密码。

2. **在客户端上运行挂载脚本：**
   ```bash
   sudo ./samba_mount.sh
   ```
   输入服务器 IP 地址，从列表中选择共享，输入凭据完成挂载。

3. **验证挂载：**
   ```bash
   df -h | grep cifs
   ls /mnt/myshare
   ```

<a id="example-2"></a>
### 📂 示例 2：手动挂载 Samba 共享

```bash
# 创建挂载点目录
sudo mkdir -p /mnt/myshare

# 挂载共享（认证访问）
sudo mount -t cifs //192.168.1.100/myshare /mnt/myshare -o username=myuser,password=mypass,vers=3.0

# 使用凭据文件（更安全）
echo "username=myuser" > /root/.smbcredentials
echo "password=mypass" >> /root/.smbcredentials
chmod 600 /root/.smbcredentials

sudo mount -t cifs //192.168.1.100/myshare /mnt/myshare -o credentials=/root/.smbcredentials,vers=3.0

# 挂载时指定文件和目录权限
sudo mount -t cifs //192.168.1.100/myshare /mnt/myshare -o credentials=/root/.smbcredentials,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,vers=3.0
```

<a id="example-3"></a>
### ⚙️ 示例 3：配置开机自动挂载

1. **创建凭据文件：**
   ```bash
   sudo nano /root/.smbcredentials
   ```
   添加内容：
   ```
   username=myuser
   password=mypass
   ```
   设置权限：
   ```bash
   chmod 600 /root/.smbcredentials
   ```

2. **编辑 `/etc/fstab` 文件：**
   ```bash
   sudo nano /etc/fstab
   ```
   添加以下行：
   ```
   //192.168.1.100/myshare /mnt/myshare cifs credentials=/root/.smbcredentials,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,vers=3.0 0 0
   ```

3. **测试 fstab 配置：**
   ```bash
   sudo mount -a
   ```
   如果没有错误信息，表示配置成功，重启后会自动挂载。

<a id="common-issues"></a>
## ❓ 常见问题解决

1. **挂载失败：协议错误** 🤔
   - 尝试添加 `vers=2.0` 或 `vers=1.0` 参数兼容旧版本
   - 检查服务器和客户端的 Samba 版本：`smbd --version`
   - 确认服务器支持的协议版本：在 `smb.conf` 的 `[global]` 部分设置 `server min protocol = NT1`

2. **权限问题** 🔐
   - 确保挂载点目录存在且有适当权限：`chmod 755 /mnt/share`
   - 检查 Samba 配置中的权限设置：`force user` 和 `force group` 参数
   - 确认 SELinux 或 AppArmor 没有阻止访问：`setenforce 0`（临时禁用测试）

3. **连接超时** ⏱️
   - 检查防火墙设置，确保 139/TCP 和 445/TCP 端口开放：
     ```bash
     sudo ufw allow samba
     sudo firewall-cmd --add-service=samba --permanent
     ```
   - 验证网络连通性：`ping server_ip` 和 `telnet server_ip 445`

4. **认证失败** 🔑
   - 确认用户名和密码正确
   - 检查服务器上的用户是否已添加到 Samba：`pdbedit -L`
   - 确保用户有权限访问共享：检查 `smb.conf` 中的 `valid users` 设置

5. **共享不可见** 👻
   - 检查 `smb.conf` 中共享的 `browseable = yes` 设置
   - 确认网络发现正常工作：`nmblookup -S server_ip`

6. **写入权限不足** 📝
   - 检查共享目录的 Linux 文件系统权限
   - 确认 Samba 配置中的 `writable = yes` 或 `read only = no`
   - 检查 `create mask` 和 `directory mask` 设置

<a id="security-tips"></a>
## 🔒 安全建议

1. **使用强密码策略** 💪
   - 为 Samba 用户设置复杂密码（大小写字母、数字、特殊字符）
   - 定期更换密码，避免使用默认或常见密码

2. **最小权限原则** 📉
   - 限制共享目录的访问权限到必要的最小范围
   - 为不同用户组创建不同的共享和权限设置

3. **网络隔离** 🌐
   - 使用防火墙限制只有可信网络可以访问 Samba 端口
   - 考虑使用 VPN 或 SSH 隧道加密 Samba 流量

4. **定期更新** 🔄
   - 定期更新 Samba 软件以获取安全补丁：`sudo apt update && sudo apt upgrade samba`
   - 订阅 Samba 安全公告，及时应对漏洞

5. **日志监控** 👀
   - 定期检查 Samba 日志：`/var/log/samba/`
   - 设置日志轮转和监控，及时发现可疑活动

6. **禁用匿名访问** 🚫
   - 除非必要，否则禁用匿名访问：`map to guest = never`
   - 为所有共享设置认证要求

<a id="summary"></a>
## 📝 总结

通过本文介绍的两个脚本和一系列 Samba 管理命令，您可以轻松实现以下目标：🎯

- **快速部署**：使用 `samba_setup.sh` 在几分钟内完成 Samba 服务器配置
- **便捷连接**：通过 `samba_mount.sh` 轻松挂载远程共享，支持交互式选择
- **灵活管理**：掌握各种 Samba 命令，应对不同管理场景和需求
- **故障排除**：使用专业工具诊断和解决连接、权限等问题
- **安全保障**：实施最佳实践，确保文件共享服务的安全性

无论是家庭网络中的简单文件共享，还是企业环境中的跨平台协作，Samba 都是一个强大而灵活的解决方案。这些脚本和命令将帮助您更高效地使用这一工具，提升工作效率和系统可靠性。💼

建议收藏本文作为 Samba 管理的参考手册，随时查阅相关命令和技巧。如有任何问题或建议，欢迎留言讨论！💬