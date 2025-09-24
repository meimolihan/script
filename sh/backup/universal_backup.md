# Linux 完整目录备份与解压自动化脚本 📂

![](https://file.meimolihan.eu.org/img/linux-rar-01.webp)

> 本文详细介绍通用自动备份脚本的功能、使用方法及恢复指南，帮助您轻松管理重要数据的安全。

---

## 📋 导航目录

- [📦 脚本概述](#script-overview)
- [✨ 一、备份脚本功能与特点](#features)
- [📦 二、解压命令功能与特点](#extract-features)
- [🔧 三、使用方法](#usage)
  - [🌐 1. 远程执行方式（压缩与解压）](#remote-usage)
    - [📦 远程压缩操作](#remote-backup)
    - [📤 本地解压操作](#remote-extract)
  - [💻 2. 本地执行方式（压缩与解压）](#local-usage)
    - [📦 本地压缩操作](#local-backup)
    - [📤 本地解压操作](#local-extract)
- [🔍 四、测试压缩与解压](#test-backup-extract)
- [📁 五、备份原理与压缩机制](#backup-compression)
- [⏰ 六、定时任务设置](#cron-setup)
- [💡 七、注意事项](#notes)

---

<a id="script-overview"></a>
## 📦 脚本概述

通用自动备份脚本是一个高效的数据保护工具，能够自动化完成目录的压缩备份、版本管理和旧备份清理工作。通过简单的命令即可实现一键备份，确保您的数据安全无忧。

---

<a id="features"></a>
## 一、 ✨ 备份脚本功能与特点

- ✅ **完全免交互**：适合自动化任务和定时执行
- ✅ **智能保留策略**：自动保留指定数量的最新备份文件
- ✅ **时间戳标识**：每个备份文件包含精确到秒的创建时间
- ✅ **完整性检查**：自动验证源目录和备份目录的可用性
- ✅ **详细日志输出**：实时显示备份进度和结果
- ✅ **空间管理**：自动清理旧备份，避免磁盘空间不足

---

<a id="extract-features"></a>
## 二、📦 解压命令功能与特点

-   ✅ **灵活解压**：支持解压到当前目录、指定目录，满足不同场景需求
-   ✅ **内容预览**：可在解压前查看归档文件内容，避免覆盖重要文件
-   ✅ **选择性解压**：支持从大型备份中提取单个或特定目录的文件
-   ✅ **权限保持**：完整保留文件原始权限、所有权及时间戳属性
-   ✅ **进度可视化**：使用`-v`参数可显示解压过程的详细文件列表
-   ✅ **通用性强**：标准tar/gzip格式，兼容所有Linux/Unix系统及常见解压软件

---

<a id="usage"></a>

## 三、🔧 使用方法

<a id="remote-usage"></a>
### 1. 远程执行方式（压缩与解压）

- **基本命令格式 `bash universal_backup.sh <源目录> <备份目录> [保留数量]`**

<a id="remote-backup"></a>
#### 📦 远程压缩操作

```bash
# 使用主域名执行
bash <(curl -sL script.meimolihan.eu.org/sh/backup/universal_backup.sh) /源目录 /备份目录 保留数量

# 或使用Gitee镜像执行（国内用户推荐）
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/universal_backup.sh) /源目录 /备份目录 保留数量
```

![](https://file.meimolihan.eu.org/screenshot/universal_backup-001.webp) 

<a id="remote-extract"></a>
#### 📤 本地解压操作

```bash
# 解压到当前目录
tar -xzvf /备份目录/备份文件.tar.gz

# 解压到指定目录
tar -xzvf /备份目录/备份文件.tar.gz -C /目标目录/
```

- **实际解压示例**

```bash
# 解压到当前目录（会在当前目录创建原目录结构）
tar -xzvf /backups/html_20231201_143022.tar.gz

# 解压到指定目录
tar -xzvf /backups/html_20231201_143022.tar.gz -C /var/www/new_html/

# 只查看归档内容而不解压
tar -tzvf /backups/html_20231201_143022.tar.gz

# 解压特定文件
tar -xzvf /backups/html_20231201_143022.tar.gz path/to/specific/file
```

- **解压参数详解**
  - `-x`：从归档中解压文件
  - `-z`：使用gzip解压缩
  - `-v`：显示详细处理过程
  - `-f`：指定归档文件名
  - `-C`：指定解压目标目录

---

<a id="local-usage"></a>
### 💻 2. 本地执行方式（压缩与解压）

<a id="local-backup"></a>
#### 📦 本地压缩操作

- **基本命令格式 `bash universal_backup.sh <源目录> <备份目录> [保留数量]`**

```bash
# 下载备份脚本
cd /mnt && \
wget -c https://gitee.com/meimolihan/script/raw/master/sh/backup/universal_backup.sh

# 赋予执行权限
chmod +x universal_backup.sh

# 解决可能存在的换行符问题（如果需要）
sudo apt install dos2unix
dos2unix universal_backup.sh

# 基本用法（保留3个备份）
/mnt/universal_backup.sh  /源目录 /备份目录

# 指定保留备份数量
/mnt/universal_backup.sh /源目录 /备份目录 保留数量

# 实际示例
/mnt/universal_backup.sh /mnt/test1 /mnt/test2
/mnt/universal_backup.sh /mnt/test1 /mnt/test2 7
```

<a id="local-extract"></a>
#### 📤 本地解压操作

```bash
# 解压到当前目录
tar -xzvf /备份目录/备份文件.tar.gz

# 解压到指定目录
tar -xzvf /备份目录/备份文件.tar.gz -C /目标目录/
```

- **实际解压示例**

```bash
# 解压到当前目录（会在当前目录创建原目录结构）
tar -xzvf /backups/html_20231201_143022.tar.gz

# 解压到指定目录
tar -xzvf /backups/html_20231201_143022.tar.gz -C /var/www/new_html/

# 只查看归档内容而不解压
tar -tzvf /backups/html_20231201_143022.tar.gz

# 解压特定文件
tar -xzvf /backups/html_20231201_143022.tar.gz path/to/specific/file
```

- **解压参数详解**
  - `-x`：从归档中解压文件
  - `-z`：使用gzip解压缩
  - `-v`：显示详细处理过程
  - `-f`：指定归档文件名
  - `-C`：指定解压目标目录

---

<a id="test-backup-extract"></a>
## 四、🔍 测试压缩与解压

以下是一个完整的测试流程，展示如何使用这两个脚本进行压缩和解压操作：

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
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/universal_backup.sh) /mnt/test1 /mnt/test2 5 && \
tree /mnt/test2
```

### 3. 测试 `解压`

```bash
tar -xzvf /mnt/test2/test1_*.tar.gz -C /mnt/test3/ && \
tree /mnt/test3/
```

#### 4. 删除测试文件

```bash
rm -rf /mnt/test1 /mnt/test2 /mnt/test3 && \
ls /mnt
```

这个测试流程展示了：
1. 创建测试目录结构和文件
2. 使用备份脚本将目录压缩为一个tar.gz文件
3. 使用解压脚本将这些压缩包解压到目标目录
4. 验证解压结果是否正确

通过这个完整的测试流程，您可以确保脚本正常工作，并且理解整个压缩和解压的过程。🧪

```bash
root@debian13 ~ # tree /mnt/test1 /mnt/test2 /mnt/test3
/mnt/test1
├── aaa
│   └── test1.txt
├── bbb
│   └── test2.txt
└── ccc
    └── test3.txt
/mnt/test2
/mnt/test3
root@debian13 ~ # bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/backup/universal_backup.sh) /mnt/test1 /mnt/test2 5
=============================================
     完整目录备份脚本（免交互版本）V3.0
=============================================
XXXXXX
=============================================
备份完成! 总共保留 1 个备份文件
=============================================

root@debian13 ~ # tree /mnt/test2
/mnt/test2
└── test1_20250915_103352.tar.gz
```

---

<a id="backup-compression"></a>
## 五、📁 备份原理与压缩机制

### 压缩技术

脚本使用标准的 `tar` 和 `gzip` 工具进行压缩，具有以下特点：

- **高压缩比**：gzip压缩算法在保证速度的同时提供良好的压缩率
- **广泛兼容**：tar.gz格式在所有Linux/Unix系统上均可直接处理
- **保留权限**：完整保留文件权限、所有权和时间戳信息

### 备份流程

1. **参数验证**：检查源目录是否存在，备份目录是否可写
2. **压缩创建**：使用 `tar -czf` 命令创建gzip压缩的归档文件
3. **文件命名**：采用"目录名_年月日_时分秒.tar.gz"格式
4. **清理策略**：按时间排序备份文件，保留最新的N个文件
5. **结果报告**：显示备份大小和当前保留的备份列表

---

<a id="cron-setup"></a>

## 六、⏰ 定时任务设置

### 设置定时自动备份

```bash
# 编辑当前用户的crontab
crontab -e

# 添加以下任务示例：
# 每天凌晨2点执行备份，保留7个备份
0 2 * * * /path/to/universal_backup.sh /var/www/html /backups 7

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

<a id="notes"></a>

## 七、💡 注意事项

1. **权限要求**：运行脚本的用户需要对源目录有读取权限，对备份目录有写入权限
2. **磁盘空间**：确保备份目录有足够的空间存储备份文件
3. **路径规范**：建议使用绝对路径，避免相对路径可能带来的问题
4. **特殊字符**：目录名中避免使用特殊字符，以免影响脚本执行
5. **文件系统**：对于大量小文件，压缩过程可能较慢，建议在系统负载低时执行
6. **网络备份**：如需备份到远程位置，可先本地备份再使用rsync同步

### 性能优化建议

- 对于大型目录，考虑使用更高效的压缩算法（如pigz）
- 使用`ionice`和`nice`调整备份任务的IO和CPU优先级
- 对于数据库应用，建议先停止服务或使用专用备份工具

### 恢复测试建议

定期测试备份文件的恢复过程，确保：
- 备份文件完整无损
- 恢复后的文件权限正确
- 重要数据没有遗漏

---

> 🚀 定期备份是数据安全的重要保障，建议您设置定时任务自动执行此脚本，为您的重要数据提供持续的保护。定期测试恢复流程，确保在需要时能够快速有效地恢复数据。
