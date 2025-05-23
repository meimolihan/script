#!/bin/bash

# 编写脚本测试 10.10.10.0/24 整个网段中哪些主机处于开机状态,哪些主机处于关机状态

for i in {1..254}
do 
 # 每隔0.3秒ping一次，一共ping2次，并以1毫秒为单位设置ping的超时时间
 ping -c 2 -i 0.3 -W 1 10.10.10.$i &>/dev/null
     if [ $? -eq 0 ];then
 echo "10.10.10.$i 开机"
 else 
 echo "10.10.10.$i 关机"
 fi
done
 
