#!/bin/bash
# 根据计算机当前时间，返回问候语，可以将该脚本设置为开机启动
# 00-12 点为早晨，12-18 点为下午，18-24 点为晚上
# 使用 date 命令获取时间后，if 判断时间的区间，确定问候语内容
tm=$(date +%H)
if [ $tm -le 12 ];then
    msg="早上好，$USER"
elif [ $tm -gt 12 -a $tm -le 18 ];then
    msg="下午好，$USER"
else
    msg="晚上好，$USER"
fi
echo "当前时间是：$(date +"%Y年%m月%d日 %H时%M分%S秒")"
echo -e "\033[34m$msg\033[0m"
 