@echo off
setlocal enabledelayedexpansion

:: ���òֿ��ַ
set REPO_URL=git@gitee.com:meimolihan/my-files.git
:: ���ñ��ش��Ŀ¼��Ĭ�ϵ�ǰĿ¼�´�����ֿ�ͬ�����ļ��У�
set TARGET_DIR=%~dp0%REPO_URL:*/=%
set TARGET_DIR=%TARGET_DIR:.git=%

:: ���git�����Ƿ����
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [����] δ��⵽git������Ȱ�װGit�����û�������
    pause
    exit /b 1
)

:: ִ�п�¡
echo ���ڿ�¡�ֿ⵽: %TARGET_DIR%
git clone %REPO_URL% "%TARGET_DIR%"

if %ERRORLEVEL% equ 0 (
    echo ��¡�ɹ����ֿ�·��: %TARGET_DIR%
) else (
    echo [����] ��¡ʧ�ܣ����飺
    echo 1. ���������Ƿ�����
    echo 2. �Ƿ��вֿ����Ȩ��
    echo 3. Ŀ��·���Ƿ��Ѵ��ڳ�ͻ�ļ���
)
pause