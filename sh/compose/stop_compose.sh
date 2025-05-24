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
echo "        正在停止并删除所有Docker容器         "
echo "=============================================="

# 停止所有运行中的容器
echo "---------- 停止所有运行中的容器 ----------"
containers=$(docker ps -q)

if [ -z "$containers" ]; then
    echo "没有正在运行的容器需要停止"
else
    while IFS= read -r container_id; do
        container_name=$(docker inspect --format='{{.Name}}' "$container_id" | sed 's|^/||')
        echo -n "停止容器: $container_name ($container_id) ... "
        docker stop "$container_id" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "成功"
        else
            echo "失败"
        fi
    done <<< "$containers"
fi

echo "--------------------------------------------"

# 删除所有容器
echo "---------- 删除所有容器 ----------"
containers=$(docker ps -aq)

if [ -z "$containers" ]; then
    echo "没有容器需要删除"
else
    while IFS= read -r container_id; do
        container_name=$(docker inspect --format='{{.Name}}' "$container_id" | sed 's|^/||')
        echo -n "删除容器: $container_name ($container_id) ... "
        docker rm "$container_id" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "成功"
        else
            echo "失败"
        fi
    done <<< "$containers"
fi

echo "--------------------------------------------"
echo "=============================================="
echo "                 操作完成！                  "
echo "=============================================="
