#!/bin/bash
# 批量加载Docker镜像脚本
# 功能：遍历当前目录下的所有.tar和.tar.gz文件，并使用docker load命令加载

# ================== 欢迎语 ==================
echo -e "\033[1;35m"
cat <<'WELCOME'
 ____             _         ____                                  _
|  _ \  __ _ _ __| | __    / ___|  ___ _ __ __ _ _ __   ___ _ __ | |_
| | | |/ _` | '__| |/ /____\___ \ / __| '__/ _` | '_ \ / _ \ '_ \| __|
| |_| | (_| | |  |   <_____|__) | (__| | | (_| | |_) |  __/ | | | |_
|____/ \__,_|_|  |_|\_\   |____/ \___|_|  \__,_| .__/ \___|_| |_|\__|
                                               |_|
           批量加载 Docker 镜像 · 仅当前目录
WELCOME
echo -e "\033[0m"
echo "--------------------------------------------"
# ============================================

# ---------- 颜色变量 ----------
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[36m'
RESET='\033[0m'

# 检查Docker是否已安装并运行
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未找到docker命令，请先安装Docker${RESET}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker服务未运行，请启动Docker服务${RESET}"
    exit 1
fi

IMAGE_DIR="."
echo -e "${BLUE}正在处理当前目录: $(realpath "$IMAGE_DIR")${RESET}"

total_files=0
loaded_success=0
loaded_failed=0

# 仅查找当前目录下的.tar和.tar.gz文件（忽略子目录）
echo -e "${YELLOW}正在查找Docker镜像文件...${RESET}"
IMAGE_FILES=$(find "$IMAGE_DIR" -maxdepth 1 -type f \( -name "*.tar" -o -name "*.tar.gz" \))

if [ -z "$IMAGE_FILES" ]; then
    echo -e "${YELLOW}未找到任何Docker镜像文件（.tar或.tar.gz）${RESET}"
    exit 0
fi

total_files=$(echo "$IMAGE_FILES" | wc -l)
echo -e "${BLUE}找到 $total_files 个Docker镜像文件${RESET}"
echo "--------------------------------------------"

# 遍历并加载每个文件
while IFS= read -r file; do
    echo -e "${YELLOW}正在处理: $file${RESET}"

    load_output=$(docker load -i "$file" 2>&1)
    load_status=$?

    if [ $load_status -eq 0 ]; then
        echo -e "${GREEN}✅ 加载成功${RESET}"

        image_info=$(echo "$load_output" | grep "Loaded image" | sed 's/^.*: //')
        if [ -n "$image_info" ]; then
            echo -e "${GREEN}   镜像信息: $image_info${RESET}"
            echo -e "${GREEN}   镜像摘要:${RESET}"
            # 仅取一行，完整匹配 REPOSITORY:TAG
            docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}" \
            | grep -F "$image_info" | head -n1
        fi
        loaded_success=$((loaded_success + 1))
    else
        echo -e "${RED}❌ 加载失败: $load_output${RESET}"
        loaded_failed=$((loaded_failed + 1))
    fi
    echo "--------------------------------------------"
done <<< "$IMAGE_FILES"

# ---------- 结果汇总（保持原格式） ----------
echo -e "${YELLOW}加载完成统计：${RESET}"
echo "总计: $total_files 个文件"
echo "成功: $loaded_success 个文件"
echo "失败: $loaded_failed 个文件"
echo "--------------------------------------------"

if [ $loaded_failed -gt 0 ]; then
    exit 1
else
    exit 0
fi