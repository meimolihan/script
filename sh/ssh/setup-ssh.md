# Linux SSH 服务一键配置脚本使用指南 🚀

![](https://file.meimolihan.eu.org/img/ssh-01.webp)

> 本文详细介绍一个高效管理 SSH 服务的 Bash 脚本：`setup-ssh.sh`（SSH 服务端配置脚本）。
> ✅ 支持主流 Linux 发行版：Debian, Ubuntu, CentOS, RHEL, Fedora, OpenSUSE, Arch Linux。

---

## 📖 导航目录

- [📌 脚本概述](#script-overview)
- [🔧 功能特点](#ssh-setup-script)
- [🚀 一、脚本使用方法](#usage-method)
- [🛠️ 二、补充相关命令](#ssh-commands)
- [🎯 三、SSH 使用示例](#usage-examples)
  - [🔑 1. SSH 密钥认证配置](#example-1)
  - [🔄 2. SSH 端口转发](#example-2)
- [❓ 四、常见问题解决](#common-issues)
- [🔒 五、SSH 安全建议](#security-tips)
- [📝 六、总结](#summary)

---

<a id="script-overview"></a>
## 📌 脚本概述

SSH（Secure Shell）是用于安全远程登录和执行命令的网络协议，是管理 Linux 服务器的标准工具。下面介绍的脚本极大简化了 SSH 服务的配置和管理流程。✨

---

<a id="ssh-setup-script"></a>
## 🔧 功能特点

此脚本用于自动化安装和配置 SSH 服务器，优化连接参数并设置防火墙规则，特别适合快速部署和批量配置场景。🎯


- ✅ 自动检测系统包管理器（APT/YUM/DNF/ZYPPER/PACMAN）并安装 SSH 服务
- ✅ 支持主流 Linux 发行版：Debian, Ubuntu, CentOS, RHEL, Fedora, OpenSUSE, Arch Linux
- ✅ 优化 SSH 连接参数（禁用 DNS 查询，启用压缩，保持连接等）
- ✅ 自动配置防火墙允许 SSH 连接（支持 ufw, firewalld, iptables）
- ✅ 备份原始配置文件，确保操作安全可逆
- ✅ 提供清晰的连接信息和安全建议
- ✅ 完整的错误处理和日志记录功能

---

<a id="usage-method"></a>
## 一、 🚀脚本使用方法

### 1. 安装基础软件

```bash
apt update -y && apt install -y rsync sudo curl wget vim tree samba nfs-common openssh-server zip htop net-tools
```

### 2. 一键配置脚本

```bash
# Vercel 仓库
bash <(curl -sL script.meimolihan.eu.org/sh/ssh/setup-ssh.sh)

# Gitee 仓库
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ssh/setup-ssh.sh)

# 或者先下载再执行
wget -c https://gitee.com/meimolihan/script/raw/master/sh/ssh/setup-ssh.sh
chmod +x setup-ssh.sh
sudo ./setup-ssh.sh
```

![](https://file.meimolihan.eu.org/screenshot/setup-ssh-001.webp)

### 3. 查看修改

```bash
grep -E 'Port 22|PermitRootLogin|GSSAPIAuthentication|UseDNS|Compression|ClientAliveInterval|ClientAliveCountMax|TCPKeepAlive|PrintMotd|PrintLastLog|X11Forwarding' /etc/ssh/sshd_config
```

| 命令片段                                            | 一句话解释                               |
| --------------------------------------------------- | ---------------------------------------- |
| # the setting of "PermitRootLogin prohibit-password | 删除那行纯注释提示。                     |
| Port 22                                             | 强制监听 22 端口。                       |
| PermitRootLogin yes                                 | 允许 root 直接密码/密钥登录。            |
| GSSAPIAuthentication no                             | 关闭 GSSAPI，加快连接速度。              |
| PrintMotd no                                        | 省掉登录提示，提速。                     |
| PrintLastLog no                                     | 关闭“上次登录”提示。                     |
| UseDNS no                                           | 禁用反向 DNS，防止登录卡慢。             |
| Compression delayed                                 | 根据数据情况决定是否启用压缩。           |
| ClientAliveInterval 30                              | 每 30 秒服务端发一次心跳。               |
| ClientAliveCountMax 120                             | 连续 120 次无响应才断开 1 小时。         |
| TCPKeepAlive no                                     | 仅用 SSH 层心跳，避免伪造 RST 导致误断。 |
| X11Forwarding no                                    | 关闭 X11 转发。                          |

### 4. 公钥认证开关和公钥文件路径（选做）

```bash
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*AuthorizedKeysFile.*/AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2/' /etc/ssh/sshd_config
```

---

<a id="ssh-commands"></a>
## 二、🛠️ 补充 SSH 相关命令

除了使用脚本外，掌握以下 SSH 命令将帮助您更灵活地管理远程连接。📚

### 📊 服务器端管理命令

```bash
# 查看 SSH 服务状态
sudo systemctl status ssh
sudo systemctl status sshd

# 启动/停止/重启 SSH 服务
sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh

# 重新加载 SSH 配置（不中断现有连接）
sudo systemctl reload ssh

# 查看 SSH 连接日志
sudo tail -f /var/log/auth.log | grep ssh
sudo journalctl -u ssh -f

# 查看当前连接的 SSH 用户
who
w
ps aux | grep sshd

# 查看 SSH 配置文件语法
sshd -t

# 生成 SSH 主机密钥
sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
sudo ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
```

### 💻 客户端连接命令

```bash
# 基本连接
ssh username@hostname

# 指定端口连接
ssh -p 2222 username@hostname

# 使用特定私钥连接
ssh -i ~/.ssh/mykey username@hostname

# 远程执行命令
ssh username@hostname "ls -la"

# 启用详细模式（调试用）
ssh -v username@hostname

# 启用压缩（慢速网络有用）
ssh -C username@hostname

# X11 转发（图形界面）
ssh -X username@hostname

# 端口转发（本地端口转发）
ssh -L 8080:localhost:80 username@hostname

# 端口转发（远程端口转发）
ssh -R 9090:localhost:90 username@hostname

# SOCKS 代理
ssh -D 1080 username@hostname

# 文件传输（SCP）
scp file.txt username@hostname:/path/to/destination
scp -r directory username@hostname:/path/to/destination

# 安全文件传输（SFTP）
sftp username@hostname

# 同步文件（RSYNC over SSH）
rsync -avz -e ssh /local/path username@hostname:/remote/path
```

### 🔍 故障排查命令

```bash
# 检查 SSH 端口是否开放
nc -zv hostname 22
nmap -p 22 hostname

# 测试连接（不执行命令）
ssh -T username@hostname

# 检查公钥指纹
ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub

# 调试 SSH 客户端
ssh -vvv username@hostname

# 调试 SSH 服务器端（临时启用调试模式）
sudo /usr/sbin/sshd -d -p 2222

# 检查 SSH 配置语法
sudo sshd -t

# 查看失败的登录尝试
sudo grep "Failed password" /var/log/auth.log
sudo lastb

# 查看成功的登录记录
sudo last
```

---

<a id="usage-examples"></a>
## 三、🎯 SSH 使用示例

<a id="example-1"></a>

### 🔑 1. SSH 密钥认证配置

```bash
# 生成 SSH 密钥对（客户端）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
ssh-keygen -t ed25519 -C "your_email@example.com"  # 更安全的选择

# 复制公钥到服务器
ssh-copy-id username@hostname

# 或者手动复制
cat ~/.ssh/id_rsa.pub | ssh username@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# 设置正确的权限
ssh username@hostname "chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys"

# 禁用密码认证（服务器端）
# 编辑 /etc/ssh/sshd_config
# 设置 PasswordAuthentication no
# 然后重启 SSH 服务
```

<a id="example-2"></a>

### 🔄 2. SSH 端口转发和隧道

```bash
# 本地端口转发（访问远程服务的本地端口）
ssh -L 3306:localhost:3306 username@hostname  # MySQL 隧道
ssh -L 8080:localhost:80 username@hostname    # Web 服务器隧道

# 远程端口转发（让远程访问本地服务）
ssh -R 9090:localhost:3000 username@hostname  # 本地开发服务器

# 动态端口转发（SOCKS 代理）
ssh -D 1080 username@hostname

# 多跳 SSH 连接（通过跳板机）
ssh -J jumpuser@jumpserver username@targetserver

# 保持连接活跃（客户端配置）
# 在 ~/.ssh/config 中添加：
# Host *
#   ServerAliveInterval 60
#   ServerAliveCountMax 3
```

---

<a id="common-issues"></a>
## 四、❓ 常见问题解决

1. **连接被拒绝或超时** 🤔
   - 检查 SSH 服务是否运行：`sudo systemctl status ssh`
   - 确认防火墙允许 SSH 端口：`sudo ufw status` 或 `sudo firewall-cmd --list-all`
   - 验证网络连通性：`ping hostname` 和 `telnet hostname 22`

2. **权限错误** 🔐
   - 检查 `~/.ssh` 目录权限：应为 700
   - 检查 `~/.ssh/authorized_keys` 文件权限：应为 600
   - 确认 SELinux 或 AppArmor 没有阻止访问

3. **主机密钥验证失败** ⚠️
   - 清除过期的密钥：`ssh-keygen -R hostname`
   - 或者编辑 `~/.ssh/known_hosts` 手动删除对应行

4. **认证失败** 🔑
   - 确认服务器是否允许密码认证：`PasswordAuthentication yes`
   - 检查密钥是否正确复制到 `authorized_keys`
   - 验证服务器是否允许该用户登录：`AllowUsers` 设置

5. **连接速度慢** 🐢
   - 禁用 DNS 反向查询：在 `sshd_config` 设置 `UseDNS no`
   - 尝试使用更快的加密算法：`Ciphers aes128-gcm@openssh.com`
   - 启用压缩：`Compression yes`

---

<a id="security-tips"></a>
## 五、🔒 SSH 安全建议

1. **使用非标准端口** 🚪
   - 修改默认 SSH 端口（22）为其他端口
   - 在 `/etc/ssh/sshd_config` 中设置：`Port 2222`

2. **禁用 root 直接登录** 👤
   - 禁止 root 用户直接 SSH 登录：
   - `PermitRootLogin no`
   - 使用普通用户登录后切换 root

3. **使用密钥认证** 🔑
   - 完全禁用密码认证：`PasswordAuthentication no`
   - 强制使用公钥认证：`PubkeyAuthentication yes`

4. **限制用户访问** 📋
   - 只允许特定用户访问：
   - `AllowUsers user1 user2`
   - 或限制用户组：`AllowGroups ssh-users`

5. **使用 fail2ban 防止暴力破解** 🛡️
   ```bash
   # 安装 fail2ban
   sudo apt install fail2ban
   
   # 配置 SSH 保护
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
   # 在 [sshd] 部分设置：
   # enabled = true
   # port = ssh
   # logpath = /var/log/auth.log
   ```

6. **定期更新 SSH** 🔄
   - 保持 SSH 软件最新：`sudo apt update && sudo apt upgrade openssh-server`
   - 关注 SSH 安全公告，及时应对漏洞

7. **使用双因素认证** ✅
   - 结合 Google Authenticator 等工具增强安全性
   - 配置 SSH 与 PAM 集成实现双因素认证

---

<a id="summary"></a>
## 六、📝 总结

通过本文介绍的脚本和一系列 SSH 管理命令，您可以轻松实现以下目标：🎯

- **快速部署**：使用 `setup-ssh.sh` 在几分钟内完成 SSH 服务器配置和优化
- **安全连接**：掌握密钥认证、端口转发等高级 SSH 功能
- **灵活管理**：使用各种 SSH 命令应对不同管理场景和需求
- **故障排除**：使用专业工具诊断和解决连接、认证等问题
- **安全保障**：实施最佳实践，确保远程访问服务的安全性

无论是单台服务器的日常管理，还是大规模集群的远程维护，SSH 都是不可或缺的核心工具。这个脚本和相关命令将帮助您更高效地使用这一工具，提升工作效率和系统安全性。💼

建议收藏本文作为 SSH 管理的参考手册，随时查阅相关命令和技巧。如有任何问题或建议，欢迎留言讨论！💬