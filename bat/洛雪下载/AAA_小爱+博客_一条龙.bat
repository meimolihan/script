@echo off
setlocal enabledelayedexpansion

REM 设置颜色为绿色背景，默认亮白色文字
COLOR 0A
CLS
PROMPT $P$G
echo =============================================================
echo 【小爱+博客 一条龙】正在处理小爱音乐：去除歌曲名中的空格...
echo =============================================================
	
rem ========================= （1）歌曲名去除空格 ============================
for %%F in (*) do (
   set "file=%%F"
   set "newFile=!file: =!"
   ren "!file!" "!newFile!"
)

echo ===========================================
echo 文件名中的空格已全部移除！
echo ===========================================
echo.
echo ===========================================
echo 2秒后，音频提取封面...
choice /n /c y /t 2 /d y >nul
goto music_bbb

rem ========================= （2）音频提取封面 ============================
:music_bbb
CLS
color 0A
setlocal
echo =============================================================
echo 【小爱+博客 一条龙】正在处理小爱音乐：提取音频中的封面...
echo =============================================================

cd /d "%~dp0"

rem 初始化计数器
set mp3_count=0

rem 统计当前目录下的MP3文件数量
for %%F in (*.mp3) do (
    set /a mp3_count+=1
)

rem 如果没有MP3文件，显示提示信息并退出
if %mp3_count% == 0 (
    echo.
    echo ===========================================
    echo 当前目录中没有找到MP3文件！
    echo ===========================================
    echo 2秒后返回主菜单...
    choice /n /c y /t 2 /d y >nul
    goto music_ccc
)

rem 遍历当前目录下所有的MP3文件
for %%F in (*.mp3) do (
    call :main "%%F"
)

:main
ffmpeg -i "%~1" "%~n1".jpg -y

echo.
echo ===========================================
echo 歌曲封面已提取完成！
echo ===========================================
echo.
echo ===========================================
echo 2秒后，复制音乐到小爱音乐目录...
choice /n /c y /t 2 /d y >nul
goto music_ccc


rem ========================= （3）复制音乐到小爱 ============================
:music_ccc
CLS
color 0A
setlocal
echo =============================================================
echo 【小爱+博客 一条龙】正在处理小爱音乐：复制音乐到小爱音乐目录...
echo =============================================================

:: 设置目标目录
set "target_dir=Y:\music"

:: 创建目标目录（如果不存在）
if not exist "%target_dir%" (
    mkdir "%target_dir%"
)

:: 用于记录是否找到指定类型的文件
set "found_files=0"

:: 遍历当前目录（不包含子文件夹）下的指定类型文件
for %%F in (*.mp3 *.lrc *.jpg) do (
    :: 复制文件到目标目录
    echo 正在复制: "%%F"
    copy /y "%%F" "%target_dir%\" >nul
    :: 找到文件，设置标志为 1
    set "found_files=1"
)

:: 判断是否找到文件
if "%found_files%"=="0" (
    echo.
    echo ===========================================
    echo 没有找到指定类型（*.mp3、*.lrc、*.jpg）的文件。
    echo ===========================================
) else (
    echo.
    echo ===========================================
    echo 所有文件已复制到 %target_dir%
    echo ===========================================
)

echo.
echo ===========================================
echo 共复制了 %file_count% 个文件到 %target_dir%
echo ===========================================
echo.
echo ===========================================
echo 2秒后，歌曲放入同名目录...
choice /n /c y /t 2 /d y >nul
goto music_ddd

rem ========================= （4）歌曲放入同名目录 ============================
:music_ddd
CLS
color 0A
setlocal
echo =============================================================
echo 【小爱+博客 一条龙】正在处理博客音乐：歌曲放入同名目录中...
echo =============================================================

rem 获取当前目录路径
set "current_dir=%cd%"

rem 遍历当前目录下的文件
for %%a in ("%current_dir%\*.*") do (
  rem 判断是否为.bat文件，不是则进行移动操作
  if not "%%~xa"==".bat" (
    rem 获取文件名（不包括扩展名）
    set "filename=%%~na"
    rem 创建新文件夹
    md "!filename!" 2>nul
    rem 移动文件到新文件夹中
    move "%%a" "!filename!" >nul
  )
)

