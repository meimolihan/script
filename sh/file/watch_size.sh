#!/usr/bin/env bash
DIR=${1:?用法: $0 <目录>}
while :; do
    printf '%(%F %T)T\t%.3f MB\n' -1 "$(du -sb "$DIR" | awk '{print $1/1024/1024}')"
    sleep 2        # 每 2 秒刷新一次，可改成 1 秒
done