@echo off
color 0A
:: 提示用户输入Git仓库的URL
set /p repoUrl="请输入Git仓库的URL: "

:: 检查是否输入了URL
if "%repoUrl%"=="" (
    echo 未输入有效的URL，请重新运行脚本并输入正确的URL。
    exit /b
)

:: 使用git clone克隆仓库
echo 正在克隆仓库，请稍候...
git clone %repoUrl%

:: 检查克隆是否成功
if %errorlevel% neq 0 (
    echo 克隆失败，请检查URL是否正确或网络连接。
) else (
    echo 克隆成功！
)

pause