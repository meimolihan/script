# Linux 子目录分离备份与解压自动化脚本 📂

![](https://file.meimolihan.eu.org/img/linux-rar-01.webp)

> 本文介绍两个实用的自动化脚本：`directory_backup.sh` 和 `directory_extract.sh`，它们分别用于目录备份和解压操作。这些脚本采用免交互设计，非常适合集成到自动化运维流程或定时任务中，能够显著提高文件管理效率。✨

---

<a id="navigation"></a>
## 📋 导航目录
- [📚 脚本简介](#script-intro)
- [⚙️ 一、备份脚本功能与特点](#backup-features)
- [📦 二、解压脚本功能与特点](#extract-features)
- [🚀 三、使用方法](#usage)
  - [🌐 1. 远程执行方式（压缩与解压）](#remote-usage)
    - [📦 远程压缩操作](#remote-backup)
    - [📤 远程解压操作](#remote-extract)
  - [💻 2. 本地执行方式（压缩与解压）](#local-usage)
    - [📦 本地压缩操作](#local-backup)
    - [📤 本地解压操作](#local-extract)
- [🔍 四、测试压缩与解压](#test-backup-extract)
- [🔧 五、脚本功能概括](#script-summary)
- [⏰ 六、定时任务设置](#cron-setup)
- [💡 七、使用场景与建议](#scenarios-tips)

---

<a id="script-intro"></a>
## 📚 脚本简介

本文介绍两个实用的自动化脚本：`directory_backup.sh` 和 `directory_extract.sh`，它们分别用于目录备份和解压操作。这些脚本采用免交互设计，非常适合集成到自动化运维流程或定时任务中，能够显著提高文件管理效率。✨

无论是系统管理员需要定期备份重要数据，还是开发人员需要快速部署环境，这两个脚本都能提供简单而强大的解决方案。它们支持多种压缩格式，具有详细的执行日志和错误报告，让用户随时了解操作状态。

---

<a id="backup-features"></a>
## 一、⚙️ 备份脚本功能与特点

**`directory_backup.sh` 是一个专业的目录备份工具，具有以下突出特点：**

- **🎯 自动化备份**：一键指定备份目录下的所有非隐藏子目录，无需人工干预
- **📁 智能压缩**：每个子目录单独压缩为 `.tar.gz` 文件，保持结构清晰
- **🔄 自动覆盖**：免交互设计自动覆盖已存在的备份文件，适合自动化任务
- **⏰ 日期标记**：备份文件名格式为 `目录名-YYYY-MM-DD-HH-MM-SS.tar.gz`，便于版本管理
- **👁️ 透明操作**：提供详细的执行日志，实时显示备份进度和结果
- **🚫 智能过滤**：自动跳过隐藏目录（以`.`开头的目录），避免不必要的备份

该脚本特别适合需要定期备份数据的场景，如网站数据备份、配置文件备份或项目版本存档等。🔒

---

<a id="extract-features"></a>
## 二、📦 解压脚本功能与特点

**`directory_extract.sh` 是一个多功能解压工具，具有以下核心功能：**

- **🔓 多格式支持**：全面支持 `.tar.gz`, `.tgz`, `.tar`, `.zip`, `.gz` 等多种压缩格式
- **📂 批量处理**：自动遍历当前目录下的所有压缩包，一次性完成解压操作
- **🏗️ 自动创建**：如果目标目录不存在，会自动创建所需目录结构
- **📊 详细报告**：显示每个文件的解压状态和最终统计结果，一目了然
- **🛡️ 错误处理**：具备完善的错误处理机制，单个文件失败不影响其他操作
- **🔍 智能识别**：正确处理复合扩展名（如 `.tar.gz`），避免重复解压问题

无论是从备份恢复数据，还是处理下载的压缩包集合，这个脚本都能大大简化工作流程。📤

---

<a id="usage"></a>
## 三、🚀 使用方法

<a id="remote-usage"></a>
### 1. 🌐 远程执行方式（压缩与解压）

最简单的方法是直接通过远程URL执行脚本，无需下载：

<a id="remote-backup"></a>
#### 📦 远程压缩操作

- **基本命令格式 `bash directory_backup.sh <源目录> <备份目录> [保留数量]`**

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/backup/directory_backup.sh) /mnt/test1 /mnt/test2/ 5
```

- **或使用Gitee镜像：**

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/directory_backup.sh) /mnt/test1 /mnt/test2/ 5
```

![](https://file.meimolihan.eu.org/screenshot/directory_backup-001.webp) 

<a id="remote-extract"></a>
#### 📤 远程解压操作

```bash
# 切换到需要解压文件目录并执行解压到指定目录
cd /mnt/test2 && \
bash <(curl -sL script.meimolihan.eu.org/sh/backup/directory_extract.sh) /mnt/test3/ && \
tree /mnt/test3
```

- **或使用Gitee镜像：**

```bash
# 切换到需要解压文件目录并执行解压到指定目录
cd /mnt/test2 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/directory_extract.sh) /mnt/test3/ && \
tree /mnt/test3
```

---

<a id="local-usage"></a>
### 2. 💻 本地执行方式（压缩与解压）

如果需要频繁使用，可以下载脚本到本地：

<a id="local-backup"></a>
#### 📦 本地压缩操作

- **基本命令格式 `bash directory_backup.sh <源目录> <备份目录> [保留数量]`**

```bash
# 下载备份脚本
wget -c https://gitee.com/meimolihan/script/raw/master/sh/backup/directory_backup.sh

# 赋予执行权限
chmod +x directory_backup.sh

# 解决可能存在的换行符问题（如果需要）
sudo apt install dos2unix
dos2unix directory_backup.sh

# 切换到需要备份的目录并执行备份到指定目录
bash directory_backup.sh /mnt/test1 /mnt/test2 5 && \
ls /mnt/test2
```

<a id="local-extract"></a>
#### 📤 本地解压操作

```bash
# 下载解压脚本
wget -c https://gitee.com/meimolihan/script/raw/master/sh/backup/directory_extract.sh

# 赋予执行权限
chmod +x directory_extract.sh

# 解决可能存在的换行符问题（如果需要）
sudo apt install dos2unix
dos2unix directory_extract.sh

# 执行脚本
# 切换到需要解压文件目录并执行解压到指定目录
cd /mnt/test2 && \
/mnt/directory_extract.sh /mnt/test3 && \
tree /mnt/test3
```

解压脚本的使用方法类似，只需替换相应的脚本名称和URL即可。

---

<a id="test-backup-extract"></a>
## 四、🔍 测试压缩与解压

- 以下是一个完整的测试流程，展示如何使用这两个脚本进行压缩和解压操作：

### 1. 创建测试文件

```bash
mkdir -p /mnt/{test1,test2,test3} && \
mkdir -p /mnt/test1/{aaa,bbb,ccc} && \
echo "测试文件内容" > /mnt/test1/aaa/test1.txt && \
echo "另一个测试文件" > /mnt/test1/bbb/test2.txt && \
echo "第三个测试文件" > /mnt/test1/ccc/test3.txt && \
tree /mnt/test1 /mnt/test2 /mnt/test3
```

### 2. 测试 `压缩`

- 这里指定了 `保留数量 5`，默认是`保留数量 3`。

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/directory_backup.sh) /mnt/test1 /mnt/test2 5 && \
tree /mnt/test2
```

### 3. 测试`解压`

```bash
cd /mnt/test2 && \
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/directory_extract.sh) /mnt/test3/ && \
tree /mnt/test3
```

### 4. 删除测试文件

```bash
cd .. && \
rm -rf /mnt/test1 /mnt/test2 /mnt/test3 && \
ls /mnt
```

这个测试流程展示了：
1. 创建测试目录结构和文件
2. 使用备份脚本将目录压缩为多个tar.gz文件
3. 使用解压脚本将这些压缩包解压到目标目录
4. 验证解压结果是否正确

通过这个完整的测试流程，您可以确保脚本正常工作，并且理解整个压缩和解压的过程。🧪

```bash
root@debian13 / # tree /mnt/test1 /mnt/test2 /mnt/test3
/mnt/test1
├── aaa
│   └── test1.txt
├── bbb
│   └── test2.txt
└── ccc
    └── test3.txt
/mnt/test2
/mnt/test3
root@debian13 / # bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/directory_backup.sh) /mnt/test1 /mnt/test2 5
=============================================
     子目录单独备份脚本（免交互版本）V3.0
=============================================
XXXXXX
=============================================
备份完成! 总共保留 0 个备份文件
=============================================

root@debian13 / # tree /mnt/test2
/mnt/test2
├── aaa_20250915_104019.tar.gz
├── bbb_20250915_104019.tar.gz
└── ccc_20250915_104019.tar.gz
···

---

<a id="script-summary"></a>
## 五、🔧 脚本功能概括

### directory_backup.sh
- **核心功能**：自动化备份当前工作目录下的所有非隐藏子目录
- **备份格式**：每个子目录压缩为单独的 `目录名-YYYY-MM-DD.tar.gz` 文件
- **适用场景**：定期自动化备份、系统定时任务、脚本集成和批处理操作

### directory_extract.sh
- **核心功能**：自动解压当前目录下的所有压缩包到指定目录
- **支持格式**：`.tar.gz`, `.tgz`, `.tar`, `.zip`, `.gz`
- **适用场景**：从备份恢复数据、批量处理下载的压缩包、环境部署

---

<a id="cron-setup"></a>
## 六、⏰ 定时任务设置

### 设置定时自动备份

```bash
# 编辑当前用户的crontab
crontab -e

# 添加以下任务示例：
# 每天凌晨2点执行备份，保留7个备份
0 2 * * * bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/directory_backup.sh) /mnt/test2/

# 每周日凌晨1点执行备份，保留4个备份
0 1 * * 0 /path/to/universal_backup.sh /home/user/documents /mnt/backup 4

# 每6小时执行一次备份
0 */6 * * * /path/to/universal_backup.sh /important/data /backups 10
```

### 日志记录配置

```bash
# 将输出同时记录到日志文件
0 2 * * * /path/to/universal_backup.sh /var/www/html /backups 7 >> /var/log/backup.log 2>&1

# 只记录错误信息
0 2 * * * /path/to/universal_backup.sh /var/www/html /backups 7 > /dev/null 2>> /var/log/backup-error.log
```

---

<a id="scenarios-tips"></a>
## 七、💡 使用场景与建议

### 常见使用场景
1. **🔄 定期数据备份**：结合cron定时任务，定期备份重要数据
2. **🚚 项目部署**：快速解压多个组件包到指定目录
3. **📦 数据迁移**：将数据打包后迁移到新服务器或新位置
4. **🛡️ 版本归档**：定期创建项目或数据的版本快照

### 实用建议
1. **🔐 权限管理**：确保运行脚本的用户有足够的读写权限
2. **💾 空间检查**：在执行备份前检查目标磁盘空间是否充足
3. **📝 日志监控**：关注脚本输出，及时发现和处理错误
4. **🔄 测试验证**：首次使用前在小范围测试，验证脚本行为符合预期
5. **⏰ 定时任务**：使用cron等工具设置定期自动执行备份任务

### 高级技巧
- 结合其他工具（如rsync）实现增量备份
- 使用脚本返回值（exit code）在自动化流程中判断执行结果
- 通过重定向输出保存执行日志：`./script.sh /backup/dir > backup.log 2>&1`

这两个脚本虽然简单，但功能强大，能够满足大多数日常备份和解压需求。通过合理使用，可以显著提高工作效率并减少人为错误。🎯

---

*如有问题或建议，欢迎反馈！希望这些脚本能为您的工作带来便利。* 😊