rem ======= 修改目录中歌曲名 ========
rem 遍历当前目录及其子目录下的所有文件
for /r %%a in (*) do (
    set "filepath=%%~dpa"
    set "file=%%~nxa"
    set "ext=%%~xa"
    if "!ext!"==".mp3" (
        if not "!file!"=="song.mp3" (
            if not exist "!filepath!song.mp3" (
                move "%%a" "!filepath!song.mp3" >nul 2>&1
            ) else (
                echo 子目录!filepath! 中存在同名的 song.mp3 文件，无法将 %%a 重命名为 song.mp3
            )
        )
    ) else if "!ext!"==".jpg" (
        if not "!file!"=="cover.jpg" (
            if not exist "!filepath!cover.jpg" (
                move "%%a" "!filepath!cover.jpg" >nul 2>&1
            ) else (
                echo 子目录!filepath! 中存在同名的 cover.jpg 文件，无法将 %%a 重命名为 cover.jpg
            )
        )
    ) else if "!ext!"==".lrc" (
        if not "!file!"=="lyric.lrc" (
            if not exist "!filepath!lyric.lrc" (
                move "%%a" "!filepath!lyric.lrc" >nul 2>&1
            ) else (
                echo 子目录!filepath! 中存在同名的 lyric.lrc 文件，无法将 %%a 重命名为 lyric.lrc
            )
        )
    )
)

echo.
echo ===========================================
echo 歌曲放入同名目录已完成！
echo ===========================================
echo.
echo ===========================================
echo 2秒后，复制代码到剪切板...
choice /n /c y /t 2 /d y >nul
goto music_eee

rem ========================= （5）复制代码到剪切板 ============================
:music_eee
CLS
color 0A
setlocal
echo =============================================================
echo 【小爱+博客 一条龙】正在处理博客音乐：复制代码到剪切板...
echo =============================================================
rem 定义一个变量来存储内容
set "list="

rem 遍历当前目录下的所有子文件夹，排除指定的文件夹
for /d %%D in (*) do (
    if /i not "%%D"=="Hugo歌曲代码生成" if /i not "%%D"=="Typecho歌曲代码生成" (
        set "list=!list!     '%%D',"
    )
)

rem 将内容复制到剪贴板
echo !list!|clip

echo.
echo ===========================================
echo 内容已复制到剪贴板，按任意键打开Hexo配置文件。
echo ===========================================
pause

rem ======= 打开Hexo配置文件 ======
   start notepad "%USERPROFILE%\Desktop\GitHub\hexo\themes\butterfly\layout\includes\head.pug"

echo.
echo ===========================================
echo   Hexo配置文件已打开！
echo ===========================================
echo.
echo ===========================================
echo 2秒后，复制音乐至仓库...
choice /n /c y /t 2 /d y >nul
goto music_fff

rem ========================= （5）复制音乐至music仓库 ============================
:music_fff
CLS
color 0A
setlocal
echo =============================================================
echo 【小爱+博客 一条龙】正在处理博客音乐：复制音乐至music仓库...
echo =============================================================

:: 设置源目录和目标目录
set "source_dir=."
set "target_dir=%USERPROFILE%\Desktop\GitHub\music"

:: 创建目标目录（如果不存在）
if not exist "%target_dir%" (
    mkdir "%target_dir%"
)

:: 遍历源目录下的所有文件夹
for /d %%F in ("%source_dir%\*") do (
    :: 检查当前文件夹中是否包含.mp3文件
    dir /b "%%F\*.mp3" >nul 2>&1
    if not errorlevel 1 (
        :: 如果包含.mp3文件，则复制整个文件夹
        echo ===========================================
        echo 正在复制包含MP3的文件夹: "%%F"
        echo ===========================================
        xcopy /E /I /Y "%%F" "%target_dir%\%%~nxF"
        echo ===========================================
    )
)

echo.
echo ===========================================
echo   歌曲已复制到music仓库！
echo ===========================================
echo.
echo ===========================================
echo 2秒后，推送music仓库更新...
choice /n /c y /t 2 /d y >nul
goto music_ggg

