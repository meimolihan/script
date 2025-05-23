#!/bin/bash
echo "开始清理Kali Linux系统..."

# 更新软件包列表
sudo apt update

# 清理缓存和残留依赖
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove --purge -y

# 清理日志和临时文件
sudo rm -rf /var/log/*.log
sudo rm -rf /var/log/*/*.gz
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# 清理缩略图和Firefox缓存
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.cache/mozilla/firefox/*.default-release/Cache/*

echo "系统清理完成！"

