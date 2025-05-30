## 远程使用方法

## Debian 安装 `FFmpeg`

```bash
sudo apt update && \
sudo apt install ffmpeg -y && \
ffmpeg -version | grep "ffmpeg version"
```

## 图片格式转换

### convert_to_webp.sh

- 遍历目录下的图片文件（`jpg,jpeg,png,gif,bmp,tiff,tif`），用 `FFmpeg` 转换为 `webp` 图片格式，保存在当前目录下（`压缩比60%`）

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ffmpeg/convert_to_webp.sh)
```

![](https://file.meimolihan.eu.org/screenshot/convert_to_webp.webp)

### image_converter.sh

- 遍历目录下的图片文件（`jpg,jpeg,png,gif,bmp,tiff,tif,webp`）用 `FFmpeg` 转换为 `webp，jpg，png` 图片格式，保存在当前目录下（`压缩比60%`）

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ffmpeg/image_converter.sh)
```

![](https://file.meimolihan.eu.org/screenshot/image_converter.webp)

## 视频格式转换

遍历目录下的图片文件（`ts,mkv,mov,avi,flv,mpg,rmvb,wmv`）用 `FFmpeg` 转换为 `mp4` 视频格式

```bash
bash <(curl -sL gitee.com/meimolihan/script/raw/master/sh/ffmpeg/video_to_mp4.sh)
```

![](https://file.meimolihan.eu.org/screenshot/video_to_mp4.webp)
