@echo off
setlocal enabledelayedexpansion

for /L %%i in (1,1,200) do (
    set "url=http://10.10.10.%%i:8080 "
    echo ���ڲ��� !url!
    ping -n 1 -w 1000 10.10.10.%%i >nul
    if !errorlevel! equ 0 (
        powershell -Command "Test-NetConnection -ComputerName 10.10.10.%%i -Port 8080 -InformationLevel Quiet" | find "True" >nul
        if !errorlevel! equ 0 (
            echo !url! ���Է��ʣ�����ʹ���������...
            start "" "!url!"
            goto end_loop
        ) else (
            echo !url! �޷����ʡ�
        )
    ) else (
        echo 10.10.10.%%i ���ɴ
    )
)

:end_loop
endlocal