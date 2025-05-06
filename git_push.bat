@echo off
color 0A
SETLOCAL EnableDelayedExpansion

:MAIN
    REM ���ýű�����
    title Git�Զ��ύ���͹���

    REM ��ȡ��ǰĿ¼��Ϊ�ֿ�·��
    SET "REPO_PATH=%CD%"

    CALL :ValidateRepoAndCommit
    IF ERRORLEVEL 1 (
        goto :EXIT_SCRIPT
    )

    goto :EXIT_SCRIPT
    exit /b 0

:ValidateRepoAndCommit
    REM ���Ŀ��Ŀ¼�Ƿ����
    IF NOT EXIST "%REPO_PATH%" (
        CALL :ShowError "����Ŀ¼ %REPO_PATH% �����ڣ�����·����"
        exit /b 1
    )

    REM �л���Ŀ��Ŀ¼
    CD /D "%REPO_PATH%" 2>NUL
    IF ERRORLEVEL 1 (
        CALL :ShowError "�����޷��л���Ŀ¼ %REPO_PATH%������Ȩ�ޡ�"
        exit /b 1
    )

    REM ����Ƿ�Ϊ��Ч�� Git �ֿ�
    IF NOT EXIST .git (
        CALL :ShowError "���󣺵�ǰĿ¼����һ����Ч�� Git �ֿ⡣"
        exit /b 1
    )

:CheckForChanges
    CALL :ShowMessage "���ڼ�鵱ǰGit�ֿ�״̬..."

    git status >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ShowError "�����޷���ȡGit�ֿ�״̬������Git������"
        exit /b 1
    )

    SET "CHANGES="
    FOR /F "delims=" %%D IN ('git status --porcelain') DO (
        IF "%%D" NEQ "" (
            SET "CHANGES=YES"
        )
    )

    IF DEFINED CHANGES (
        CALL :ShowMessage "��⵽�ļ��޸ģ�׼���ύ..."
        
        REM ��ȡ�û�������ύ��Ϣ
        SET "COMMIT_MSG=�Զ��ύ�� %DATE% %TIME%"
        set /p COMMIT_MSG="�������ύ��Ϣ(ֱ�ӻس�ʹ��Ĭ����Ϣ): "
        IF "!COMMIT_MSG!"=="" (
            SET "COMMIT_MSG=�Զ��ύ�� %DATE% %TIME%"
        )
        
        CALL :AddChanges
        IF ERRORLEVEL 1 (
            exit /b 1
        )
        
        CALL :CommitChanges "!COMMIT_MSG!"
        IF ERRORLEVEL 1 (
            exit /b 1
        )
        
        CALL :PushChanges
        IF ERRORLEVEL 1 (
            exit /b 1
        )
        
        CALL :ShowMessage "�ύ�����ͳɹ���ɣ�"
    ) ELSE (
        CALL :ShowMessage "û�м�⵽�ļ��޸ģ�����ֱ�����͵�Զ�ֿ̲�..."
        CALL :PushChanges
        IF ERRORLEVEL 1 (
            exit /b 1
        )
    )

    CALL :ShowMessage "�ű�ִ����ɡ�"
    exit /b 0

:ShowMessage
    ECHO ============================================
    ECHO ��ǰGit�ֿ⣺%REPO_PATH%
    ECHO ============================================
    ECHO %~1
    ECHO ============================================
    ECHO.
    exit /b 0

:ShowError
    ECHO ============================================
    ECHO %~1
    ECHO ============================================
    exit /b 1

:AddChanges
    CALL :ShowMessage "����������и��ĵ��ݴ���..."
    git add .
    IF ERRORLEVEL 1 (
        CALL :ShowError "�����޷�����ļ����ݴ�����"
        exit /b 1
    )
    exit /b 0

:CommitChanges
    CALL :ShowMessage "�����ύ���ĵ����زֿ�..."
    git commit -m "%~1"
    IF ERRORLEVEL 1 (
        CALL :ShowError "�����ύ�����زֿ�ʧ�ܡ�"
        exit /b 1
    )
    exit /b 0

:PushChanges
    CALL :ShowMessage "�������͸��ĵ�Զ�ֿ̲�..."
    
    REM ��ȡ��ǰ��֧����
    FOR /F "delims=" %%b IN ('git symbolic-ref --short HEAD 2^>nul') DO SET "CURRENT_BRANCH=%%b"
    
    IF DEFINED CURRENT_BRANCH (
        git push origin !CURRENT_BRANCH!
    ) ELSE (
        git push
    )
    
    IF ERRORLEVEL 1 (
        CALL :ShowError "�������͵�Զ�ֿ̲�ʧ�ܣ����������Զ�����á�"
        exit /b 1
    )
    exit /b 0

:EXIT_SCRIPT
    ECHO.
    ECHO ============================================
    ECHO ��������˳�...
    ECHO ============================================
    pause >nul
    exit /b 0