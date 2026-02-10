#!/bin/bash
# 统计指定目录的文件、目录数量（含隐藏项）及总大小（MB和GB）

# 颜色变量定义
gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_zi='\033[35m'
gl_bufan='\033[96m'
gl_bai='\033[0m'

# 日志函数
log_info()  { echo -e "${gl_lan}[信息]${gl_bai} $*"; }
log_ok()    { echo -e "${gl_lv}[成功]${gl_bai} $*"; }
log_warn()  { echo -e "${gl_huang}[警告]${gl_bai} $*"; }
log_error() { echo -e "${gl_hong}[错误]${gl_bai} $*" >&2; }

# 检查命令是否可用
check_command() {
    command -v "$1" >/dev/null 2>&1 || { 
        log_error "需要安装 '$1' 包"
        exit 1
    }
}

# 检查命令依赖
check_command find
check_command du
check_command awk
check_command bc

# 定义需要统计的目录列表（格式：中文名称|目录路径）
directories=(
    "未处理壁纸目录|/vol1/1000/compose/random-pic-api/photos"
    "已处理手机壁纸目录|/vol1/1000/compose/random-pic-api/portrait"
    "手机壁纸原图目录|/vol2/1000/阿里云盘/教程文件/壁纸原图/手机原图"
    "已处理电脑壁纸目录|/vol1/1000/compose/random-pic-api/landscape"
    "电脑壁纸原图目录|/vol2/1000/阿里云盘/教程文件/壁纸原图/电脑原图"
)

# 主函数
main() {
    for item in "${directories[@]}"; do
        # 分割中文名称和目录路径
        IFS='|' read -r name path <<< "$item"
        
        echo -e ""
        echo -e "${gl_huang}>>>【${gl_lv}${name}${gl_huang}】统计结果"
        echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
        log_info "正在统计目录: ${gl_huang}${path}${gl_bai}"
        
        # 检查目录是否存在
        if [[ ! -d "$path" ]]; then
            log_warn "目录不存在: ${gl_huang}${path}${gl_bai}"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            continue
        fi
        
        # 检查目录是否可读
        if [[ ! -r "$path" ]]; then
            log_warn "目录不可读: ${gl_huang}${path}${gl_bai}"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            continue
        fi
        
        # 统计文件数量（含隐藏文件）
        file_count=$(find "$path" -maxdepth 1 -type f -not -path '*/\.*' 2>/dev/null | wc -l)
        hidden_file_count=$(find "$path" -maxdepth 1 -type f -name '.*' 2>/dev/null | wc -l)
        total_files=$((file_count + hidden_file_count))
        
        # 统计目录数量（含隐藏目录，排除当前目录）
        dir_count=$(find "$path" -maxdepth 1 -type d -not -path "$path" -not -path '*/\.*' 2>/dev/null | wc -l)
        hidden_dir_count=$(find "$path" -maxdepth 1 -type d -name '.*' -not -path "$path" 2>/dev/null | wc -l)
        total_dirs=$((dir_count + hidden_dir_count))
        
        # 统计总大小（排除当前目录自身占用）
        total_size_mb=$(du -sm "$path"/.* "$path"/* 2>/dev/null | awk '{sum += $1} END {print sum}')
        total_size_gb=$(echo "scale=2; $total_size_mb / 1024" | bc 2>/dev/null)
        
        # 检查计算是否成功
        if [[ -z "$total_size_mb" ]] || [[ -z "$total_size_gb" ]]; then
            log_warn "无法计算目录大小: ${gl_huang}${path}${gl_bai}"
            echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
            continue
        fi
        
        # 输出结果
        log_info "当前目录下的项目统计："
        log_info "  - 文件总数: ${gl_lv}${total_files}${gl_bai}"
        log_info "    • 普通文件: ${gl_huang}${file_count}${gl_bai}"
        log_info "    • 隐藏文件: ${gl_huang}${hidden_file_count}${gl_bai}"
        log_info "  - 目录总数: ${gl_lv}${total_dirs}${gl_bai}"
        log_info "    • 普通目录: ${gl_huang}${dir_count}${gl_bai}"
        log_info "    • 隐藏目录: ${gl_huang}${hidden_dir_count}${gl_bai}"
        log_info "  - 总项目数: ${gl_lv}$((total_files + total_dirs))${gl_bai}"
        log_info "文件总大小为: ${gl_lv}${total_size_mb} MB${gl_bai} (${gl_lv}${total_size_gb} GB${gl_bai})"
    done
    
    echo -e ""
    echo -e "${gl_bufan}————————————————————————————————————————————————${gl_bai}"
    log_ok "所有目录统计完成${gl_hong}.${gl_huang}.${gl_lv}.${gl_bai}"
}

# 执行主函数
main "$@"