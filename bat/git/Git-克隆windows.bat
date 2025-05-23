@echo off
color 0A
setlocal enabledelayedexpansion

rem ����ֿ��ַ��ÿ��һ��
set "repo[1]=git@gitee.com:meimolihan/bat.git"  :: ����������
set "repo[2]=git@gitee.com:meimolihan/360.git"  :: 360�������
set "repo[3]=git@gitee.com:meimolihan/final-shell.git"  :: �ն˹���
set "repo[4]=git@gitee.com:meimolihan/clash.git"  :: ��ǽ����
set "repo[5]=git@gitee.com:meimolihan/dism.git"  :: Dism++ϵͳ�Ż�����
set "repo[6]=git@gitee.com:meimolihan/youtube.git"  :: youtube ��Ƶ����
set "repo[7]=git@gitee.com:meimolihan/ffmpeg.git"  :: ����Ƶ����
set "repo[8]=git@gitee.com:meimolihan/bcuninstaller.git"  :: ж�����
set "repo[9]=git@gitee.com:meimolihan/typora.git"  :: �ı��༭��
set "repo[10]=git@gitee.com:meimolihan/lx-music-desktop.git"  :: ��ѩ����
set "repo[11]=git@gitee.com:meimolihan/xsnip.git"  :: ��ͼ����
set "repo[12]=git@gitee.com:meimolihan/image.git"  :: ͼƬ����
set "repo[13]=git@gitee.com:meimolihan/rename.git"  :: �󱿹�������
set "repo[14]=git@gitee.com:meimolihan/wallpaper.git"  :: windows ��ֽ
set "repo[15]=git@gitee.com:meimolihan/trafficmonitor.git"  :: ��ʾ����

rem ��ȡ�ֿ�����
set "repo_count=0"
for /l %%i in (1,1,999) do (
    if defined repo[%%i] (
        set /a repo_count+=1
    ) else (
        goto :break_loop
    )
)
:break_loop

:clone_menu
cls
echo ========================================
echo             ��ѡ��Ҫ��¡�Ĳֿ�
echo ========================================
for /l %%i in (1,1,!repo_count!) do (
    if defined repo[%%i] (
        rem ��ȡ�ֿ���
        set "repo_url=!repo[%%i]!"
        for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
            set "repo_name=%%~na"
            echo %%i. ��¡�ֿ⣺!repo_name!
        )
    )
)
echo ========================================
echo x. ��¡���вֿ�
echo y. ��¡�µĲֿ�
echo 0. �˳�
echo ========================================

set /p choice=������������: 

rem ת��ΪСд�Ա㲻���ִ�Сд�Ƚ�
set "lc_choice=%choice%"
if "%choice%" neq "" (
    for /f "delims=" %%c in ('powershell -command "'%choice%'.ToLower()"') do (
        set "lc_choice=%%c"
    )
)

if "%lc_choice%"=="x" goto git_clone_all
if "%lc_choice%"=="y" goto git_clone_new
if "%lc_choice%"=="0" goto EXIT_SCRIPT

rem �������ѡ��
if %choice% geq 1 if %choice% leq !repo_count! (
    if defined repo[%choice%] (
        set "repo_url=!repo[%choice%]!"
        for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
            cls
            set "repo_name=%%~na"
            echo ========================================
            echo      ���ڿ�¡�ֿ⣺!repo_name! 
            echo ========================================
            git clone !repo[%choice%]! || (
                echo.
                echo [����] ��¡�ֿ⣺!repo_name! ʧ��
                echo ========================================
            )
        )
        echo.
        echo ========================================
        echo �ֿ⣺!repo_name! �����в�������ɡ�
        echo ========================================
        pause
        goto clone_menu
    )
)

echo ��Ч��ѡ����������롣
echo ========================================
pause
goto clone_menu

:git_clone_all
cls
echo ����׼����¡���вֿ�...
echo ========================================
set "all_success=1"

for /l %%i in (1,1,!repo_count!) do (
    if defined repo[%%i] (
        color 0A
        set "repo_url=!repo[%%i]!"
        for /f "tokens=2 delims=/" %%a in ("!repo_url:*.com:=!") do (
            set "repo_name=%%~na"
            echo ���ڿ�¡�ֿ⣺!repo_name!
            git clone !repo[%%i]! || (
                echo [����] ��¡�ֿ⣺!repo_name! ʧ��
                set "all_success=0"
            )
            echo ========================================
        )
    )
)

if !all_success! equ 1 (
    echo ���вֿ��¡�ɹ���
) else (
    echo ���ֲֿ��¡ʧ�ܣ����������ֿ��ַ��
)

echo ========================================
pause
goto clone_menu

:git_clone_new
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

pause
goto clone_menu

echo ========================================
:EXIT_SCRIPT
cls
echo.
echo.
echo ========================================
echo         ��лʹ�ã��ټ���
echo ========================================
timeout /t 2 >nul
exit