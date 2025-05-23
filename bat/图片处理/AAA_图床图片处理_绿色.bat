@echo off
setlocal enabledelayedexpansion
REM 设置颜色为绿色背景，默认亮白色文字
COLOR 0A
CLS

:menu
	rem 清屏，显示主菜单
	cls

echo ==============================
echo        博客图片处理工具
echo ==============================
echo 1. 图片格式处理
echo 2. 复制图至仓库
echo 3. 更新仓库标签
echo 4. 复制图片链接
echo 5. 打开截图目录 
echo ==============================
echo 0. 退出
echo ==============================

    set "choice="
    set /p choice="请输入操作编号 (0 - 5): "
    if not defined choice (
        echo 输入不能为空，请输入（0 - 5）之间的数字。
        timeout /t 2 >nul
		rem 定义要返回的菜单
        goto menu
    )
	
	if "%choice%"=="1" goto img_aaa_menu
	if "%choice%"=="2" goto img_bbb_menu
	if "%choice%"=="3" goto img_ccc_menu
	if "%choice%"=="4" goto img_ddd_menu
	if "%choice%"=="5" goto img_eee_menu
	if "%choice%"=="0" goto exit_script
	

rem ==========================  一 、图片格式处理  ===========================
:img_aaa_menu
CLS
echo *******************************************************************************
REM 检查是否有可处理的文件
set "has_files=0"
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.avif *.tiff *.gif *.psd *.raw) do (
    set "has_files=1"
    goto :process_files
)

if !has_files! equ 0 (
    echo 当前目录中没有找到可转换的图片文件。
    echo 2秒后将返回...
    timeout /t 2 /nobreak >nul
    goto menu
    exit /b
)
:process_files
REM 开始转换图片
set "file_count=0"
echo 正在处理的文件：
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.avif *.tiff *.gif *.psd *.raw) do (
    set /a file_count+=1
    echo %%a
    echo *******************************************************************************
    ffmpeg -i "%%a" -c:v libwebp -lossless 0 -q:v 80 -y "%%~na.webp"
    if !errorlevel! neq 0 (
        echo 转换文件 %%a 时出错。
    ) else (
        echo *******************************************************************************
        echo 文件 %%a 转换成功。
    )
)

echo 任务完成！所有文件已转换为.webp格式。
echo *******************************************************************************
echo 已处理的文件：
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.avif *.tiff *.gif *.psd *.raw) do (
    echo %%a
)
echo *******************************************************************************
echo *                                   删除原文件                                *
echo *******************************************************************************
rem ============= 删除多余文件 ===========
:: 设置要操作的目录（当前脚本所在目录为默认）
set "target_dir=%~dp0"

:: 定义排除的文件名和文件夹名（用空格分隔）
set "exclude_files=*.bat *.exe *.webp"
set "exclude_folders=透明图片处理 1920x1080 hugo歌曲代码生成 typecho歌曲 博客图片处理"

:: 遍历目录下的所有文件
for %%f in ("%target_dir%\*") do (
    :: 检查是否是文件
    if exist "%%f" (
        set "is_excluded="
        for %%e in (%exclude_files%) do (
            if /i "%%~nxf"=="%%~e" (
                set "is_excluded=true"
            )
        )
        if not defined is_excluded (
            echo 删除文件: %%f
            del "%%f" >nul 2>&1
        )
    )
)

:: 遍历目录下的所有文件夹
for /d %%d in ("%target_dir%\*") do (
    set "is_excluded="
    for %%e in (%exclude_folders%) do (
        if /i "%%~nxd"=="%%~e" (
            set "is_excluded=true"
        )
    )
    if not defined is_excluded (
        echo 删除文件夹: %%d
        rd /s /q "%%d" >nul 2>&1
    )
)
echo *******************************************************************************
echo 所有操作已完成，按任意键返回...
pause >nul
goto menu


rem ==========================  二 、复制图至仓库  ===========================
:img_bbb_menu
CLS :: 清屏
:: 设置目标目录
set "TARGET1=%USERPROFILE%\Desktop\GitHub\file\screenshot"
set "TARGET2=Y:\blog\screenshot"

:: 创建目标目录（如果不存在）
if not exist "%TARGET1%" mkdir "%TARGET1%"
if not exist "%TARGET2%" mkdir "%TARGET2%"

:: 获取当前目录
set "SOURCE_DIR=%~dp0"

:: 收集所有.webp文件路径
set "count=0"
for /r "%SOURCE_DIR%" %%f in (*.webp) do (
    set /a count+=1
    set "files[!count!]=%%f"
)

if %count% equ 0 (
    echo 没有找到 .webp 文件
    pause
    goto menu
    exit /b
)

