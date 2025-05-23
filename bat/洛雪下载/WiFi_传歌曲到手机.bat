@echo off
setlocal enabledelayedexpansion

for /L %%i in (1,1,200) do (
    set "url=http://10.10.10.%%i:8080 "
    echo 正在测试 !url!
    ping -n 1 -w 1000 10.10.10.%%i >nul
    if !errorlevel! equ 0 (
        powershell -Command "Test-NetConnection -ComputerName 10.10.10.%%i -Port 8080 -InformationLevel Quiet" | find "True" >nul
        if !errorlevel! equ 0 (
            echo !url! 可以访问，正在使用浏览器打开...
            start "" "!url!"
            goto end_loop
        ) else (
            echo !url! 无法访问。
        )
    ) else (
        echo 10.10.10.%%i 不可达。
    )
)

:end_loop
endlocal