@echo off
color 0A
:: ��ʾ�û�����Git�ֿ��URL
set /p repoUrl="������Git�ֿ��URL: "

:: ����Ƿ�������URL
if "%repoUrl%"=="" (
    echo δ������Ч��URL�����������нű���������ȷ��URL��
    exit /b
)

:: ʹ��git clone��¡�ֿ�
echo ���ڿ�¡�ֿ⣬���Ժ�...
git clone %repoUrl%

:: ����¡�Ƿ�ɹ�
if %errorlevel% neq 0 (
    echo ��¡ʧ�ܣ�����URL�Ƿ���ȷ���������ӡ�
) else (
    echo ��¡�ɹ���
)

pause