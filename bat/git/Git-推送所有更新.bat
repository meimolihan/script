@echo off
setlocal enabledelayedexpansion

REM 设置颜色为绿色背景，默认亮白色文字
COLOR 0A
CLS
PROMPT $P$G

REM 设置根目录为当前脚本所在的目录
set "ROOT_DIR=%~dp0"

REM 检查目录是否存在
if not exist "%ROOT_DIR%" (
    echo 指定的目录 "%ROOT_DIR%" 不存在。
    pause
    exit /b 1
)

REM 遍历当前目录下的所有文件夹
echo 正在检查当前目录中的 Git 项目...
echo.
for /d %%F in ("%ROOT_DIR%\*") do (
    REM 检查文件夹是否是 Git 项目（通过检查 .git 文件夹是否存在）
    if exist "%%F\.git" (
        REM 切换到目录并执行 git pull
        pushd "%%F"
        echo.
        echo ========================================
        echo 正在更新项目: %%~nxF
        echo 项目路径: %%F
        echo ========================================
        git pull origin main
        popd
        echo.
        echo.
    )
)

echo 所有项目更新完成！
pause
exit /b 0