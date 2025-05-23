@echo off
color 0A
setlocal enabledelayedexpansion

cls
echo ========================================
echo               Git ��¡�ֿ�
echo ========================================
set /p repoUrl="������Git�ֿ��URL��git clone����: "

if "%repoUrl%"=="" (
    color 0A
    echo.
    echo ========================================
    echo δ������Ч��URL�����������нű���������ȷ��URL��
    echo ========================================
    pause
    goto clone_menu
)

set "cleanUrl=%repoUrl%"
set "cleanUrl=%cleanUrl:git clone =%"
set "cleanUrl=%cleanUrl:git clone=%"

:: ��ȡ�ֿ�����
set "repoName=%cleanUrl%"
:: �Ƴ�URLĩβ��б��
:removeTrailingSlash
if "%repoName:~-1%"=="\" set "repoName=%repoName:~0,-1%" & goto removeTrailingSlash
if "%repoName:~-1%"=="/" set "repoName=%repoName:~0,-1%" & goto removeTrailingSlash
:: ��ȡ���һ��б�ܺ�Ĳ���
for %%a in ("%repoName%") do set "repoName=%%~nxa"
:: �Ƴ�.git��׺
set "repoName=%repoName:.git=%"


echo ========================================
echo.
echo ========================================
echo ���ڿ�¡�ֿ� "%repoName%"�����Ժ�...
echo ========================================
echo.
echo ========================================
git clone %cleanUrl%
echo ========================================
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo �ֿ� "%repoName%"����¡ʧ�ܣ�����URL�Ƿ���ȷ���������ӡ�
    echo ========================================
) else (
    echo.
    echo ========================================
    echo �ֿ� "%repoName%"����¡�ɹ���
    echo ========================================
)


echo ��лʹ�ã��ټ���
timeout /t 5 >nul
exit