# 使用方法

## 创建配置文件脚本

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/nginx/create_nginx_conf.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/nginx/create_nginx_conf.sh)
```

- 相关路径

```bash
✓ 说明页面 - 路径和名称：/etc/nginx/html/help/aaaa_help
✓ 错误页面 - 路径和名称：/etc/nginx/html/error/aaaa_error
✓ 配置文件 - 路径和名称：/etc/nginx/conf.d/aaaa.conf
```



![](https://file.meimolihan.eu.org/screenshot/create_nginx_conf.webp) 

---



## 修改配置文件脚本

```bash
bash <(curl -sL script.meimolihan.eu.org/sh/nginx/your_script.sh)
```

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/nginx/your_script.sh)
```

---

## 脚本源码

```bash
#!/bin/bash
read -p "请输入要使用的名称（例如 xunlei）: " name

# 拷贝【说明页面】模板
sudo cp -r /etc/nginx/html/help/test-xxx_help /etc/nginx/html/help/${name}_help

# 修改【说明页面】html
sudo sed -i "s/test-xxx/${name}/g" "/etc/nginx/html/help/${name}_help/index.html"

# 拷贝【错误页面】模板
sudo cp -r /etc/nginx/html/error/test-xxx_error "/etc/nginx/html/error/${name}_error"

# 修改【错误页面】html
sudo sed -i "s/test-xxx/${name}/g" "/etc/nginx/html/error/${name}_error/index.html"
```

