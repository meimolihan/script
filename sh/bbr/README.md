# Google BBR 拥塞控制算法管理脚本 🚀

![](https://file.meimolihan.eu.org/img/google-bbr-01.webp)

本文介绍一款功能强大的 BBR 拥塞控制算法管理脚本，支持一键安装、更新和管理 BBR v3 内核及拥塞控制配置，帮助您轻松优化服务器网络性能。

---

## 📋 导航目录

- [📋 脚本信息](#script-info)
- [🖥️ 支持的系统](#supported-systems)
- [🚀 主要功能](#main-features)
- [📥 使用方法](#usage-guide)
- [⚙️ 技术细节](#technical-details)
- [💡 注意事项](#important-notes)
- [🔧 故障排除](#troubleshooting)
- [✨ 脚本特点](#script-features)
- [🎯 使用场景](#use-cases)

---

<a id="script-info"></a>
## 📋 脚本信息

- **脚本名称**: `install-bbr.sh`
- **作者**: Joey
- **最新版本**: 支持自动检测和安装最新版 BBR v3 内核
- **反馈渠道**: [Telegram 群组](https://t.me/+ft-zI76oovgwNmRh) 提供技术交流和支持
- **开源地址**: 脚本基于开源项目开发，持续更新维护

<a id="supported-systems"></a>
## 🖥️ 支持的系统

### 系统要求
- **仅支持基于 Debian/Ubuntu 的系统** (包括 Ubuntu 18.04+, Debian 10+ 等主流版本)
- 需要 `apt-get` 包管理器
- 需要 root 权限执行管理操作

### 支持的架构
- `x86_64` (AMD64) - 大多数云服务器和物理机
- `aarch64` (ARM64) - 树莓派、ARM服务器和移动设备

### 自动安装的依赖
脚本会自动检查并安装以下必要工具：
- `curl`, `wget` - 用于下载内核包和资源文件
- `dpkg` - 用于软件包管理操作
- `awk`, `sed` - 用于文本处理和配置修改
- `sysctl` - 用于内核参数调整
- `jq` - 用于解析JSON数据（获取版本信息）

<a id="main-features"></a>
## 🚀 主要功能

脚本提供以下七大操作选项，满足不同场景需求：

1. **安装或更新 BBR v3 (最新版)** - 自动获取并安装最新版本，保持系统最新
2. **指定版本安装** - 从可用版本列表中选择安装，适合需要特定版本的场景
3. **检查 BBR v3 状态** - 验证当前 BBR 版本和状态，快速诊断问题
4. **启用 BBR + FQ** - 配置 BBR 与 FQ (Fair Queue) 队列算法，平衡流量分配
5. **启用 BBR + FQ_PIE** - 配置 BBR 与 FQ_PIE 队列算法，增强网络稳定性
6. **启用 BBR + CAKE** - 配置 BBR 与 CAKE 队列算法，提供高级流量管理功能
7. **卸载 BBR 内核** - 安全移除由本脚本安装的内核，恢复原系统配置

<a id="usage-guide"></a>
## 📥 使用方法

### 一键执行脚本

**使用 Vercel 仓库:**
```bash
bash <(curl -sL script.meimolihan.eu.org/sh/bbr/install-bbr.sh)
```

**使用 Gitee 仓库:**
```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/bbr/install-bbr.sh)
```



![](https://file.meimolihan.eu.org/screenshot/google-bbr-001.webp) 



### 📝 执行流程

1. 运行脚本后会显示当前系统状态和可选操作菜单
2. 输入对应数字选择操作（1-7）
3. 根据提示完成相应操作
4. 对于内核安装，安装完成后可能需要重启系统生效

### 🔄 安装后验证
安装完成后，可以通过以下命令验证 BBR 状态：
```bash
# 检查当前启用拥塞控制算法
sysctl net.ipv4.tcp_congestion_control

# 检查队列规则
sysctl net.core.default_qdisc

# 查看当前加载的内核模块
lsmod | grep bbr
```

<a id="technical-details"></a>
## ⚙️ 技术细节

### 配置文件
- 系统网络配置保存在 `/etc/sysctl.d/99-joeyblog.conf`
- 内核包来自 GitHub Releases: [byJoey/Actions-bbr-v3](https://github.com/byJoey/Actions-bbr-v3)
- 脚本会自动备份原有配置，便于需要时恢复

### 引导更新
- 脚本会自动检测并使用 `update-grub` 更新引导配置
- 对于 ARM 系统（如 U-Boot），提供相应提示信息
- 支持多内核并存，可自由选择启动内核

### 🔄 版本管理
- 自动检测已安装版本和可用更新
- 支持版本列表显示和选择安装
- 自动清理旧内核包，节省磁盘空间

<a id="important-notes"></a>
## 💡 注意事项

1. **权限要求** - 需要 root 权限执行内核安装和配置修改操作
2. **重启要求** - 安装新内核后需要重启系统才能生效，脚本会提示重启
3. **兼容性** - 脚本会自动卸载旧版本内核以避免冲突，但建议备份重要数据
4. **生产环境** - 对于生产环境，建议先测试再部署，可在测试环境验证效果
5. **网络依赖** - 安装过程需要联网下载内核包，请确保网络连接稳定

<a id="troubleshooting"></a>
## 🔧 故障排除

如果脚本执行出现问题，可以尝试以下排查步骤：

1. **检查网络连接** - 确保服务器可以正常访问互联网和GitHub
2. **确认系统兼容性** - 检查系统是否为支持的Debian/Ubuntu版本
3. **查看错误信息** - 仔细阅读脚本输出的错误信息，通常包含解决线索
4. **手动下载执行** - 如果curl直接执行失败，可以尝试手动下载脚本：
   ```bash
   wget https://raw.githubusercontent.com/byJoey/Actions-bbr-v3/master/install-bbr.sh
   chmod +x install-bbr.sh
   ./install-bbr.sh
   ```
5. **寻求帮助** - 可以通过Telegram群组联系作者或社区获取支持

<a id="script-features"></a>
## ✨ 脚本特点

### 🔄 自动化程度高
- 自动检测系统架构和版本
- 自动安装所需依赖项
- 自动下载和验证内核包
- 自动配置优化参数

### 🛡️ 安全可靠
- 使用官方源和验证过的内核包
- 提供卸载功能，可完整清理
- 配置修改前自动备份
- 错误处理机制完善，避免半完成状态

### 📊 用户体验好
- 清晰的交互提示和进度显示
- 颜色区分不同类型信息
- 详细的状态检查和验证功能
- 多平台支持和完善的文档

<a id="use-cases"></a>
## 🎯 使用场景

这个BBR管理脚本特别适用于以下场景：

### 🌐 网络优化需求
- 海外服务器加速 - 减少国际链路延迟和丢包影响
- 视频流媒体服务 - 提供更稳定的带宽和更低的缓冲
- 游戏服务器 - 降低网络延迟和抖动，提升游戏体验
- 大文件传输 - 提高传输效率和速度稳定性

### 🖥️ 服务器管理
- 批量服务器部署 - 一键标准化网络配置
- 自动化运维 - 可集成到自动化部署流程中
- 性能调优 - 快速测试不同拥塞算法效果
- 临时加速 - 活动期间临时提升网络性能

---

通过这个脚本，您可以轻松管理和优化服务器的网络性能，享受 BBR v3 带来的网络加速效果。无论是个人项目还是企业应用，都能从中获得显著的网络性能提升。

> 💡 提示：建议定期检查更新，以获取最新版本的BBR改进和性能优化。