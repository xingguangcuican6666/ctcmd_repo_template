@echo on
REM 用法：ctcmd_trim_space.bat 文件名
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo 请提供要处理的文件名
    exit /b 1
)

set "infile=%~1"
set "outfile=%infile%.trimmed"

(for /f "usebackq delims=" %%a in ("%infile%") do (
    set "line=%%a"
    set "line=!line: =!"
    for /f "tokens=* delims= " %%b in ("!line!") do (
        set "line=%%a"
        REM 移除行尾空格
        for /f "tokens=* delims=" %%c in ("!line!") do (
            set "line=%%c"
            setlocal enabledelayedexpansion
            set "line=!line!"
            for /f "tokens=* delims=" %%d in ("!line!") do (
                set "line=%%d"
                REM 下面这行移除行尾空格
                set "line=!line!"
                set "line=!line: =!"
                echo !line!
            )
            endlocal
        )
    )
)) > "%outfile%"

echo 已处理完毕，结果文件：%outfile%