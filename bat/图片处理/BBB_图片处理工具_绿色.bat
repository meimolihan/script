@echo off
setlocal enabledelayedexpansion

REM ������ɫΪ��ɫ������Ĭ������ɫ����
COLOR 0A
CLS
PROMPT $P$G
:menu
color 0A
cls
echo ==============================
echo         ͼƬ������
echo ==============================
echo * 1. ͼƬ�ߴ紦��
echo.
echo * 2. ͼƬ��ʽ����
echo ==============================
echo * 0. �˳�
echo ==============================
set /p choice="������������ (0 - 2): "

if "%choice%"=="1" goto img_aaa_menu
if "%choice%"=="2" goto img_bbb_menu
if "%choice%"=="0" goto exit_script

echo ��Чѡ�������ѡ��...
pause
goto MENU
	

rem ==========================  һ ��ͼƬ�ߴ紦��  ===========================
:img_aaa_menu
	rem ��������ʾ Git �����Ӳ˵�
	cls

echo ==============================
echo         ͼƬ�ߴ紦��
echo ==============================
echo * 1. ����150x150����ͼ(JPG) 
echo * 2. ����320x320�еȳߴ�(JPG)
echo * 3. ����640x640�еȳߴ�(JPG)
echo * 4. ����1920x1080����ߴ�(JPG)
echo ==============================
echo * 5. ����150x150����ͼ(PNG) 
echo * 6. ����320x320�еȳߴ�(PNG)
echo * 7. ����150x150����ͼ(PNG) 
echo * 8. ����320x320�еȳߴ�(PNG)
echo ==============================
echo * 9. �������˵�
echo * 0. �˳�
echo ==============================
set /p choice="������������ (0 - 9): "

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

echo ��Чѡ�������ѡ��...
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
echo �������� [!folder!] �ߴ�...
md "!folder!" 2>nul
set count=0

for %%i in (%ext%) do (
    set /a count+=1
    echo ���ڴ��� [!count!] %%i
    ffmpeg -hide_banner -loglevel error -y -i "%%i" ^
        -vf "scale=!scale!:force_original_aspect_ratio=decrease,pad=!pad!:(ow-iw)/2:(oh-ih)/2:color=black@0" ^
        -pix_fmt rgba "!folder!\%%~ni.!!outputFmt!!"
)

echo; & echo ������ɣ���ת�� [!count!] ���ļ�
echo ���Ŀ¼��%cd%\!folder!
start "" "%cd%\!folder!"  REM �����һ������Ŀ¼
echo ������ 3 ��󷵻� ...
powershell -Command "Start-Sleep -Seconds 3"
goto img_aaa_menu  REM �Զ��������˵�


rem ======================== �� ��ͼƬ��ʽ���� =============================
:img_bbb_menu
cls

echo ==============================
echo         ͼƬ��ʽ����
echo ==============================
echo * 1. ת��Ϊ WebP ��ʽ
echo * 2. ת��Ϊ JPG ��ʽ
echo * 3. ת��Ϊ PNG ��ʽ
echo ==============================
echo * 9. �������˵�
echo * 0. �˳�
echo ==============================
set /p choice="������������ (0 - 8): "
	
if "%choice%"=="1" goto webp
if "%choice%"=="2" goto jpg
if "%choice%"=="3" goto png
if "%choice%"=="9" goto menu
if "%choice%"=="0" goto exit_script

echo ��Чѡ�������ѡ��...
pause
goto img_bbb_menu

:webp
echo.
echo ��ʼת��Ϊ WebP ��ʽ...
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.webp *.avif *.tiff *.gif *.psd *.raw) do (
    echo ����ת���ļ�: %%a
    ffmpeg -i "%%a" -c:v libwebp -lossless 0 -q:v 80 -y "%%~na.webp"
    if %errorlevel% neq 0 (
        echo ת���ļ� %%a ʱ����
    ) else (
        echo �ļ� %%a ת���ɹ���
    )
)
echo.
echo �����ļ�ת����ɡ�
goto img_bbb_menu

:jpg
echo.
echo ��ʼת��Ϊ JPG ��ʽ...
for %%a in (*.png *.bmp *.tga *.jpeg *.webp *.avif *.tiff *.gif *.psd *.raw) do (
    echo ����ת���ļ�: %%a
    ffmpeg -i "%%a" -c:v mjpeg -q:v 2 -y "%%~na.jpg"
    if %errorlevel% neq 0 (
        echo ת���ļ� %%a ʱ����
    ) else (
        echo �ļ� %%a ת���ɹ���
    )
)
echo.
echo �����ļ�ת����ɡ�
goto img_bbb_menu

:png
echo.
echo ��ʼת��Ϊ PNG ��ʽ...
for %%a in (*.jpg *.bmp *.tga *.jpeg *.webp *.avif *.tiff *.gif *.psd *.raw) do (
    echo ����ת���ļ�: %%a
    ffmpeg -i "%%a" -c:v png -y "%%~na.png"
    if %errorlevel% neq 0 (
        echo ת���ļ� %%a ʱ����
    ) else (
        echo �ļ� %%a ת���ɹ���
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
echo         ��лʹ�ã��ټ���
echo ========================================
timeout /t 2 >nul
exit