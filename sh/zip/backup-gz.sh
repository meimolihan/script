#!/bin/bash
# =================================================================================================
# 脚本名称：backup.sh
# 作    用：提供一个交互式菜单，用于选择备份路径并备份当前目录下的所有子目录到指定路径。
# 功能描述：
#   1. 显示备份路径选项菜单，包括预定义路径和自定义路径选项。
#   2. 根据用户选择，创建备份目录（如果不存在）。
#   3. 遍历当前目录下的所有子目录，将每个子目录压缩成单独的 tar.gz 文件并保存到备份目录。
#   4. 提供详细的错误处理和用户反馈。
# 使用方法：
#   1. 将脚本保存为 backup-gz.sh。
#   2. 赋予执行权限：chmod +x backup-gz.sh。
#   3. 运行脚本：./backup-gz.sh。
#   4. 按照提示选择备份路径或输入自定义路径。
# 注意事项：
#   - 确保运行脚本的用户对备份目录有写权限。
#   - 当前目录下的隐藏文件夹（以 . 开头）不会被备份。
#   - 备份文件名格式：文件夹名字-yyyy-mm-dd.tar.gz
# =================================================================================================
echo ==============================================
echo 作    用：提供一个交互式菜单，用于选择备份路径并备份当前目录下的所有子目录到指定路径。
echo 当前目录下的隐藏文件夹（以 . 开头）不会被备份。
echo 备份文件名格式：文件夹名字-yyyy-mm-dd.tar.gz
echo ==============================================

# 设置预定义的备份路径选项
options=(
    "/mnt/backup"
    "/vol1/1000/backup"
    "/vol2/1000/backup"
    "自定义路径"
)

# 显示选项菜单
while true; do
    clear
    echo "请选择备份路径："
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[$i]}"
    done
    echo "0. 退出程序"

    # 获取用户选择
    read -p "请输入选项数字 (0-4): " choice

    # 验证输入
    if [[ ! "$choice" =~ ^[0-4]$ ]]; then
        echo -e "\033[31m错误：无效选择，请输入0-4的数字！\033[0m"
        read -p "按任意键继续..."
        continue
    fi

    # 处理退出选项
    if [[ $choice -eq 0 ]]; then
        echo -e "\033[32m已退出备份程序。\033[0m"
        exit 0
    fi

    # 处理用户选择
    if [[ $choice -eq 4 ]]; then
        while true; do
            read -p "请输入自定义备份路径: " backup_dir
            # 验证自定义路径是否为空
            if [[ -z "$backup_dir" ]]; then
                echo -e "\033[31m错误：备份路径不能为空！\033[0m"
                continue
            fi
            break
        done
    else
        backup_dir="${options[$((choice-1))]}"
    fi

    # 验证备份路径是否有效
    if [[ ! -w "$(dirname "$backup_dir")" ]]; then
        echo -e "\033[31m错误：没有写权限到 ${backup_dir} 的父目录！\033[0m"
        read -p "按任意键继续..."
        continue
    fi

    # 创建备份目录（如果不存在）
    if [[ ! -d "$backup_dir" ]]; then
        echo -e "\033[33m正在创建备份目录 ${backup_dir}...\033[0m"
        mkdir -p "$backup_dir" || {
            echo -e "\033[31m错误：无法创建目录 $backup_dir，请检查权限！\033[0m"
            exit 1
        }
        echo -e "\033[32m成功创建目录 ${backup_dir}\033[0m"
    else
        echo -e "\033[32m备份目录 ${backup_dir} 已存在，将直接使用\033[0m"
    fi

    # 验证备份目录是否可写
    if [[ ! -w "$backup_dir" ]]; then
        echo -e "\033[31m错误：没有写权限到备份目录 ${backup_dir}！\033[0m"
        read -p "按任意键继续..."
        continue
    fi

    # 遍历当前目录下的所有子目录并压缩
    echo -e "\033[33m开始备份当前目录下的所有子目录...\033[0m"
    current_date=$(date +'%Y-%m-%d')  # 获取当前日期
    for d in */; do
        dir_name="${d%/}"
        echo -e "\033[33m正在备份 ${dir_name}...\033[0m"
        # 使用当前日期作为备份文件名的一部分
        tar -czvf "${backup_dir}/${dir_name}-${current_date}.tar.gz" "$dir_name" 2>/dev/null || {
            echo -e "\033[31m错误：无法备份 ${dir_name}！\033[0m"
            continue
        }
        echo -e "\033[32m成功备份 ${dir_name} 到 ${backup_dir}/${dir_name}-${current_date}.tar.gz\033[0m"
    done

    echo -e "\033[32m已完成！所有文件夹已压缩到 \033[33m${backup_dir}\033[32m 目录。\033[0m"
    read -p "按任意键退出..."
    exit 0
done