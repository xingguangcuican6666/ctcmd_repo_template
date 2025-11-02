@echo off
set now_work="%cd%"
cd /d %~dp0
git pull -v
cd /d %now_work%
setlocal enabledelayedexpansion
call %HOME%\config.bat
if "%~4"=="" (
    echo Usage: upload.bat [file] [name] [arch] [last_will_change_version]
    exit /b 1
)
set "HOME=%~dp0"
set "name=%2"
@REM echo Name: %name%
@REM goto 1
set "arch=%3"
set "version=%4"
set found=0
for /f "tokens=* delims=" %%a in ('type "%HOME%\all.ctcmd"') do (
    set "line=%%a"
    if not "!line!"=="" if not "!line:~0,2!"=="//" (
        for /f "tokens=1,2 delims=@" %%b in ("!line!") do (
            @REM echo 处理行: !line!
            @REM echo @前部分: %%b
            @REM echo @后部分: %%c
            @REM echo.
            if "%name%"=="%%b" (
                echo Found matching name: %%b
                set found=1
            )
        )
    )
)
:skip
if "%found%"=="0" (
    echo %name%@%repo%/refs/heads/main/%name%>>"%HOME%\all.ctcmd"    
)
mkdir "%HOME%%name%"
move /y "%HOME%%name%\%name%_%arch%_latest.zip" "%HOME%%name%\%name%_%arch%_%version%.zip"
copy /y %1 "%HOME%%name%\%name%_%arch%_latest.zip"
cd /d %HOME%


REM 以下为移除 all.ctcmd 每行末尾空格的整合代码
set "tmpfile=%HOME%\all.ctcmd.trimmed"
break > "%tmpfile%"
for /f "usebackq delims=" %%a in ("%HOME%\all.ctcmd") do (
    set "line=%%a"
    REM 移除行尾空格
    for /f "tokens=* delims=" %%b in ("!line!") do (
        set "line=%%b"
        setlocal enabledelayedexpansion
        set "line=!line!"
        for /f "tokens=* delims=" %%c in ("!line!") do (
            set "line=%%c"
            REM 逐字符从右向左移除空格
            :trimloop
            if "!line!"=="" goto trimdone
            set "lastchar=!line:~-1!"
            if "!lastchar!"==" " (
                set "line=!line:~0,-1!"
                goto trimloop
            )
            :trimdone
            echo !line!>>"%tmpfile%"
        )
        endlocal
    )
)
copy /Y "%tmpfile%" "%HOME%\all.ctcmd"

git config --global user.email %git_username%
git config --global user.name %git_email%
git add . -v
git commit -m "upload" -v
git push -v
:1
cd /d %now_work%
endlocal