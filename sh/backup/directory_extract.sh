#!/bin/bash
# =================================================================================================
# 脚本名称：safe_extract.sh
# 作    用：安全解压当前目录下的所有压缩包到指定目录（完全免交互版本）
# 使用方法：
#   1. 将脚本保存为 safe_extract.sh
#   2. 赋予执行权限：chmod +x safe_extract.sh
#   3. 运行脚本：./safe_extract.sh /path/to/extract/directory
# 注意：此版本为完全免交互版本，不会询问任何问题，不会删除原始文件
# =================================================================================================

echo "=================================="
echo "         安全压缩包解压工具"
echo "        (完全免交互版本)"
echo "=================================="
echo "功能描述："
echo "  1. 安全解压当前目录下的所有压缩包到指定目录"
echo "  2. 支持多种压缩格式：tar.gz, tgz, tar, zip"
echo "  3. 自动创建目标目录（如不存在）"
echo "  4. 不会删除原始压缩包"
echo "  5. 完全免交互，无需任何确认"
echo "=================================="
echo

# 检查是否提供了目标目录参数
if [ $# -lt 1 ]; then
    echo "错误：必须指定解压目标目录路径作为参数"
    echo "使用方法: $0 /path/to/extract/directory"
    exit 1
fi

# 设置当前目录和提取目录
current_dir=$(pwd)
extract_dir="$1"
echo "当前目录: $current_dir"
echo "解压目录: $extract_dir"
echo

# 移除路径末尾可能存在的斜杠
extract_dir="${extract_dir%/}"

# 检查解压目录是否与当前目录相同
if [ "$current_dir" = "$extract_dir" ]; then
    echo "警告：解压目录与当前目录相同，这可能导致文件覆盖问题！"
fi

# 验证是否有写入解压目录父目录的权限
if [ ! -w "$(dirname "$extract_dir")" ]; then
    echo "错误：没有写权限到 '$extract_dir' 的父目录！"
    exit 1
fi

# 创建解压目录（如果不存在）
if [ ! -d "$extract_dir" ]; then
    echo "正在创建解压目录 '$extract_dir'..."
    mkdir -p "$extract_dir"
    if [ $? -ne 0 ]; then
        echo "错误：无法创建目录 '$extract_dir'，请检查权限！"
        exit 1
    fi
    echo "√ 成功创建解压目录 '$extract_dir'"
else
    echo "√ 解压目录 '$extract_dir' 已存在"
fi

# 验证解压目录是否可写
if [ ! -w "$extract_dir" ]; then
    echo "错误：没有写权限到解压目录 '$extract_dir'！"
    exit 1
fi

echo "√ 解压目录验证通过"
echo
echo "开始扫描当前目录下的压缩文件..."
echo

# 初始化计数器
total_files=0
success_count=0
fail_count=0

# 查找所有支持的压缩文件
for file in "$current_dir"/*.tar.gz "$current_dir"/*.tgz "$current_dir"/*.tar "$current_dir"/*.zip; do
    # 跳过不存在的文件（通配符扩展）
    [ -e "$file" ] || continue
    
    total_files=$((total_files + 1))
    filename=$(basename "$file")
    echo "正在解压: $filename"
    
    # 根据文件扩展名选择解压命令
    case "$filename" in
        *.tar.gz|*.tgz)
            if tar -xzf "$file" -C "$extract_dir" 2>/dev/null; then
                echo "√ 成功解压: $filename"
                success_count=$((success_count + 1))
            else
                echo "× 解压失败: $filename"
                fail_count=$((fail_count + 1))
            fi
            ;;
        *.tar)
            if tar -xf "$file" -C "$extract_dir" 2>/dev/null; then
                echo "√ 成功解压: $filename"
                success_count=$((success_count + 1))
            else
                echo "× 解压失败: $filename"
                fail_count=$((fail_count + 1))
            fi
            ;;
        *.zip)
            if unzip -q "$file" -d "$extract_dir" 2>/dev/null; then
                echo "√ 成功解压: $filename"
                success_count=$((success_count + 1))
            else
                echo "× 解压失败: $filename"
                fail_count=$((fail_count + 1))
            fi
            ;;
        *)
            # 不应该到达这里，因为通配符已经过滤了
            echo "× 不支持的文件格式: $filename"
            fail_count=$((fail_count + 1))
            ;;
    esac
    
    echo
done

# 显示解压结果摘要
echo "=================================="
echo "          解压完成摘要"
echo "=================================="
echo "当前目录: $current_dir"
echo "解压目录: $extract_dir"
echo "找到文件: $total_files 个压缩包"
echo "成功解压: $success_count 个文件"
echo "解压失败: $fail_count 个文件"
echo "=================================="

if [ $total_files -eq 0 ]; then
    echo "未找到任何支持的压缩文件！"
    echo "支持的格式: tar.gz, tgz, tar, zip"
elif [ $fail_count -eq 0 ] && [ $success_count -gt 0 ]; then
    echo "所有压缩包解压完成！原始压缩包保持不变。"
    echo "解压文件已保存到: $extract_dir"
elif [ $success_count -eq 0 ]; then
    echo "所有压缩包解压失败！原始压缩包保持不变。"
else
    echo "解压完成，但有 $fail_count 个文件解压失败！原始压缩包保持不变。"
fi

exit 0