#!/bin/bash

# 批量加载Docker镜像脚本
# 功能：遍历当前目录下的所有.tar和.tar.gz文件，并使用docker load命令加载

# 检查Docker是否已安装并运行
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到docker命令，请先安装Docker"
    exit 1
fi

# 检查Docker服务是否运行
if ! docker info &> /dev/null; then
    echo "错误: Docker服务未运行，请启动Docker服务"
    exit 1
fi

# 设置当前目录为镜像目录
IMAGE_DIR="."
echo "正在处理当前目录: $(realpath "$IMAGE_DIR")"

# 统计变量
total_files=0
loaded_success=0
loaded_failed=0

# 查找所有.tar和.tar.gz文件
echo "正在查找Docker镜像文件..."
IMAGE_FILES=$(find "$IMAGE_DIR" -type f \( -name "*.tar" -o -name "*.tar.gz" \))

# 检查是否找到文件
if [ -z "$IMAGE_FILES" ]; then
    echo "未找到任何Docker镜像文件（.tar或.tar.gz）"
    exit 0
fi

# 统计文件数量
total_files=$(echo "$IMAGE_FILES" | wc -l)
echo "找到 $total_files 个Docker镜像文件"
echo "--------------------------------------------"

# 遍历并加载每个文件
echo "$IMAGE_FILES" | while IFS= read -r file; do
    echo "正在处理: $file"
    
    # 执行docker load命令并捕获输出
    load_output=$(docker load -i "$file" 2>&1)
    load_status=$?
    
    # 显示加载结果
    if [ $load_status -eq 0 ]; then
        echo "✅ 加载成功"
        
        # 提取镜像名称和标签
        image_info=$(echo "$load_output" | grep "Loaded image" | sed 's/^.*: //')
        if [ -n "$image_info" ]; then
            echo "   镜像信息: $image_info"
            
            # 显示镜像详细信息
            echo "   镜像摘要:"
            docker images | grep "$image_info"
        fi
        
        loaded_success=$((loaded_success + 1))
    else
        echo "❌ 加载失败: $load_output"
        loaded_failed=$((loaded_failed + 1))
    fi
    
    echo "--------------------------------------------"
done

# 等待循环完成后显示统计信息
echo "加载完成!"
echo "总计: $total_files 个文件"
echo "成功: $loaded_success 个文件"
echo "失败: $loaded_failed 个文件"

# 设置退出状态码
if [ $loaded_failed -gt 0 ]; then
    exit 1
else
    exit 0
fi
