@echo off
color 0A
setlocal enabledelayedexpansion

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


echo 感谢使用，再见！
timeout /t 5 >nul
exit