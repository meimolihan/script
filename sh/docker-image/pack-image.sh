#!/usr/bin/env bash
set -euo pipefail

# ================== 欢迎语 ==================
echo -e "\033[1;35m"
cat <<'BANNER'
 ____             _         ____                  _          _
|  _ \ __ _ _ __ | | __    / ___|  ___ _ __ __ _ | |_ _  ___| |_
| | | / _` | '__| |/ /____\___ \ / __| '__/ _` || __| |/ __| __|
| |_| | (_| | |  |   <_____|__) | (__| | | (_| || |_| | (__| |_
|____/ \__,_|_|  |_|\_\   |____/ \___|_|  \__,_| \__|_|\___|\__|

            Docker 镜像打包小助手 ·  一键导出
BANNER
echo -e "\033[0m"
echo "--------------------------------------------"
# ============================================

# 颜色
RED='\033[31m'
GRN='\033[32m'
YEL='\033[33m'
NC='\033[0m'

# 1. 列出所有镜像
echo -e "${YEL}本地镜像列表：${NC}"
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}"

# 2. 循环输入镜像名:版本，直到正确
while true; do
    echo "--------------------------------------------"
    read -erp "请输入要打包的镜像名称和版本（格式  repository:tag ）： " IMG
    if docker image inspect "$IMG" &>/dev/null; then
        break
    else
        echo -e "${RED}镜像不存在，请重新输入！${NC}"
    fi
done

# 3. 循环选择格式
while true; do
    read -erp "选择打包格式  1) .tar   2) .tar.gz  （输入 1 或 2）： " FMT
    case "$FMT" in
        1) EXT="tar"; break ;;
        2) EXT="tar.gz"; break ;;
        *) echo -e "${RED}输入错误，请重新选择！${NC}" ;;
    esac
done

# 4. 循环输入文件名（不含扩展名）
while true; do
    read -erp "请输入打包文件名（不含扩展名）： " FNAME
    if [[ "$FNAME" =~ [^a-zA-Z0-9._-] ]]; then
        echo -e "${RED}文件名含非法字符，请重新输入！${NC}"
    else
        break
    fi
done

OUT="${FNAME}.${EXT}"

# 5. 打包
echo -e "${YEL}正在打包 → ${OUT}${NC}"
if [[ "$EXT" == "tar.gz" ]]; then
    docker save "$IMG" | gzip -c > "$OUT"
else
    docker save -o "$OUT" "$IMG"
fi

# 6. 静默校验 + 打印校验后的镜像名:版本
echo -e "${YEL}正在静默校验 …${NC}"
if [[ "$EXT" == "tar.gz" ]]; then
    gzip -t "$OUT" &&
    LOADED=$(gunzip -kc "$OUT" | docker load | awk '/Loaded image:/ {print $3}')
    echo -e "${GRN}校验通过：${OUT} 完整无损${NC}"
    echo -e "${GRN}检验后镜像名称与版本：${LOADED}${NC}"
else
    LOADED=$(docker load -i "$OUT" | awk '/Loaded image:/ {print $3}')
    echo -e "${GRN}校验通过：${OUT} 完整无损${NC}"
    echo -e "${GRN}检验后镜像名称与版本：${LOADED}${NC}"
fi

# 7. 提示加载命令
echo -e "${YEL}------------------------------------------------${NC}"
echo -e "${GRN}打包完成！如需加载镜像，请执行：${NC}"
echo -e "${GRN}docker load -i ${OUT}${NC}"
echo -e "${YEL}------------------------------------------------${NC}"
