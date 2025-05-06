@echo off
setLocal EnableDelayedExpansion

echo 正在扫描目录及子目录中的 Git 仓库...

for /d /r "." %%d in (.) do (
    if exist "%%d\.git" (
        echo.
        echo 检测到 Git 仓库: %%d
        cd /d "%%d"
        echo 正在拉取远程更新...
        git pull
        echo.
        echo 拉取完成: %%d
        echo ---------------------------
    )
)

echo 扫描完成！
pause