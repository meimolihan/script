#!/bin/bash

# 配置目录 - 修改为当前目录
BASE_DIR="$(pwd)"

# 服务列表 - 每行格式: "服务名 是否启用(yes/no)"
services=(
    "1panel          no"
    "aipan           yes"
    "allinssl        yes"
    "dpanel          yes"
    "easyvoice       yes"
    "emby            yes"
    "halo            no"
    "istoreos        yes"
    "it-tools        no"
    "kspeeder        no"
    "libretv         yes"
    "md              no"
    "metube          yes"
    "nastools        yes"
    "random-pic-api  no"
    "reubah          yes"
    "speedtest       yes"
    "sun-panel       no"
    "taoSync         yes"
    "tvhelper        yes"
    "uptime-kuma     yes"
    "watchtower      yes"
    "xiaomusic       no"
    "xunlei          no"
    "openlist        yes"
    "navidrome       yes"
    "musicn          yes"
    "nginx-file-server no"
)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 恢复默认颜色

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1 || { log_error "需要 $1 命令，但未找到。请安装后再试。"; exit 1; }
}

# 主函数
main() {
    # 检查依赖
    check_command docker-compose
    check_command cd
    
    # 统计信息
    total=0
    success=0
    failed=0
    skipped=0
    
    log_info "开始停止 Docker 服务..."
    
    # 遍历服务列表
    for service in "${services[@]}"; do
        # 解析服务名和启用状态
        read -r name enabled <<< "$service"
        total=$((total + 1))
        
        # 检查是否启用
        if [ "$enabled" != "yes" ]; then
            log_warn "跳过服务: $name (已禁用)"
            skipped=$((skipped + 1))
            continue
        fi
        
        # 服务目录
        service_dir="$BASE_DIR/$name"
        
        # 检查目录是否存在
        if [ ! -d "$service_dir" ]; then
            log_error "服务目录不存在: $service_dir"
            failed=$((failed + 1))
            continue
        fi
        
        # 进入目录
        log_info "处理服务: $name"
        cd "$service_dir" || { log_error "无法进入目录: $service_dir"; failed=$((failed + 1)); continue; }
        
        # 停止服务
        log_info "执行: docker-compose down"
        if docker-compose down; then
            log_info "服务 $name 已成功停止"
            success=$((success + 1))
        else
            log_error "停止服务 $name 失败"
            failed=$((failed + 1))
        fi
        
        # 返回原目录
        cd - >/dev/null 2>&1
        echo
    done
    
    # 输出统计结果
    echo "----------------------------------------"
    log_info "操作完成!"
    log_info "总计: $total 个服务"
    log_info "成功: $success"
    log_info "失败: $failed"
    log_info "跳过: $skipped"
    echo "----------------------------------------"
    
    # 检查是否有失败
    if [ $failed -gt 0 ]; then
        log_error "有 $failed 个服务停止失败，请检查日志。"
        exit 1
    else
        log_info "所有服务均已成功停止!"
        exit 0
    fi
}

# 执行主函数
main