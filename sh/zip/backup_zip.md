# Linux 文件压缩与解压工具脚本集 📦

![](https://file.meimolihan.eu.org/img/zip-gz-01.webp) 

> 本文档提供一系列用于文件压缩与解压的 Bash 脚本，支持 ZIP 和 TAR.GZ 格式，可自动化处理当前目录下的文件与子目录。所有脚本均通过远程链接一键执行，方便快捷！

---

## 📚 导航目录

- [📦 ZIP 格式处理](#zip-format)
  - [压缩为ZIP文件](#backup-zip)
  - [解压ZIP文件](#unzip)
- [📦 TAR.GZ 格式处理](#tar-gz-format)
  - [压缩为TAR.GZ文件](#backup-gz)
  - [解压TAR.GZ文件](#untar-gz)
- [💡 使用注意事项](#notes)
- [🔧 自定义与扩展](#customization)

---

<a id="zip-format"></a>
## 📦 ZIP 格式处理

本节介绍与 ZIP 格式相关的压缩与解压操作。

<a id="backup-zip"></a>
### 📦 压缩为ZIP文件

此功能用于遍历当前目录下的所有子目录，并将每个子目录单独压缩为一个同名的 `.zip` 文件。适合用于批量备份或整理项目目录。

**✨ 特点：**
- 🔄 自动化遍历：无需手动指定路径，自动处理所有子目录。
- 🗂️ 保留结构：压缩后的 ZIP 文件完整保留原始目录结构。
- 🌐 远程脚本：直接通过 curl 下载并执行，无需本地保存脚本。

**📝 使用命令：**
```bash
bash <(curl -sL script.meimolihan.eu.org/sh/zip/backup-zip.sh)
```

- 或使用国内镜像（若访问 GitHub 受限）：

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/backup-zip.sh)
```

![backup-zip压缩示例](https://file.meimolihan.eu.org/screenshot/backup-zip-001.webp) 

<a id="unzip"></a>
### 🔓 解压ZIP文件

此功能用于遍历当前目录下的所有 `.zip` 文件，并将每个 ZIP 文件解压到当前目录下。适用于批量恢复备份或提取多个压缩包。

**✨ 特点：**
- 🔄 批量处理：自动识别所有 ZIP 文件，无需逐个解压。
- 📂 解压到当前目录：所有文件提取到当前文件夹，保持路径清晰。
- ⚡ 一键执行：简化重复性操作，提高效率。

**📝 使用命令：**
```bash
bash <(curl -sL script.meimolihan.eu.org/sh/zip/unzip.sh)
```

- 或使用国内镜像：

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/zip/unzip.sh)
```

---

<a id="tar-gz-format"></a>
## 📦 TAR.GZ 格式处理

本节介绍与 TAR.GZ 格式相关的压缩与解压操作。

<a id="backup-gz"></a>
### 📦 压缩为TAR.GZ文件

此功能用于遍历当前目录下的所有子目录，并将每个子目录压缩为一个同名的 `.tar.gz` 文件。TAR.GZ 格式在 Linux 环境中广泛使用，具有较好的压缩效率和兼容性。

**✨ 特点：**
- 🐧 Linux 友好：TAR.GZ 是 Linux 系统常见的压缩格式。
- 📦 高压缩比：相比 ZIP，TAR.GZ 通常能提供更高的压缩率。
- 🔗 远程执行：直接通过网络脚本执行，无需本地安装。

**📝 使用命令：**
```bash
bash <(curl -sL script.meimolihan.eu.org/sh/gz/backup_gz.sh)
```

- 或使用国内镜像：

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/gz/backup_gz.sh)
```

![backup-gz压缩示例](https://file.meimolihan.eu.org/screenshot/backup-gz-001.webp) 

<a id="untar-gz"></a>
### 🔓 解压TAR.GZ文件

此功能用于遍历当前目录下的所有 `.tar.gz` 文件，并将每个文件解压到当前目录下。适用于从 TAR.GZ 备份中恢复数据或提取压缩内容。

**✨ 特点：**
- 🔍 自动识别：自动查找所有 TAR.GZ 文件并进行处理。
- 🗃️ 保留权限：解压时保留原始文件权限和属性（适用于 Linux 系统）。
- 🚀 快速执行：一条命令即可完成所有解压操作。

**📝 使用命令：**
```bash
bash <(curl -sL script.meimolihan.eu.org/sh/gz/untar.sh)
```

- 或使用国内镜像：

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/gz/untar.sh)
```

---

<a id="notes"></a>
## 💡 使用注意事项

1.  **🌐 网络依赖**：这些脚本需要通过 curl 下载，请确保您的系统已连接互联网，并且能够访问 `script.meimolihan.eu.org` 或 `gitee.com`。
2.  **🔐 安全提醒**：执行远程脚本前，请确保您信任脚本来源。建议先检查脚本内容（可通过 curl 下载后查看），再执行。
3.  **📁 目录结构**：压缩脚本会遍历当前目录下的所有子目录，每个子目录生成一个压缩文件。请确保当前目录下没有无关子目录，以免产生多余文件。
4.  **⚙️ 系统兼容**：这些脚本主要在 Linux 或 macOS 环境中测试通过，Windows 用户可能需要使用 WSL 或类似环境。
5.  **⚠️ 覆盖风险**：解压时，如果当前目录已存在同名文件或文件夹，可能会被覆盖，请提前做好备份。

---

<a id="customization"></a>
## 🔧 自定义与扩展

如果您需要修改脚本以满足特定需求（如排除某些目录、添加压缩密码等），可以先将脚本下载到本地，然后进行编辑：

```bash
# 下载脚本到本地
curl -sL script.meimolihan.eu.org/sh/zip/backup-zip.sh > my-backup-script.sh
# 编辑脚本
nano my-backup-script.sh
# 授予执行权限
chmod +x my-backup-script.sh
# 运行本地脚本
./my-backup-script.sh
```

**🎯 常见自定义场景：**
- 添加压缩密码（ZIP 格式支持）。
- 排除特定目录或文件（如 node_modules、.git 等）。
- 修改压缩级别（ZIP 和 TAR.GZ 均支持）。
- 将压缩文件上传到远程服务器或云存储。

---

希望这些脚本能帮助您更高效地管理文件！如有问题或建议，欢迎反馈。🚀