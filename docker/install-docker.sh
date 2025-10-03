#!/usr/bin/env bash
# -------------------------------------------------------------
#  一键安装 Docker Engine + docker-compose（latest 直链版）
#  支持：fnOS、Debian、Ubuntu、Kali、CentOS、Rocky、Alma、Fedora、openEuler
# -------------------------------------------------------------
set -euo pipefail

RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

is_cn() { curl -s --max-time 2 ipinfo.io/country | grep -qi '^CN$'; }

# ------------------ Docker 安装 ------------------
install_docker() {
    if command -v docker &>/dev/null; then
        log_warn "Docker 已安装，跳过安装步骤"
        return
    fi
    log_info "正在安装 Docker ..."
    . /etc/os-release
    case "${ID,,}" in
        fedora)
            dnf install -y dnf-plugins-core
            if is_cn; then
                dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/fedora/docker-ce.repo
                dnf install -y docker-ce docker-ce-cli containerd.io
            else
                curl -fsSL https://get.docker.com | sh
            fi ;;
        centos|rhel|rocky|almalinux|openeuler)
            yum install -y yum-utils
            if is_cn; then
                yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
            else
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            fi
            yum install -y docker-ce docker-ce-cli containerd.io ;;
        debian|ubuntu|kali)
            apt-get update -y
            apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            ARCH=$(dpkg --print-architecture)
            REPO_URL=$(is_cn && echo "https://mirrors.aliyun.com/docker-ce/linux/${ID}" || echo "https://download.docker.com/linux/${ID}")
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL "${REPO_URL}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] ${REPO_URL} $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
            apt-get update -y
            apt-get install -y docker-ce docker-ce-cli containerd.io ;;
        *) is_cn && install_docker_ali || install_docker_official ;;
    esac
}

install_docker_ali() {
    cd ~ && curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh --mirror Aliyun
    rm -f get-docker.sh
}
install_docker_official() {
    curl -fsSL https://get.docker.com | sh
}

# ------------------ 镜像加速 ------------------
config_mirror() {
    local daemon=/etc/docker/daemon.json
    mkdir -p /etc/docker
    if is_cn; then
        cat > "$daemon" <<'EOF'
{
  "registry-mirrors": [
    "https://docker-0.unsee.tech",
    "https://docker.1panel.live",
    "https://registry.dockermirror.com",
    "https://docker.imgdb.de",
    "https://docker.m.daocloud.io",
    "https://hub.firefly.store",
    "https://hub.littlediary.cn",
    "https://hub.rat.dev",
    "https://dhub.kubesre.xyz",
    "https://cjie.eu.org",
    "https://docker.1panelproxy.com",
    "https://docker.hlmirror.com",
    "https://hub.fast360.xyz",
    "https://dockerpull.cn",
    "https://cr.laoyou.ip-ddns.com",
    "https://docker.melikeme.cn",
    "https://docker.kejilion.pro"
  ]
}
EOF
    else
        echo '{}' > "$daemon"
    fi
}

start_docker() {
    log_info "启动 Docker ..."
    systemctl daemon-reload
    systemctl enable --now docker
    systemctl restart docker
}

# ------------------ docker-compose 安装 ------------------
install_docker_compose() {
    command -v docker-compose &>/dev/null && { log_info "docker-compose 已存在，跳过"; return; }

    # 1. 目录判断
    local target_dir
    . /etc/os-release
    case "${ID,,}" in
        fnos)          target_dir="/usr/local/bin" ;;
        debian|ubuntu) target_dir="/usr/bin"      ;;
        *)             target_dir="/usr/local/bin" ;;
    esac

    # 2. 加速地址
    local base_url
    if is_cn; then
        base_url="https://hub.fast360.xyz/https://github.com/docker/compose/releases/latest/download"
    else
        base_url="https://github.com/docker/compose/releases/latest/download"
    fi

    # 3. 架构
    local bin_name="docker-compose-$(uname -s)-$(uname -m)"

    # 4. 下载安装
    log_info "下载 docker-compose -> ${target_dir}/docker-compose"
    curl -L --retry 2 "${base_url}/${bin_name}" -o "${target_dir}/docker-compose"
    chmod +x "${target_dir}/docker-compose"
    docker-compose --version && log_info "docker-compose 安装完成"
}

# ------------------ 主流程 ------------------
main() {
    [[ $EUID -eq 0 ]] || { log_error "请用 root 或 sudo 运行"; exit 1; }
    install_docker
    config_mirror
    start_docker
    install_docker_compose
    docker --version
    docker-compose --version
    log_info "全部安装完成！"
}

main "$@"