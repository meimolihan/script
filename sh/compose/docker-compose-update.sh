#!/bin/bash

# 欢迎语 & 脚本说明
echo "======================================"
echo "       Docker Compose 批量更新工具       "
echo " 功能：遍历子目录执行容器停止、拉取、重启、清理"
echo "======================================"
echo ""


# 遍历当前目录下的所有子目录
for dir in */; do
    # 跳过非目录项或隐藏目录（以.开头）
    if [ ! -d "$dir" ] || [[ "$dir" =~ ^\. ]]; then
        continue
    fi
    
    echo "------------------------------"
    echo "开始处理目录：$(basename "$dir")"
    echo "------------------------------"
    
    cd "$dir" || {
        echo "❌ 进入目录失败：$dir"
        echo ""
        continue
    }
    
    # 检查 docker-compose.yml 是否存在
    if [ ! -f "docker-compose.yml" ]; then
        echo "❌ 缺少 docker-compose.yml：$dir"
        cd ..
        echo ""
        continue
    fi
    
    # 执行命令
    echo "▶ 停止容器：docker-compose down"
    docker-compose down
    
    echo "▶ 拉取最新镜像：docker-compose pull"
    docker-compose pull
    
    echo "▶ 重启容器：docker-compose up -d"
    docker-compose up -d
    
    echo "▶ 清理无用镜像：docker image prune -f"
    docker-image-prune -f || echo "⚠ 清理镜像时出错（可能无冗余镜像）"
    
    cd ..
    echo ""
done

echo "======================================"
echo "所有目录处理完成 ✅"
echo "------------------------------"
