@echo off
setlocal enabledelayedexpansion
REM ������ɫΪ��ɫ������Ĭ������ɫ����
COLOR 0A
CLS

:menu
	rem ��������ʾ���˵�
	cls

echo ==============================
echo        ����ͼƬ������
echo ==============================
echo 1. ͼƬ��ʽ����
echo 2. ����ͼ���ֿ�
echo 3. ���²ֿ��ǩ
echo 4. ����ͼƬ����
echo 5. �򿪽�ͼĿ¼ 
echo ==============================
echo 0. �˳�
echo ==============================

    set "choice="
    set /p choice="������������ (0 - 5): "
    if not defined choice (
        echo ���벻��Ϊ�գ������루0 - 5��֮������֡�
        timeout /t 2 >nul
		rem ����Ҫ���صĲ˵�
        goto menu
    )
	
	if "%choice%"=="1" goto img_aaa_menu
	if "%choice%"=="2" goto img_bbb_menu
	if "%choice%"=="3" goto img_ccc_menu
	if "%choice%"=="4" goto img_ddd_menu
	if "%choice%"=="5" goto img_eee_menu
	if "%choice%"=="0" goto exit_script
	

rem ==========================  һ ��ͼƬ��ʽ����  ===========================
:img_aaa_menu
CLS
echo *******************************************************************************
REM ����Ƿ��пɴ�����ļ�
set "has_files=0"
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.avif *.tiff *.gif *.psd *.raw) do (
    set "has_files=1"
    goto :process_files
)

if !has_files! equ 0 (
    echo ��ǰĿ¼��û���ҵ���ת����ͼƬ�ļ���
    echo 2��󽫷���...
    timeout /t 2 /nobreak >nul
    goto menu
    exit /b
)
:process_files
REM ��ʼת��ͼƬ
set "file_count=0"
echo ���ڴ�����ļ���
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.avif *.tiff *.gif *.psd *.raw) do (
    set /a file_count+=1
    echo %%a
    echo *******************************************************************************
    ffmpeg -i "%%a" -c:v libwebp -lossless 0 -q:v 80 -y "%%~na.webp"
    if !errorlevel! neq 0 (
        echo ת���ļ� %%a ʱ����
    ) else (
        echo *******************************************************************************
        echo �ļ� %%a ת���ɹ���
    )
)

echo ������ɣ������ļ���ת��Ϊ.webp��ʽ��
echo *******************************************************************************
echo �Ѵ�����ļ���
for %%a in (*.png *.bmp *.tga *.jpeg *.jpg *.avif *.tiff *.gif *.psd *.raw) do (
    echo %%a
)
echo *******************************************************************************
echo *                                   ɾ��ԭ�ļ�                                *
echo *******************************************************************************
rem ============= ɾ�������ļ� ===========
:: ����Ҫ������Ŀ¼����ǰ�ű�����Ŀ¼ΪĬ�ϣ�
set "target_dir=%~dp0"

:: �����ų����ļ������ļ��������ÿո�ָ���
set "exclude_files=*.bat *.exe *.webp"
set "exclude_folders=͸��ͼƬ���� 1920x1080 hugo������������ typecho���� ����ͼƬ����"

:: ����Ŀ¼�µ������ļ�
for %%f in ("%target_dir%\*") do (
    :: ����Ƿ����ļ�
    if exist "%%f" (
        set "is_excluded="
        for %%e in (%exclude_files%) do (
            if /i "%%~nxf"=="%%~e" (
                set "is_excluded=true"
            )
        )
        if not defined is_excluded (
            echo ɾ���ļ�: %%f
            del "%%f" >nul 2>&1
        )
    )
)

:: ����Ŀ¼�µ������ļ���
for /d %%d in ("%target_dir%\*") do (
    set "is_excluded="
    for %%e in (%exclude_folders%) do (
        if /i "%%~nxd"=="%%~e" (
            set "is_excluded=true"
        )
    )
    if not defined is_excluded (
        echo ɾ���ļ���: %%d
        rd /s /q "%%d" >nul 2>&1
    )
)
echo *******************************************************************************
echo ���в�������ɣ������������...
pause >nul
goto menu


rem ==========================  �� ������ͼ���ֿ�  ===========================
:img_bbb_menu
CLS :: ����
:: ����Ŀ��Ŀ¼
set "TARGET1=%USERPROFILE%\Desktop\GitHub\file\screenshot"
set "TARGET2=Y:\blog\screenshot"

:: ����Ŀ��Ŀ¼����������ڣ�
if not exist "%TARGET1%" mkdir "%TARGET1%"
if not exist "%TARGET2%" mkdir "%TARGET2%"

:: ��ȡ��ǰĿ¼
set "SOURCE_DIR=%~dp0"

:: �ռ�����.webp�ļ�·��
set "count=0"
for /r "%SOURCE_DIR%" %%f in (*.webp) do (
    set /a count+=1
    set "files[!count!]=%%f"
)

if %count% equ 0 (
    echo û���ҵ� .webp �ļ�
    pause
    goto menu
    exit /b
)

