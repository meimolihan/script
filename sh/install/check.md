# Linux 检查脚本安装工具 🚀

![](https://file.meimolihan.eu.org/img/linux-check-01.webp) 

> 这是一个用于自动下载和安装 Linux 系统检查脚本的 Bash 工具。它会从 Gitee 代码仓库下载 `linux-check.sh` 脚本，并创建便捷的执行方式。

---

## 主要功能 ✨

1. **📥 自动下载**: 从 Gitee 仓库下载最新的 `linux-check.sh` 脚本
2. **📁 安装到系统**: 将脚本保存到 `/etc/profile.d/` 目录
3. **🔗 创建快捷方式**: 建立符号链接 `/usr/local/bin/m` 指向检查脚本
4. **⚙️ 权限设置**: 自动为脚本添加执行权限
5. **🚀 立即执行**: 安装完成后立即运行检查脚本

---

## 支持的系统 🖥️

目前已在以下系统上测试通过：

- **🐧 Debian** - 稳定可靠的发行版
- **🛡️ PVE (Proxmox VE)** - 专业的虚拟化环境
- **🎯 FNOS** - 特定定制系统
- **🌱 Ubuntu** - 流行的桌面和服务器系统

---

## 使用方法

### 直接运行（推荐）🎯
```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/install/check.sh)
```



![](https://file.meimolihan.eu.org/screenshot/linux-check-001.webp) 



### 参数说明 📋

安装脚本支持所有 `linux-check.sh` 的原始参数，例如：
- `-h` 或 `--help`: 显示帮助信息 ℹ️
- `-v` 或 `--version`: 显示版本信息 🔖
- 其他检查脚本支持的参数

---

## 安装后的使用方式 💡

安装完成后，您可以通过以下方式使用：

1. **使用快捷命令**:
   ```bash
   m [参数]
   ```

2. **使用完整路径**:
   ```bash
   /etc/profile.d/linux-check.sh [参数]
   ```

---

## 文件位置 📂

- **📄 主脚本**: `/etc/profile.d/linux-check.sh`
- **🔗 快捷方式**: `/usr/local/bin/m`

---

## 系统要求 💻

- 🐧 Linux 操作系统
- 💬 Bash shell
- 🌐 curl 工具（用于下载）
- 👑 需要有 root 权限或 sudo 权限

---

## 注意事项 ⚠️

1. 🌐 需要网络连接来下载脚本
2. 🔐 需要管理员权限来写入系统目录
3. 📝 安装过程会覆盖已存在的同名文件
4. 🏷️ 脚本来源为 Gitee 代码仓库，请确保网络可访问

---

## 卸载方法 🗑️

如需卸载，只需删除相关文件：
```bash
sudo rm -f /etc/profile.d/linux-check.sh /usr/local/bin/m
```

---

## 安全提示 🔒

请在信任的环境中使用此脚本，建议在运行前检查脚本内容以确保安全性。

---

**🎉 享受便捷的 Linux 系统检查体验！**



