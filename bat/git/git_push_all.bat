@echo off
setlocal enabledelayedexpansion

REM ������ɫΪ��ɫ������Ĭ������ɫ����
COLOR 0A
CLS
PROMPT $P$G

REM ���ø�Ŀ¼Ϊ��ǰ�ű����ڵ�Ŀ¼
set "ROOT_DIR=%~dp0"

REM ���Ŀ¼�Ƿ����
if not exist "%ROOT_DIR%" (
    echo ָ����Ŀ¼ "%ROOT_DIR%" �����ڡ�
    pause
    exit /b 1
)

REM ������ǰĿ¼�µ������ļ���
echo ���ڼ�鵱ǰĿ¼�е� Git ��Ŀ...
echo.
for /d %%F in ("%ROOT_DIR%\*") do (
    REM ����ļ����Ƿ��� Git ��Ŀ��ͨ����� .git �ļ����Ƿ���ڣ�
    if exist "%%F\.git" (
        REM �л���Ŀ¼��ִ�� git pull
        pushd "%%F"
        echo.
        echo ========================================
        echo ���ڸ�����Ŀ: %%~nxF
        echo ��Ŀ·��: %%F
        echo ========================================
        git pull origin main
        popd
        echo.
        echo.
    )
)

echo ������Ŀ������ɣ�
pause
exit /b 0