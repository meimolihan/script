#!/bin/bash

# 解压当前目录下所有的 .tar.gz 文件
for file in *.tar.gz; do
    if [ -f "$file" ]; then
        echo -e "\033[33m正在解压 $file...\033[0m"
        tar -xzvf "$file" || {
            echo -e "\033[31m错误：无法解压 $file！\033[0m"
            exit 1
        }
        echo -e "\033[32m成功解压 $file\033[0m"
    fi
done

# 提示用户是否删除 .tar.gz 文件
read -p "是否删除所有 .tar.gz 文件？(y/n): " choice

# 根据用户选择删除或保留 .tar.gz 文件
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "\033[33m正在删除所有 .tar.gz 文件...\033[0m"
    rm -f *.tar.gz || {
        echo -e "\033[31m错误：无法删除 .tar.gz 文件！\033[0m"
        exit 1
    }
    echo -e "\033[32m已删除所有 .tar.gz 文件。\033[0m"
else
    echo -e "\033[32m已保留所有 .tar.gz 文件。\033[0m"
fi

echo -e "\033[32m操作完成。\033[0m"
read -p "按任意键退出..."
exit 0