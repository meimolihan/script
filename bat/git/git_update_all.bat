@echo off
setLocal EnableDelayedExpansion

echo ����ɨ��Ŀ¼����Ŀ¼�е� Git �ֿ�...

for /d /r "." %%d in (.) do (
    if exist "%%d\.git" (
        echo.
        echo ��⵽ Git �ֿ�: %%d
        cd /d "%%d"
        echo ������ȡԶ�̸���...
        git pull
        echo.
        echo ��ȡ���: %%d
        echo ---------------------------
    )
)

echo ɨ����ɣ�
pause