rem ========================= （6）推送music仓库更新 ============================
:music_ggg
CLS
color 0A
setlocal
echo =============================================================
echo 【小爱+博客 一条龙】正在处理博客音乐：推送music仓库更新...
echo =============================================================

REM 设置 Git 仓库路径
SET REPO_PATH=%USERPROFILE%\Desktop\GitHub\music

REM 切换到指定的 Git 仓库目录
CD /D %REPO_PATH%

REM 检查是否成功切换到仓库目录
IF NOT EXIST .git (
    echo ===========================================
    echo 错误：目录 %REPO_PATH% 不是一个有效的 Git 仓库。
    echo ===========================================
    pause
    EXIT /B 1
)

REM 添加所有更改并提交
echo ===========================================
echo 正在添加所有更改...
git add .
echo ===========================================
echo 正在提交更改，提交信息为 "update"...
git commit -m "update"
echo ===========================================

REM 推送提交到远程仓库
echo 正在将提交推送到远程仓库...
git push
echo ===========================================

REM 删除本地标签 v1.0.0
echo 正在删除本地标签 v1.0.0...
git tag -d v1.0.0
echo ===========================================

REM 删除远程标签 v1.0.0
echo 正在删除远程标签 v1.0.0...
git push origin :refs/tags/v1.0.0
echo ===========================================

REM 检查标签是否删除成功
echo 检查标签 v1.0.0 是否删除成功...
git tag -l | findstr /I "v1.0.0" >nul
IF %ERRORLEVEL% EQU 0 (
    echo 远程标签 v1.0.0 删除失败，请手动检查。
) ELSE (
    echo 远程标签 v1.0.0 删除成功。
)
echo ===========================================

REM 创建新标签 v1.0.0
echo 正在创建新标签 v1.0.0，标签信息为 "为最新提交的重新创建标签"...
git tag -a v1.0.0 -m "Recreate tags for the latest submission"
echo ===========================================

REM 推送新标签到远程仓库
echo 正在将新的标签 v1.0.0 推送到远程仓库...
git push origin v1.0.0
echo ===========================================

REM 检查标签是否推送成功
echo 检查标签 v1.0.0 是否推送成功...
git tag -l | findstr /I "v1.0.0" >nul
IF %ERRORLEVEL% EQU 0 (
    echo 标签 v1.0.0 推送成功。
) ELSE (
    echo 标签 v1.0.0 推送失败，请手动检查。
)
echo ===========================================
echo.
echo ===========================================
echo   推送music仓库更新，已完成。
echo ===========================================
echo.
echo ===========================================
echo 2秒后，推送 Hexo 更新...
choice /n /c y /t 2 /d y >nul
goto music_hhh

rem ========================= （7）部署 Hexo 博客 ============================
:music_hhh
CLS
color 0A
setlocal
echo =============================================================
echo 【小爱+博客 一条龙】正在处理博客音乐：部署 Hexo 博客...
echo =============================================================

set "baseDir=%USERPROFILE%\Desktop\GitHub"
set "hexoDir=%baseDir%\hexo"

echo 正在检查目录 %hexoDir% 是否存在...

if not exist "%hexoDir%" (
    echo 错误：目录 %hexoDir% 不存在！
    goto :END
)

echo 切换到目录 %hexoDir%
cd /d "%hexoDir%"

echo 执行 hexo cl...
call hexo cl
if errorlevel 1 goto :ERROR

echo 执行 hexo g...
call hexo g
if errorlevel 1 goto :ERROR

echo 执行 hexo d...
call hexo d
if errorlevel 1 goto :ERROR

echo Hexo 部署成功！
goto :END

:ERROR
echo Hexo 部署过程中发生错误！

:END
echo.
echo ===========================================
echo   推送 Hexo 更新，已完成。
echo ===========================================
pause
goto exit_script




rem ===========================================================================
:exit_script
cls
echo.
echo.
echo ==============================
echo         感谢使用，再见！
echo ==============================
timeout /t 2 >nul
exit
rem ===========================================================================