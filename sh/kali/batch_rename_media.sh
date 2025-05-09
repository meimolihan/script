#!/bin/bash

# 递归遍历目录中的所有文件
find . -type f | while IFS= read -r file; do
    # 获取文件路径和扩展名
    filepath=$(dirname "$file")
    filename=$(basename "$file")
    ext="${filename##*.}"
    
    # 根据文件类型执行不同的重命名规则
    case "$ext" in
        mp3)
            target="song.mp3"
            ;;
        jpg)
            target="cover.jpg"
            ;;
        lrc)
            target="lyric.lrc"
            ;;
        *)
            # 不是目标类型的文件，跳过
            continue
            ;;
    esac
    
    # 检查是否已为目标文件名
    if [ "$filename" = "$target" ]; then
        continue
    fi
    
    # 构建目标文件路径
    target_path="$filepath/$target"
    
    # 检查目标文件是否存在
    if [ ! -e "$target_path" ]; then
        # 移动并重命名文件
        mv -n "$file" "$target_path" 2>/dev/null || {
            echo "警告：无法重命名 '$file' 为 '$target'" >&2
        }
    else
        echo "子目录 $filepath 中存在同名的 $target 文件，无法将 $file 重命名为 $target"
    fi
done

echo "文件重命名操作已完成，如有同名文件导致部分重命名未成功，请查看提示信息。"    