#!/bin/bash

# 检查是否提供了目录参数，默认为当前目录
target_dir="${1:-.}"

# 检查目录是否存在
if [ ! -d "$target_dir" ]; then
    echo "错误：目录 '$target_dir' 不存在。"
    exit 1
fi

# 获取当前目录的绝对路径
current_dir=$(realpath "$target_dir")

echo "=============================================="
echo "   开始遍历目录 '$current_dir' 下的所有子目录   "
echo "=============================================="
echo "        正在构建并启动所有Docker容器         "
echo "=============================================="

# 保存当前工作目录
original_dir=$(pwd)
found_compose=0
started_services=0

# 遍历指定目录下的所有子目录
for dir in "$target_dir"/*; do
    if [ -d "$dir" ]; then
        echo "---------- 检查目录: $dir ----------"
        cd "$dir" || continue
        
        if [ -f "docker-compose.yml" ]; then
            found_compose=$((found_compose + 1))
            echo "在 $dir 中找到 docker-compose.yml，正在启动服务..."
            docker-compose up -d
            
            if [ $? -eq 0 ]; then
                started_services=$((started_services + 1))
                echo "✓ $dir 中的服务已成功启动"
                
                # 打印启动的容器名称
                echo "启动的容器:"
                containers=$(docker-compose ps -q)
                if [ -n "$containers" ]; then
                    while IFS= read -r container_id; do
                        if [ -n "$container_id" ]; then
                            container_name=$(docker inspect --format='{{.Name}}' "$container_id" | sed 's|^/||')
                            echo "  - $container_name"
                        fi
                    done <<< "$containers"
                else
                    echo "  (没有找到容器)"
                fi
            else
                echo "✗ 启动 $dir 中的服务时出错"
            fi
        else
            echo "在 $dir 中未找到 docker-compose.yml，跳过..."
        fi
        
        echo "--------------------------------------------"
        # 返回原始目录
        cd "$original_dir" || exit
    fi
done

echo "=============================================="
if [ $found_compose -eq 0 ]; then
    echo "   未找到任何docker-compose.yml文件   "
else
    echo "   遍历完成，找到 $found_compose 个服务，成功启动 $started_services 个服务   "
fi
echo "=============================================="