:: 显示找到的文件
echo *******************************************************************************
echo *                               找到以下 .webp 文件                           *
echo *******************************************************************************
for /l %%i in (1,1,%count%) do (
    echo !files[%%i]!
)
echo *******************************************************************************
echo * 远程图床目录：%USERPROFILE%\Desktop\GitHub\file\screenshot
echo * 本地图床目录：Y:\blog\screenshot
echo *******************************************************************************

echo.
echo *******************************************************************************
echo *                           正在复制文件到目标目录                            *
echo *******************************************************************************
for /l %%i in (1,1,%count%) do (
    set "file=!files[%%i]!"
    echo 正在复制: !file!
    copy "!file!" "%TARGET1%" >nul
    copy "!file!" "%TARGET2%" >nul
)

echo *******************************************************************************
echo *                           所有 .webp 文件已复制完成                         *
echo *******************************************************************************
echo 所有操作已完成，按任意键返回...
pause >nul
goto menu

rem ==========================  三 、更新仓库标签  ===========================
:img_ccc_menu
CLS
@echo off
REM Windows 批处理脚本：更新 Git 标签

REM 设置颜色为绿色背景，默认亮白色文字
COLOR 0A
CLS
PROMPT $P$G

REM 设置 Git 仓库路径
SET REPO_PATH=%USERPROFILE%\Desktop\GitHub\file

REM 切换到指定的 Git 仓库目录
CD /D %REPO_PATH%

REM 检查是否成功切换到仓库目录
IF NOT EXIST .git (
    echo ===========================================
    echo 错误：目录 %REPO_PATH% 不是一个有效的 Git 仓库。
    echo ===========================================
    pause
    EXIT /B 1
)

REM 添加所有更改并提交
echo ===========================================
echo 正在添加所有更改...
git add .
echo ===========================================
echo 正在提交更改，提交信息为 "update"...
git commit -m "update"
echo ===========================================

REM 推送提交到远程仓库
echo 正在将提交推送到远程仓库...
git push
echo ===========================================

REM 删除本地标签 v1.0.0
echo 正在删除本地标签 v1.0.0...
git tag -d v1.0.0
echo ===========================================

REM 删除远程标签 v1.0.0
echo 正在删除远程标签 v1.0.0...
git push origin :refs/tags/v1.0.0
echo ===========================================

REM 检查标签是否删除成功
echo 检查标签 v1.0.0 是否删除成功...
git tag -l | findstr /I "v1.0.0" >nul
IF %ERRORLEVEL% EQU 0 (
    echo 远程标签 v1.0.0 删除失败，请手动检查。
) ELSE (
    echo 远程标签 v1.0.0 删除成功。
)
echo ===========================================

REM 创建新标签 v1.0.0
echo 正在创建新标签 v1.0.0，标签信息为 "为最新提交的重新创建标签"...
git tag -a v1.0.0 -m "Recreate tags for the latest submission"
echo ===========================================

REM 推送新标签到远程仓库
echo 正在将新的标签 v1.0.0 推送到远程仓库...
git push origin v1.0.0
echo ===========================================

REM 检查标签是否推送成功
echo 检查标签 v1.0.0 是否推送成功...
git tag -l | findstr /I "v1.0.0" >nul
IF %ERRORLEVEL% EQU 0 (
    echo 标签 v1.0.0 推送成功。
) ELSE (
    echo 标签 v1.0.0 推送失败，请手动检查。
)
echo ===========================================

echo 所有操作已完成。
goto menu

rem ==========================  四、复制图片链接  ===========================
:img_ddd_menu
CLS
@echo off
setlocal disabledelayedexpansion

set "img_dir=."
set "count=0"

for %%F in ("%img_dir%\*.jpg" "%img_dir%\*.webp") do (
    set /a "count+=1"
    
    :: 构造完整的Markdown图片链接（确保包含右括号）
    echo ^!^[](https://file.meimolihan.eu.org/screenshot/%%~nxF^) > "%temp%\md_link.txt"
    clip < "%temp%\md_link.txt"
    
    :: 显示输出（确保包含右括号）
    echo 正在处理: %%~nxF
    echo 已复制：![](https://file.meimolihan.eu.org/screenshot/%%~nxF^)
    echo 按任意键继续处理下一个文件...
    pause > nul
)

echo 所有 %count% 个文件处理完成，按任意键返回...
pause >nul
goto menu

rem ==========================  五 、打开截图目录  ===========================
:img_eee_menu
	start "" "%USERPROFILE%\Desktop\GitHub\file\screenshot"
        start "" "Y:\blog\screenshot"
goto menu





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