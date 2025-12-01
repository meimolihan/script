#!/bin/bash

gl_huang='\033[33m'
gl_bai='\033[0m'

read -r -e -p "$(echo -e "${gl_bai}请输入要使用的名称 (例如 ${gl_hong}xunlei${gl_bai): ")"  name

# 拷贝【说明页面】模板
sudo cp -r /etc/nginx/html/help/test-xxx_help /etc/nginx/html/help/${name}_help

# 修改【说明页面】html
sudo sed -i "s/test-xxx/${name}/g" "/etc/nginx/html/help/${name}_help/index.html"

# 拷贝【错误页面】模板
sudo cp -r /etc/nginx/html/error/test-xxx_error "/etc/nginx/html/error/${name}_error"

# 修改【错误页面】html
sudo sed -i "s/test-xxx/${name}/g" "/etc/nginx/html/error/${name}_error/index.html"