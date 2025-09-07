#!/bin/bash

# 日志文件位置
LOG_FILE="/var/log/cron-tasks/emby-hosts.log"

# 同步源和目标路径
SOURCE_FILE="/etc/hosts"
TARGET_DIR="/vol1/1000/compose/emby/config"
TARGET_FILE="$TARGET_DIR/hosts"

# 创建日志目录
mkdir -p /var/log/cron-tasks

# 函数：同时输出到终端和日志文件
log_and_echo() {
    echo "$1"
    echo "$1" >> $LOG_FILE
}

# 记录脚本开始执行
log_and_echo "================================================================"
log_and_echo "【主机文件同步任务】开始时间: $(date +"%Y-%m-%d %H:%M:%S")"
log_and_echo "================================================================"

# 检查源文件是否存在
if [ ! -f "$SOURCE_FILE" ]; then
    log_and_echo "【错误】源文件不存在: $SOURCE_FILE"
    log_and_echo "【状态】同步任务失败，源文件未找到"
    log_and_echo "================================================================"
    exit 1
fi

# 检查目标目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    log_and_echo "【错误】目标目录不存在: $TARGET_DIR"
    log_and_echo "【状态】同步任务失败，目标目录未找到"
    log_and_echo "================================================================"
    exit 1
fi

# 记录同步前信息
log_and_echo "【信息】源文件: $SOURCE_FILE"
log_and_echo "【信息】目标位置: $TARGET_FILE"
log_and_echo "【信息】源文件大小: $(du -h "$SOURCE_FILE" | cut -f1)"
log_and_echo "【信息】开始同步主机文件..."

# 执行同步 - 同时输出到终端和日志
log_and_echo "【执行】开始执行 rsync 命令..."
rsync -avhzp --progress --delete "$SOURCE_FILE" "$TARGET_FILE" 2>&1 | tee -a $LOG_FILE
SYNC_RESULT=${PIPESTATUS[0]}

# 检查同步结果
if [ $SYNC_RESULT -eq 0 ]; then
    log_and_echo "【成功】主机文件同步完成"
    
    # 验证目标文件
    if [ -f "$TARGET_FILE" ]; then
        log_and_echo "【验证】目标文件已创建/更新"
        log_and_echo "【验证】目标文件大小: $(du -h "$TARGET_FILE" | cut -f1)"
        log_and_echo "【验证】同步后文件校验: $(md5sum "$TARGET_FILE" | cut -d' ' -f1)"
    else
        log_and_echo "【警告】同步完成但目标文件未找到"
    fi
else
    log_and_echo "【错误】同步过程出现问题 (退出代码: $SYNC_RESULT)"
    log_and_echo "【状态】同步任务可能未完成"
fi

# 记录结束时间
log_and_echo "【信息】同步结束时间: $(date +"%Y-%m-%d %H:%M:%S")"
log_and_echo "【信息】任务执行时长: ${SECONDS} 秒"
log_and_echo "================================================================"
log_and_echo ""