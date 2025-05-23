@echo off
color 0A
setlocal enabledelayedexpansion

rem 定义仓库地址，每行一个
set "repo[1]=git@gitee.com:meimolihan/bat.git"  :: 常用批处理
set "repo[2]=git@gitee.com:meimolihan/360.git"  :: 360单机软件
set "repo[3]=git@gitee.com:meimolihan/final-shell.git"  :: 终端工具
set "repo[4]=git@gitee.com:meimolihan/clash.git"  :: 翻墙工具
set "repo[5]=git@gitee.com:meimolihan/dism.git"  :: Dism++系统优化工具
set "repo[6]=git@gitee.com:meimolihan/youtube.git"  :: youtube 视频下载
set "repo[7]=git@gitee.com:meimolihan/ffmpeg.git"  :: 音视频处理
set "repo[8]=git@gitee.com:meimolihan/bcuninstaller.git"  :: 卸载软件
set "repo[9]=git@gitee.com:meimolihan/typora.git"  :: 文本编辑器
set "repo[10]=git@gitee.com:meimolihan/lx-music-desktop.git"  :: 落雪音乐
set "repo[11]=git@gitee.com:meimolihan/xsnip.git"  :: 截图工具
set "repo[12]=git@gitee.com:meimolihan/image.git"  :: 图片处理
set "repo[13]=git@gitee.com:meimolihan/rename.git"  :: 大笨狗更名器
set "repo[14]=git@gitee.com:meimolihan/wallpaper.git"  :: windows 壁纸
set "repo[15]=git@gitee.com:meimolihan/trafficmonitor.git"  :: 显示网速

rem 获取仓库数量
set "repo_count=0"
for /l %%i in (1,1,999) do (
    if defined repo[%%i] (
        set /a repo_count+=1
    ) else (
        goto :break_loop
    )
)
:break_loop

:clone_menu
cls
echo ========================================
echo             请选择要克隆的仓库
echo ========================================
for /l %%i in (1,1,!repo_count!) do (
    if defined repo[%%i] (
        rem 提取仓库名
        set "repo_url=!repo[%%i]!"
        for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
            set "repo_name=%%~na"
            echo %%i. 克隆仓库：!repo_name!
        )
    )
)
echo ========================================
echo x. 克隆所有仓库
echo y. 克隆新的仓库
echo 0. 退出
echo ========================================

set /p choice=请输入操作编号: 

rem 转换为小写以便不区分大小写比较
set "lc_choice=%choice%"
if "%choice%" neq "" (
    for /f "delims=" %%c in ('powershell -command "'%choice%'.ToLower()"') do (
        set "lc_choice=%%c"
    )
)

if "%lc_choice%"=="x" goto git_clone_all
if "%lc_choice%"=="y" goto git_clone_new
if "%lc_choice%"=="0" goto EXIT_SCRIPT

rem 检查数字选择
if %choice% geq 1 if %choice% leq !repo_count! (
    if defined repo[%choice%] (
        set "repo_url=!repo[%choice%]!"
        for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
            cls
            set "repo_name=%%~na"
            echo ========================================
            echo      正在克隆仓库：!repo_name! 
            echo ========================================
            git clone !repo[%choice%]! || (
                echo.
                echo [错误] 克隆仓库：!repo_name! 失败
                echo ========================================
            )
        )
        echo.
        echo ========================================
        echo 仓库：!repo_name! ，所有操作已完成。
        echo ========================================
        pause
        goto clone_menu
    )
)

echo 无效的选项，请重新输入。
echo ========================================
pause
goto clone_menu

:git_clone_all
cls
echo 正在准备克隆所有仓库...
echo ========================================
set "all_success=1"

for /l %%i in (1,1,!repo_count!) do (
    if defined repo[%%i] (
        color 0A
        set "repo_url=!repo[%%i]!"
        for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
            set "repo_name=%%~na"
            echo 正在克隆仓库：!repo_name!
            git clone !repo[%%i]! || (
                echo [错误] 克隆仓库：!repo_name! 失败
                set "all_success=0"
            )
            echo ========================================
        )
    )
)

if !all_success! equ 1 (
    echo 所有仓库克隆成功！
) else (
    echo 部分仓库克隆失败，请检查网络或仓库地址。
)

echo ========================================
pause
goto clone_menu

:git_clone_new
cls
echo ========================================
echo               Git 克隆仓库
echo ========================================
set /p repoUrl="请输入Git仓库的URL或git clone命令: "

if "%repoUrl%"=="" (
    color 0A
    echo.
    echo ========================================
    echo 未输入有效的URL，请重新运行脚本并输入正确的URL。
    echo ========================================
    pause
    goto clone_menu
)

set "cleanUrl=%repoUrl%"
set "cleanUrl=%cleanUrl:git clone =%"
set "cleanUrl=%cleanUrl:git clone=%"

:: 提取仓库名称
set "repoName=%cleanUrl%"
:: 移除URL末尾的斜杠
:removeTrailingSlash
if "%repoName:~-1%"=="\" set "repoName=%repoName:~0,-1%" & goto removeTrailingSlash
if "%repoName:~-1%"=="/" set "repoName=%repoName:~0,-1%" & goto removeTrailingSlash
:: 提取最后一个斜杠后的部分
for %%a in ("%repoName%") do set "repoName=%%~nxa"
:: 移除.git后缀
set "repoName=%repoName:.git=%"


echo ========================================
echo.
echo ========================================
echo 正在克隆仓库 "%repoName%"，请稍候...
echo ========================================
echo.
echo ========================================
git clone %cleanUrl%
echo ========================================
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo 仓库 "%repoName%"，克隆失败，请检查URL是否正确或网络连接。
    echo ========================================
) else (
    echo.
    echo ========================================
    echo 仓库 "%repoName%"，克隆成功！
    echo ========================================
)

pause
goto clone_menu

echo ========================================
:EXIT_SCRIPT
cls
echo.
echo.
echo ========================================
echo         感谢使用，再见！
echo ========================================
timeout /t 2 >nul
exit