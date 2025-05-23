@echo off
color 0A
setlocal enabledelayedexpansion

rem 定义仓库地址，每行一个
set "repo[1]=git@gitee.com:meimolihan/1panel.git"
set "repo[2]=git@gitee.com:meimolihan/aipan.git"
set "repo[3]=git@gitee.com:meimolihan/alist.git"
set "repo[4]=git@gitee.com:meimolihan/home.git"
set "repo[5]=git@gitee.com:meimolihan/emby.git"
set "repo[6]=git@gitee.com:meimolihan/halo.git"
set "repo[7]=git@gitee.com:meimolihan/istoreos.git"
set "repo[8]=git@gitee.com:meimolihan/it-tools.git"
set "repo[9]=git@gitee.com:meimolihan/kspeeder.git"
set "repo[10]=git@gitee.com:meimolihan/nastools.git"
set "repo[11]=git@gitee.com:meimolihan/random-pic-api.git"
set "repo[12]=git@gitee.com:meimolihan/sun-panel.git"
set "repo[13]=git@gitee.com:meimolihan/tvhelper.git"
set "repo[14]=git@gitee.com:meimolihan/uptime-kuma.git"
set "repo[15]=git@gitee.com:meimolihan/xiaomusic.git"
set "repo[16]=git@gitee.com:meimolihan/xunlei.git"
set "repo[17]=git@gitee.com:meimolihan/md.git"
set "repo[18]=git@gitee.com:meimolihan/easyvoice.git"
set "repo[19]=git@gitee.com:meimolihan/dpanel.git"
set "repo[20]=git@gitee.com:meimolihan/libretv.git"
set "repo[21]=git@gitee.com:meimolihan/metube.git"


rem 你可以继续添加更多仓库地址，修改索引和地址即可

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

:menu
cls
echo 请选择要克隆的仓库：
echo ========================
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
echo ========================
echo x. 克隆所有仓库
echo y. 添加新的仓库
echo 0. 退出
echo ========================

set /p choice=请输入选项: 

rem 转换为小写以便不区分大小写比较
set "lc_choice=%choice%"
if not "%choice%"=="" (
    for /f "delims=" %%c in ('powershell -command "$env:choice.ToLower()"') do (
        set "lc_choice=%%c"
    )
)

if "%lc_choice%"=="0" (
    exit /b
)

if "%lc_choice%"=="x" (
    echo 正在准备克隆所有仓库...
    echo ========================
    set "all_success=1"
    
    for /l %%i in (1,1,!repo_count!) do (
        if defined repo[%%i] (
            set "repo_url=!repo[%%i]!"
            for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
                set "repo_name=%%~na"
                echo 正在克隆仓库：!repo_name!
                git clone !repo[%%i]! || (
                    echo [错误] 克隆仓库：!repo_name! 失败
                    set "all_success=0"
                )
                echo.
            )
        )
    )
    
    if !all_success! equ 1 (
        echo 所有仓库克隆成功！
    ) else (
        echo 部分仓库克隆失败，请检查网络或仓库地址。
    )
    
    pause
    goto menu
)

if "%lc_choice%"=="y" (
    set /a repo_count+=1
    set /p "new_repo=请输入新的仓库地址: "
    set "repo[!repo_count!]=!new_repo!"
    echo 已添加新仓库！
    pause
    goto menu
)

rem 验证用户输入是否为数字
echo %choice% | findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo 无效的选项，请重新输入。
    pause
    goto menu
)

if %choice% geq 1 if %choice% leq !repo_count! (
    if defined repo[%choice%] (
        set "repo_url=!repo[%choice%]!"
        for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
            set "repo_name=%%~na"
            echo 正在克隆仓库：!repo_name!
            git clone !repo[%choice%]! || (
                echo [错误] 克隆仓库：!repo_name! 失败
            )
        )
        pause
        goto menu
    )
)

echo 无效的选项，请重新输入。
pause
goto menu