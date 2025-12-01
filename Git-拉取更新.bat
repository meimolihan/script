@echo off
setlocal EnableDelayedExtensions

:: 生成 ESC 字符
for /f "delims=#" %%a in ('prompt #$E# ^& for %%b in ^(1^) do rem') do set "ESC=%%a"

:: 颜色
set "gl_lv=32"
set "LINE=%ESC%[96m------------------------%ESC%[0m"

cls
call echo %ESC%[%gl_lv%m正在从远程仓库拉取更新...%ESC%[0m
call echo %LINE%
echo.

:: 拉取并屏蔽所有警告
git pull >nul 2>&1

if %errorlevel% equ 0 (
    call echo %LINE%
    call echo %ESC%[%gl_lv%m拉取成功！本地仓库已是最新版本。%ESC%[0m
    call echo %LINE%
) else (
    call echo %LINE%
    call echo %ESC%[31m拉取失败！请检查网络或远程仓库地址是否正确。%ESC%[0m
    call echo %LINE%
)
pause
endlocal