@echo off
color 0A
SETLOCAL EnableDelayedExpansion

:MAIN
    REM 设置脚本标题
    title Git自动提交推送工具

    REM 获取当前目录作为仓库路径
    SET "REPO_PATH=%CD%"

    CALL :ValidateRepoAndCommit
    IF ERRORLEVEL 1 (
        goto :EXIT_SCRIPT
    )

    goto :EXIT_SCRIPT
    exit /b 0

:ValidateRepoAndCommit
    REM 检查目标目录是否存在
    IF NOT EXIST "%REPO_PATH%" (
        CALL :ShowError "错误：目录 %REPO_PATH% 不存在，请检查路径！"
        exit /b 1
    )

    REM 切换到目标目录
    CD /D "%REPO_PATH%" 2>NUL
    IF ERRORLEVEL 1 (
        CALL :ShowError "错误：无法切换到目录 %REPO_PATH%，请检查权限。"
        exit /b 1
    )

    REM 检查是否为有效的 Git 仓库
    IF NOT EXIST .git (
        CALL :ShowError "错误：当前目录不是一个有效的 Git 仓库。"
        exit /b 1
    )

:CheckForChanges
    CALL :ShowMessage "正在检查当前Git仓库状态..."

    git status >nul 2>&1
    IF ERRORLEVEL 1 (
        CALL :ShowError "错误：无法获取Git仓库状态，请检查Git环境。"
        exit /b 1
    )

    SET "CHANGES="
    FOR /F "delims=" %%D IN ('git status --porcelain') DO (
        IF "%%D" NEQ "" (
            SET "CHANGES=YES"
        )
    )

    IF DEFINED CHANGES (
        CALL :ShowMessage "检测到文件修改，准备提交..."
        
        REM 获取用户输入的提交信息
        SET "COMMIT_MSG=自动提交于 %DATE% %TIME%"
        set /p COMMIT_MSG="请输入提交信息(直接回车使用默认信息): "
        IF "!COMMIT_MSG!"=="" (
            SET "COMMIT_MSG=自动提交于 %DATE% %TIME%"
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
        
        CALL :ShowMessage "提交和推送成功完成！"
    ) ELSE (
        CALL :ShowMessage "没有检测到文件修改，尝试直接推送到远程仓库..."
        CALL :PushChanges
        IF ERRORLEVEL 1 (
            exit /b 1
        )
    )

    CALL :ShowMessage "脚本执行完成。"
    exit /b 0

:ShowMessage
    ECHO ============================================
    ECHO 当前Git仓库：%REPO_PATH%
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
    CALL :ShowMessage "正在添加所有更改到暂存区..."
    git add .
    IF ERRORLEVEL 1 (
        CALL :ShowError "错误：无法添加文件到暂存区。"
        exit /b 1
    )
    exit /b 0

:CommitChanges
    CALL :ShowMessage "正在提交更改到本地仓库..."
    git commit -m "%~1"
    IF ERRORLEVEL 1 (
        CALL :ShowError "错误：提交到本地仓库失败。"
        exit /b 1
    )
    exit /b 0

:PushChanges
    CALL :ShowMessage "正在推送更改到远程仓库..."
    
    REM 获取当前分支名称
    FOR /F "delims=" %%b IN ('git symbolic-ref --short HEAD 2^>nul') DO SET "CURRENT_BRANCH=%%b"
    
    IF DEFINED CURRENT_BRANCH (
        git push origin !CURRENT_BRANCH!
    ) ELSE (
        git push
    )
    
    IF ERRORLEVEL 1 (
        CALL :ShowError "错误：推送到远程仓库失败，请检查网络或远程配置。"
        exit /b 1
    )
    exit /b 0

:EXIT_SCRIPT
    ECHO.
    ECHO ============================================
    ECHO 按任意键退出...
    ECHO ============================================
    pause >nul
    exit /b 0