:: ��ʾ�ҵ����ļ�
echo *******************************************************************************
echo *                               �ҵ����� .webp �ļ�                           *
echo *******************************************************************************
for /l %%i in (1,1,%count%) do (
    echo !files[%%i]!
)
echo *******************************************************************************
echo * Զ��ͼ��Ŀ¼��%USERPROFILE%\Desktop\GitHub\file\screenshot
echo * ����ͼ��Ŀ¼��Y:\blog\screenshot
echo *******************************************************************************

echo.
echo *******************************************************************************
echo *                           ���ڸ����ļ���Ŀ��Ŀ¼                            *
echo *******************************************************************************
for /l %%i in (1,1,%count%) do (
    set "file=!files[%%i]!"
    echo ���ڸ���: !file!
    copy "!file!" "%TARGET1%" >nul
    copy "!file!" "%TARGET2%" >nul
)

echo *******************************************************************************
echo *                           ���� .webp �ļ��Ѹ������                         *
echo *******************************************************************************
echo ���в�������ɣ������������...
pause >nul
goto menu

rem ==========================  �� �����²ֿ��ǩ  ===========================
:img_ccc_menu
CLS
@echo off
REM Windows ������ű������� Git ��ǩ

REM ������ɫΪ��ɫ������Ĭ������ɫ����
COLOR 0A
CLS
PROMPT $P$G

REM ���� Git �ֿ�·��
SET REPO_PATH=%USERPROFILE%\Desktop\GitHub\file

REM �л���ָ���� Git �ֿ�Ŀ¼
CD /D %REPO_PATH%

REM ����Ƿ�ɹ��л����ֿ�Ŀ¼
IF NOT EXIST .git (
    echo ===========================================
    echo ����Ŀ¼ %REPO_PATH% ����һ����Ч�� Git �ֿ⡣
    echo ===========================================
    pause
    EXIT /B 1
)

REM ������и��Ĳ��ύ
echo ===========================================
echo ����������и���...
git add .
echo ===========================================
echo �����ύ���ģ��ύ��ϢΪ "update"...
git commit -m "update"
echo ===========================================

REM �����ύ��Զ�ֿ̲�
echo ���ڽ��ύ���͵�Զ�ֿ̲�...
git push
echo ===========================================

REM ɾ�����ر�ǩ v1.0.0
echo ����ɾ�����ر�ǩ v1.0.0...
git tag -d v1.0.0
echo ===========================================

REM ɾ��Զ�̱�ǩ v1.0.0
echo ����ɾ��Զ�̱�ǩ v1.0.0...
git push origin :refs/tags/v1.0.0
echo ===========================================

REM ����ǩ�Ƿ�ɾ���ɹ�
echo ����ǩ v1.0.0 �Ƿ�ɾ���ɹ�...
git tag -l | findstr /I "v1.0.0" >nul
IF %ERRORLEVEL% EQU 0 (
    echo Զ�̱�ǩ v1.0.0 ɾ��ʧ�ܣ����ֶ���顣
) ELSE (
    echo Զ�̱�ǩ v1.0.0 ɾ���ɹ���
)
echo ===========================================

REM �����±�ǩ v1.0.0
echo ���ڴ����±�ǩ v1.0.0����ǩ��ϢΪ "Ϊ�����ύ�����´�����ǩ"...
git tag -a v1.0.0 -m "Recreate tags for the latest submission"
echo ===========================================

REM �����±�ǩ��Զ�ֿ̲�
echo ���ڽ��µı�ǩ v1.0.0 ���͵�Զ�ֿ̲�...
git push origin v1.0.0
echo ===========================================

REM ����ǩ�Ƿ����ͳɹ�
echo ����ǩ v1.0.0 �Ƿ����ͳɹ�...
git tag -l | findstr /I "v1.0.0" >nul
IF %ERRORLEVEL% EQU 0 (
    echo ��ǩ v1.0.0 ���ͳɹ���
) ELSE (
    echo ��ǩ v1.0.0 ����ʧ�ܣ����ֶ���顣
)
echo ===========================================

echo ���в�������ɡ�
goto menu

rem ==========================  �ġ�����ͼƬ����  ===========================
:img_ddd_menu
CLS
@echo off
setlocal disabledelayedexpansion

set "img_dir=."
set "count=0"

for %%F in ("%img_dir%\*.jpg" "%img_dir%\*.webp") do (
    set /a "count+=1"
    
    :: ����������MarkdownͼƬ���ӣ�ȷ�����������ţ�
    echo ^!^[](https://file.meimolihan.eu.org/screenshot/%%~nxF^) > "%temp%\md_link.txt"
    clip < "%temp%\md_link.txt"
    
    :: ��ʾ�����ȷ�����������ţ�
    echo ���ڴ���: %%~nxF
    echo �Ѹ��ƣ�![](https://file.meimolihan.eu.org/screenshot/%%~nxF^)
    echo �����������������һ���ļ�...
    pause > nul
)

echo ���� %count% ���ļ�������ɣ������������...
pause >nul
goto menu

rem ==========================  �� ���򿪽�ͼĿ¼  ===========================
:img_eee_menu
	start "" "%USERPROFILE%\Desktop\GitHub\file\screenshot"
        start "" "Y:\blog\screenshot"
goto menu





echo ========================================
:exit_script
cls
echo.
echo.
echo ========================================
echo         ��лʹ�ã��ټ���
echo ========================================
timeout /t 2 >nul
exit