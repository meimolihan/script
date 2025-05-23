#!/bin/bash

# 设置终端文本颜色为绿色
tput setaf 2

echo "========================================"
echo "               Git 克隆仓库"
echo "========================================"

# 重置文本颜色
tput sgr0

# 读取用户输入的仓库URL
read -p "请输入Git仓库的URL或git clone命令: " repoUrl

# 检查输入是否为空
if [ -z "$repoUrl" ]; then
    tput setaf 1
    echo
    echo "========================================"
    echo "未输入有效的URL，请重新运行脚本并输入正确的URL。"
    echo "========================================"
    tput sgr0
    read -p "按任意键继续..."
    exit 1
fi

# 清理输入，移除"git clone"前缀
cleanUrl="${repoUrl#git clone }"
cleanUrl="${cleanUrl#git clone}"
cleanUrl="${cleanUrl# }"  # 移除可能的前导空格

# 提取仓库名称
repoName="${cleanUrl%/}"  # 移除末尾斜杠
repoName="${repoName##*/}"  # 提取最后一个斜杠后的部分
repoName="${repoName%.git}"  # 移除.git后缀

tput setaf 2
echo "========================================"
echo
echo "========================================"
echo "正在克隆仓库 \"$repoName\"，请稍候..."
echo "========================================"
echo
echo "========================================"
tput sgr0

# 执行克隆命令
git clone "$cleanUrl"

# 检查克隆结果
if [ $? -ne 0 ]; then
    tput setaf 1
    echo
    echo "========================================"
    echo "仓库 \"$repoName\"，克隆失败，请检查URL是否正确或网络连接。"
    echo "========================================"
else
    tput setaf 2
    echo
    echo "========================================"
    echo "仓库 \"$repoName\"，克隆成功！"
    echo "========================================"
fi
tput sgr0

echo "感谢使用，再见！"
sleep 5
exit 0