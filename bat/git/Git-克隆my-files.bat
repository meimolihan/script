@echo off
setlocal enabledelayedexpansion

:: 设置仓库地址
set REPO_URL=git@gitee.com:meimolihan/my-files.git
:: 设置本地存放目录（默认当前目录下创建与仓库同名的文件夹）
set TARGET_DIR=%~dp0%REPO_URL:*/=%
set TARGET_DIR=%TARGET_DIR:.git=%

:: 检查git命令是否可用
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [错误] 未检测到git命令，请先安装Git并配置环境变量
    pause
    exit /b 1
)

:: 执行克隆
echo 正在克隆仓库到: %TARGET_DIR%
git clone %REPO_URL% "%TARGET_DIR%"

if %ERRORLEVEL% equ 0 (
    echo 克隆成功！仓库路径: %TARGET_DIR%
) else (
    echo [错误] 克隆失败，请检查：
    echo 1. 网络连接是否正常
    echo 2. 是否有仓库访问权限
    echo 3. 目标路径是否已存在冲突文件夹
)
pause