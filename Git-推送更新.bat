@echo off
setlocal EnableDelayedExpansion

::===================== 生成 ESC 字符 =====================
:: 用 prompt  hack 得到 0x1B
for /f "delims=#" %%a in ('prompt #$E# ^& for %%b in ^(1^) do rem') do set "ESC=%%a"

::===================== 颜色变量 ==========================
set "gl_hui=37"
set "gl_hong=31"
set "gl_lv=32"
set "gl_huang=33"
set "gl_lan=34"
set "gl_zi=35"
set "gl_bufan=96"
set "gl_bai=0"

::===================== 日志函数 ==========================
set "log_info=echo !ESC![34m[信息]!ESC![0m"
set "log_ok  =echo !ESC![32m[成功]!ESC![0m"
set "log_warn=echo !ESC![33m[警告]!ESC![0m"
set "log_error=echo !ESC![31m[错误]!ESC![0m"

::===================== 分割线 ============================
set "LINE=!ESC![96m------------------------!ESC![0m"

::===================== 主程序 ============================
title Git自动提交推送工具
set "REPO_PATH=%CD%"

:MAIN
call :ValidateRepoAndCommit
goto :EXIT_SCRIPT

:ValidateRepoAndCommit
if not exist "%REPO_PATH%" (
    call :ShowError "目录 %REPO_PATH% 不存在"
    exit /b 1
)
cd /d "%REPO_PATH%" 2>nul || (
    call :ShowError "无法切换到目录 %REPO_PATH%"
    exit /b 1
)
if not exist .git (
    call :ShowError "当前目录不是有效 Git 仓库"
    exit /b 1
)

:CheckForChanges
call :ShowMessage "正在检查当前Git仓库状态..."
git status >nul 2>&1 || (
    call :ShowError "无法获取Git仓库状态"
    exit /b 1
)

set "CHANGES="
for /f "delims=" %%D in ('git status --porcelain') do set "CHANGES=YES"

if defined CHANGES (
    call :ShowMessage "检测到文件修改，准备提交..."
    set "COMMIT_MSG=自动提交于 %DATE% %TIME%"
    set /p "COMMIT_MSG=请输入提交信息(直接回车使用默认信息): "
    if "!COMMIT_MSG!"=="" set "COMMIT_MSG=自动提交于 %DATE% %TIME%"

    call :AddChanges  || exit /b 1
    call :CommitChanges "!COMMIT_MSG!" || exit /b 1
    call :PushChanges   || exit /b 1
    call :ShowMessage "提交和推送成功完成！"
) else (
    call :ShowMessage "没有检测到文件修改，尝试直接推送..."
    call :PushChanges || exit /b 1
)
call :ShowMessage "脚本执行完成。"
exit /b 0

:AddChanges
!log_info! 正在添加所有更改到暂存区
git add . || (
    !log_error! 无法添加文件到暂存区
    exit /b 1
)
exit /b 0

:CommitChanges
!log_info! 正在提交更改到本地仓库
git commit -m "%~1" || (
    !log_error! 提交到本地仓库失败
    exit /b 1
)
exit /b 0

:PushChanges
!log_info! 正在推送更改到远程仓库
for /f "delims=" %%b in ('git symbolic-ref --short HEAD 2^>nul') do set "CURRENT_BRANCH=%%b"
if defined CURRENT_BRANCH ( git push origin !CURRENT_BRANCH! ) else ( git push )
if errorlevel 1 (
    !log_error! 推送到远程仓库失败
    exit /b 1
)
exit /b 0

:ShowMessage
echo.
!log_info! %~1
echo !LINE!
echo.
goto :eof

:ShowError
echo.
!log_error! %~1
echo !LINE!
goto :eof

:EXIT_SCRIPT
:: 2 秒倒计时自动退出
set /a t=2
:countDown
echo.
echo 脚本执行完毕，%t% 秒后自动退出…
ping -n 2 127.0.0.1 >nul
set /a t-=1
if %t% gtr 0 goto countDown
exit /b 0

