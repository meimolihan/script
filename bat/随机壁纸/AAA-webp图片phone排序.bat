@echo off
setlocal enabledelayedexpansion

:: ������
set "default_prefix=phone"

:: �û����뽻��
set /p "prefix=�������ļ���ǰ׺��Ĭ�� %default_prefix%����"
if "%prefix%"=="" set "prefix=%default_prefix%"
echo ����ʹ��ǰ׺��[%prefix%]

:: ����Ĭ����ʼ���
set /a start_number=1

:: ��ʼ��������
set /a counter=%start_number%
set "error_log=rename_errors.log"
set "temp_folder=temp_rename_folder"

:: ��վ���־
if exist "%error_log%" del "%error_log%"

:: ������ʱ�ļ���
if not exist "%temp_folder%" mkdir "%temp_folder%"

:: �ƶ�����.webp�ļ�����ʱ�ļ���
for /f "delims=" %%F in ('dir /b /a-d /o:d *.webp') do (
    move "%%F" "%temp_folder%\" 
    if errorlevel 1 (
        echo �����ƶ��ļ�ʧ�� %%F >> %error_log%
    )
)

:: ����ʱ�ļ��н��ļ����������ƻ�ԭĿ¼
for /f "delims=" %%F in ('dir /b /a-d /o:d "%temp_folder%\*.webp"') do (
    call :rename_proc "%%~F"
)

:: ɾ����ʱ�ļ���
if exist "%temp_folder%" rmdir "%temp_folder%"

:: ִ�н������
echo ---------------------------
if exist "%error_log%" (
    echo ������ɣ������ִ�������� %error_log%
    type "%error_log%"
) else (
    echo �����ļ��ѳɹ���������
)
pause
exit

:: ��������������
:rename_proc
set "old_file=%temp_folder%\%~1"

:: ������λ�����
:generate_number
set /a cnt=1000 + counter
set "cnt=!cnt:~1!"
set "new_file=%prefix%-!cnt!.webp"

:: ��ͻ��⣨���⸲�������ļ���
if exist "%new_file%" (
    set /a counter+=1
    goto generate_number
)

:: ִ�����������ƶ�
echo �������������ƶ���"%old_file%" �� %new_file%
move "%old_file%" "%new_file%"

:: ������
if errorlevel 1 (
    echo �������������ƶ�ʧ�� "%old_file%" �� %new_file% >> %error_log%
) else (
    set /a counter+=1
)
goto :eof