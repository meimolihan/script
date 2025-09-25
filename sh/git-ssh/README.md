# Git SSH 密钥自动配置脚本使用指南 🚀

![](https://file.meimolihan.eu.org/img/git-ssh-01.webp) 

---

## 目录导航 📚

- [✨ 简介](#introduction) 
- [🌟 功能特点](#features)
- [📋 一、使用方法](#usage)
  - [🐱 1. Gitee SSH 配置流程](#gitee-usage)
  - [🐱 2. GitHub SSH 配置流程](#github-usage)
- [🔍 二、脚本详解](#script-details)
- [⚙️ 三、配置说明](#configuration)
- [🛠️ 四、故障排除](#troubleshooting)

---

<a id="introduction"></a>
## 简介 ✨

本仓库提供两个**高效自动化脚本**，专门用于快速配置 Gitee 和 GitHub 的 SSH 密钥连接。这些脚本采用**全自动智能化流程**，用户只需进行简单交互即可完成从 Git 环境检测到 SSH 连接测试的完整配置流程。

### 🎯 解决痛点
- **传统配置复杂**：手动配置 SSH 密钥需要多个步骤，容易出错
- **平台差异处理**：不同代码托管平台（Gitee/GitHub）配置要求不同
- **系统兼容性**：不同操作系统和发行版的环境差异

### 📊 核心价值
通过自动化脚本，将原本需要 10-15 分钟的手动配置过程缩短至 **2-3 分钟**，大幅提升开发环境 setup 效率！

---

<a id="features"></a>
## 功能特点 🌟

### 🔧 全自动化体验
- **智能环境检测**：自动识别系统类型和包管理器
- **一键式安装**：从 Git 安装到 SSH 配置全程自动化
- **交互式引导**：关键步骤等待用户确认，避免误操作

### 🌍 多平台兼容
| 平台        | 支持情况   | 特色功能                                             |
| ----------- | ---------- | ---------------------------------------------------- |
| **Linux**   | ✅ 全面支持 | 自动识别发行版（Debian/Ubuntu/CentOS/RHEL/openSUSE） |
| **macOS**   | ✅ 完美运行 | 原生终端支持，Homebrew 环境兼容                      |
| **Windows** | ✅ Git Bash | 完整的 Linux-like 环境体验                           |

### 🛡️ 安全可靠
- **强加密标准**：使用 4096 位 RSA 加密算法
- **密钥隔离**：为每个平台生成独立的密钥对
- **权限控制**：自动设置正确的文件权限（700/600）

### 💡 用户友好设计
- **彩色终端输出**：不同信息级别使用不同颜色标识
- **进度提示**：清晰的步骤编号和状态反馈
- **错误处理**：完善的异常捕获和友好错误提示

---

<a id="usage"></a>
## 一、使用方法 📋

<a id="gitee-usage"></a>
### 1. 🐱 Gitee SSH 配置流程
```bash
# Vercel 仓库
bash <(curl -sL script.meimolihan.eu.org/sh/git-ssh/gitee-ssh-init.sh)

# Gitee 仓库
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git-ssh/gitee-ssh-init.sh)
```

![Gitee-ssh](https://file.meimolihan.eu.org/screenshot/gitee-git-ssh-001.webp) 

<a id="github-usage"></a>
### 2. 🐱 GitHub SSH 配置流程
```bash
# Vercel 仓库
bash <(curl -sL script.meimolihan.eu.org/sh/git-ssh/github-ssh-init.sh)

# Gitee 仓库
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/git-ssh/github-ssh-init.sh)
```

![GitHub-ssh](https://file.meimolihan.eu.org/screenshot/github-git-ssh-001.webp) 

### 🔄 详细执行流程

#### 步骤 1: 环境检测与准备 🛠️
- ✅ 检测系统类型和包管理器
- ✅ 自动安装 Git（如未安装）
- ✅ 验证 Git 版本兼容性

#### 步骤 2: Git 全局配置 ⚙️
```bash
# 自动设置的用户配置
git config --global user.name "您的用户名"
git config --global user.email "您的邮箱"
```

#### 步骤 3: SSH 密钥生成 🔑
- ✅ 生成 4096 位 RSA 密钥对
- ✅ 使用邮箱作为密钥注释标识
- ✅ 密钥文件自动命名和存储

#### 步骤 4: 公钥添加指导 👨‍💻
```
==================================================
您的 SSH 公钥如下（请完整复制）：
ssh-rsa AAAAB3NzaC1yc2E... meimolihan@gmail.com
==================================================
请打开 Gitee 添加页面：https://gitee.com/profile/sshkeys
```

#### 步骤 5: 自动配置写入 📝
- ✅ 创建 ~/.ssh/config 文件
- ✅ 添加平台特定的 SSH 配置
- ✅ 更新 known_hosts 文件

#### 步骤 6: 连接测试验证 ✅
```bash
# 测试 Gitee 连接
ssh -T git@gitee.com

# 测试 GitHub 连接  
ssh -T git@github.com
```

### ⏱️ 时间预估
- **首次运行**：约 2-3 分钟（包含用户交互时间）
- **后续运行**：约 30 秒（复用现有配置）

<a id="script-details"></a>
## 二、脚本详解 🔍

### 🏗️ 架构设计

#### 模块化函数设计
```bash
# 主要功能模块
install_git_if_needed()    # 环境检测与安装
step_git_config()         # Git 配置设置
step_gen_key()           # 密钥生成管理
step_show_pub_and_wait() # 用户交互引导
step_ssh_config()        # SSH 配置写入
step_known_hosts()       # 主机密钥管理
step_test()              # 连接测试验证
```

#### 错误处理机制
```bash
set -euo pipefail  # 严格错误处理模式
# -e: 命令失败立即退出
# -u: 使用未定义变量时报错
# -o pipefail: 管道命令失败整体失败
```

### 🔄 智能适配逻辑

#### 多系统包管理器检测
```bash
install_git_if_needed() {
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu 系统
        sudo apt-get update -qq && sudo apt-get install -y git
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL 系统
        if command -v dnf &>/dev/null; then
            sudo dnf -y install git  # 新版本使用 dnf
        else
            sudo yum -y install git  # 老版本使用 yum
        fi
    elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ]; then
        # openSUSE 系统
        sudo zypper -n install git
    else
        log_error "未识别的 Linux 发行版"
        exit 1
    fi
}
```

### 📊 平台特性对比

| 功能特性     | Gitee 脚本         | GitHub 脚本         | 差异说明                   |
| ------------ | ------------------ | ------------------- | -------------------------- |
| **连接端口** | 标准 22 端口       | 22 + 443 端口       | GitHub 支持 HTTPS 端口备用 |
| **主机验证** | gitee.com          | ssh.github.com      | GitHub 使用专用 SSH 端点   |
| **欢迎消息** | Gitee 个性化欢迎语 | GitHub 官方欢迎信息 | 平台特定的连接成功提示     |
| **配置优化** | 标准 SSH 配置      | 多端口备用配置      | GitHub 针对网络环境的优化  |

<a id="configuration"></a>
## 三、配置说明 ⚙️

### 🎛️ 自定义变量调整

#### 基础身份配置
```bash
# 📍 在脚本开头修改这些变量即可个性化配置

# Gitee 专用配置
GITEE_USER="meimolihan"                    # 您的 Gitee 用户名
GITEE_EMAIL="meimolihan@gmail.com"         # 您的 Gitee 验证邮箱
KEY_COMMENT="$GITEE_EMAIL"                 # 密钥注释（建议使用邮箱）

# GitHub 专用配置  
GITHUB_USER="meimolihan"                   # 您的 GitHub 用户名
GITHUB_EMAIL="meimolihan@gmail.com"        # 您的 GitHub 验证邮箱
KEY_COMMENT="$GITHUB_EMAIL"                # 密钥注释标识
```

#### 文件路径配置
```bash
# 🔐 密钥文件存储路径（一般无需修改）
KEY_FILE="$HOME/.ssh/id_rsa_gitee"         # Gitee 密钥路径
KEY_FILE="$HOME/.ssh/id_rsa_github"        # GitHub 密钥路径
```

### 📁 生成的文件结构

```
~/.ssh/
├── 🗝️ id_rsa_gitee          # Gitee 私钥（权限 600）
├── 🔓 id_rsa_gitee.pub      # Gitee 公钥（权限 644）
├── 🗝️ id_rsa_github         # GitHub 私钥（权限 600）
├── 🔓 id_rsa_github.pub     # GitHub 公钥（权限 644）
├── ⚙️ config               # SSH 主配置文件（权限 600）
└── 🌐 known_hosts          # 可信主机列表（权限 644）
```

### 🔧 SSH 配置详解

#### 优化后的 config 文件
```bash
# Gitee 配置段
Host gitee.com
    User git
    Hostname gitee.com
    IdentityFile ~/.ssh/id_rsa_gitee    # 指定专用密钥
    IdentitiesOnly yes                 # 只使用指定密钥
    PreferredAuthentications publickey # 优先公钥认证

# GitHub 配置段（包含端口备用）
Host github.com
    User git
    Hostname ssh.github.com            # GitHub SSH 专用端点
    Port 443                          # HTTPS 备用端口
    IdentityFile ~/.ssh/id_rsa_github
    IdentitiesOnly yes
    PreferredAuthentications publickey
```

<a id="troubleshooting"></a>
## 四、故障排除 🛠️

### 🔍 常见问题速查表

| 问题现象               | 可能原因             | 解决方案                  |
| ---------------------- | -------------------- | ------------------------- |
| **❌ 脚本执行权限错误** | 文件未设置执行权限   | `chmod +x script-name.sh` |
| **❌ Git 安装失败**     | 网络问题或镜像源错误 | 检查网络连接，更换镜像源  |
| **❌ 密钥生成失败**     | .ssh 目录权限问题    | `chmod 700 ~/.ssh`        |
| **❌ SSH 连接超时**     | 防火墙或网络限制     | 检查 22/443 端口是否开放  |
| **❌ 认证被拒绝**       | 公钥未正确添加       | 重新复制完整公钥到平台    |

### 🐛 详细排错指南

#### 1. 权限问题修复 🔐
```bash
# 完整的权限修复命令序列
chmod 700 ~/.ssh                          # SSH 目录权限
chmod 600 ~/.ssh/config                   # 配置文件权限
chmod 600 ~/.ssh/id_rsa_*                 # 所有私钥文件权限
chmod 644 ~/.ssh/*.pub ~/.ssh/known_hosts # 公钥和已知主机文件权限
```

#### 2. 连接测试与诊断 🌐
```bash
# 详细连接测试（显示调试信息）
ssh -T -v git@gitee.com    # 测试 Gitee 连接并显示详细日志
ssh -T -v git@github.com   # 测试 GitHub 连接并显示详细日志

# 配置验证命令
ssh -G gitee.com          # 显示最终使用的 SSH 配置
ssh-keygen -l -f ~/.ssh/id_rsa_gitee  # 验证密钥指纹
```

#### 3. 脚本调试技巧 🔧
```bash
# 语法检查
bash -n gitee-ssh-init.sh

# 详细执行跟踪
bash -x gitee-ssh-init.sh

# 输出重定向（用于日志分析）
./gitee-ssh-init.sh > setup.log 2>&1
```

### 💡 高级技巧

#### 多平台密钥管理
```bash
# 查看所有密钥的指纹信息
for key in ~/.ssh/id_rsa_*; do
    if [[ -f "$key" && ! "$key" == *.pub ]]; then
        echo "密钥: $(basename $key)"
        ssh-keygen -l -f "$key"
        echo "---"
    fi
done
```

#### 配置备份与恢复
```bash
# 备份 SSH 配置
cp -r ~/.ssh ~/.ssh_backup_$(date +%Y%m%d)

# 恢复 SSH 配置（谨慎操作）
# cp -r ~/.ssh_backup_20241201/* ~/.ssh/
```

## 🎯 最佳实践建议

### ✅ 安全建议
1. **定期更换密钥**：建议每 6-12 个月更换一次 SSH 密钥
2. **使用强密码**：虽然脚本生成无密码密钥，但生产环境建议设置密钥密码
3. **多因素认证**：在平台端启用 2FA 增强安全性

### ✅ 维护建议
1. **版本控制**：将自定义配置的脚本版本进行 git 管理
2. **文档更新**：随着平台政策变化及时更新脚本和文档
3. **测试验证**：在重要变更前在测试环境验证脚本功能

---

**📅 最后更新**: 2024年1月  
**👨‍💻 作者**: meimolihan  
**📧 联系方式**: meimolihan@gmail.com  
**🐛 问题反馈**: 欢迎提交 Issue 和 Pull Request 改进脚本功能  
