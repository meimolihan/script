@echo off
setlocal enabledelayedexpansion

REM 设置颜色为绿色背景，默认亮白色文字
COLOR 0A
CLS
PROMPT $P$G
:menu
color 0A
cls
echo ==============================
echo         图片处理工具
echo ==============================
echo * 1. 图片尺寸处理
echo.
echo * 2. 图片格式处理
echo ==============================
echo * 0. 退出
echo ==============================
set /p choice="请输入操作编号 (0 - 2): "

if "%choice%"=="1" goto img_aaa_menu
if "%choice%"=="2" goto img_bbb_menu
if "%choice%"=="0" goto exit_script

echo 无效选项，请重新选择...
pause
goto MENU
	

rem ==========================  一 、图片尺寸处理  ===========================
:img_aaa_menu
	rem 清屏，显示 Git 命令子菜单
	cls

echo ==============================
echo         图片尺寸处理
echo ==============================
echo * 1. 生成150x150缩略图(JPG) 
echo * 2. 生成320x320中等尺寸(JPG)
echo * 3. 生成640x640中等尺寸(JPG)
echo * 4. 生成1920x1080高清尺寸(JPG)
echo ==============================
echo * 5. 生成150x150缩略图(PNG) 
echo * 6. 生成320x320中等尺寸(PNG)
echo * 7. 生成150x150缩略图(PNG) 
echo * 8. 生成320x320中等尺寸(PNG)
echo ==============================
echo * 9. 返回主菜单
echo * 0. 退出
echo ==============================
set /p choice="请输入操作编号 (0 - 9): "

if "%choice%"=="1" set "cfg=150x150|150:150|150:150|*.jpg *.png *.bmp *.tga *.jpeg *.webp" && set "outputFmt=jpg" && goto VALID
if "%choice%"=="2" set "cfg=320x320|320:320|320:320|*.jpg *.png *.bmp *.tga *.jpeg *.webp *.jfif" && set "outputFmt=jpg" && goto VALID
if "%choice%"=="3" set "cfg=640x640|640:640|640:640|*.jpg *.png *.bmp *.tga *.jpeg *.webp *.jfif" && set "outputFmt=jpg" && goto VALID
if "%choice%"=="4" set "cfg=1920x1080|1920:1180|1920:1180|*.jpg *.png *.bmp *.tga *.jpeg *.webp *.jfif" && set "outputFmt=jpg" && goto VALID
if "%choice%"=="5" set "cfg=150x150|150:150|150:150|*.jpg *.png *.bmp *.tga *.jpeg *.webp" && set "outputFmt=png" && goto VALID
if "%choice%"=="6" set "cfg=320x320|320:320|320:320|*.jpg *.png *.bmp *.tga *.jpeg *.webp *.jfif" && set "outputFmt=png" && goto VALID
if "%choice%"=="7" set "cfg=640x640|640:640|640:640|*.jpg *.png *.bmp *.tga *.jpeg *.webp *.jfif" && set "outputFmt=png" && goto VALID
if "%choice%"=="8" set "cfg=1920x1080|1920:1180|1920:1180|*.jpg *.png *.bmp *.tga *.jpeg *.webp *.jfif" && set "outputFmt=png" && goto VALID
if "%choice%"=="9" goto menu
if "%choice%"=="0" exit

echo 无效选项，请重新选择...
pause
goto img_aaa_menu

:VALID
for /f "tokens=1-4 delims=|" %%a in ("%cfg%") do (
    set "folder=%%a"
    set "scale=%%b"
    set "pad=%%c"
    set "ext=%%d"
)

:PROCESS
cls
echo 正在生成 [!folder!] 尺寸...
md "!folder!" 2>nul
set count=0

for %%i in (%ext%) do (
    set /a count+=1
    echo 正在处理 [!count!] %%i
    ffmpeg -hide_banner -loglevel error -y -i "%%i" ^
        -vf "scale=!scale!:force_original_aspect_ratio=decrease,pad=!pad!:(ow-iw)/2:(oh-ih)/2:color=black@0" ^
        -pix_fmt rgba "!folder!\%%~ni.!!outputFmt!!"
)

echo; & echo 处理完成！共转换 [!count!] 个文件
echo 输出目录：%cd%\!folder!
start "" "%cd%\!folder!"  REM 添加这一行来打开目录
echo 即将在 3 秒后返回 ...
powershell -Command "Start-Sleep -Seconds 3"
goto img_aaa_menu  REM 自动返回主菜单


rem ======================== 二 、图片格式处理 =============================
:img_bbb_menu
cls

echo ==============================
echo         图片格式处理
echo ==============================
echo * 1. 转换为 WebP 格式
echo * 2. 转换为 JPG 格式
echo * 3. 转换为 PNG 格式
echo ==============================
echo * 9. 返回主菜单
echo * 0. 退出
echo ==============================
set /p choice="请输入操作编号 (0 - 8): "
	
if "%choice%"=="1" goto webp
if "%choice%"=="2" goto jpg
if "%choice%"=="3" goto png
if "%choice%"=="9" goto menu
if "%choice%"=="0" goto exit_script

echo 无效选项，请重新选择...
pause
goto img_bbb_menu

:webp
echo.
echo 开始转换为 WebP 格式...
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.webp *.avif *.tiff *.gif *.psd *.raw) do (
    echo 正在转换文件: %%a
    ffmpeg -i "%%a" -c:v libwebp -lossless 0 -q:v 80 -y "%%~na.webp"
    if %errorlevel% neq 0 (
        echo 转换文件 %%a 时出错。
    ) else (
        echo 文件 %%a 转换成功。
    )
)
echo.
echo 所有文件转换完成。
goto img_bbb_menu

:jpg
echo.
echo 开始转换为 JPG 格式...
for %%a in (*.png *.bmp *.tga *.jpeg *.webp *.avif *.tiff *.gif *.psd *.raw) do (
    echo 正在转换文件: %%a
    ffmpeg -i "%%a" -c:v mjpeg -q:v 2 -y "%%~na.jpg"
    if %errorlevel% neq 0 (
        echo 转换文件 %%a 时出错。
    ) else (
        echo 文件 %%a 转换成功。
    )
)
echo.
echo 所有文件转换完成。
goto img_bbb_menu

:png
echo.
echo 开始转换为 PNG 格式...
for %%a in (*.jpg *.bmp *.tga *.jpeg *.webp *.avif *.tiff *.gif *.psd *.raw) do (
    echo 正在转换文件: %%a
    ffmpeg -i "%%a" -c:v png -y "%%~na.png"
    if %errorlevel% neq 0 (
        echo 转换文件 %%a 时出错。
    ) else (
        echo 文件 %%a 转换成功。
    )
)
echo.
goto img_bbb_menu





echo ========================================
:exit_script
cls
echo.
echo.
echo ========================================
echo         感谢使用，再见！
echo ========================================
timeout /t 2 >nul
exit