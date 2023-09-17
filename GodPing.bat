@echo off
setlocal enabledelayedexpansion

@REM define ESC
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

@REM define servers ip
set GP_1=ir.i.de1.godping.ir
set GP_2=ir.i.de2.godping.ir
set GP_3=ir.i.de3.godping.ir
set GP_4=ir.i.nl1.godping.ir
set GP_5=ir.i.tr1.godping.ir
set GP_6=ir.i.tr2.godping.ir

@REM define calc range
set /a "this_ping=0"
set /a "prev_ping=2147483647"

@REM main script
cls
echo  -----------------------------
call :get %GP_1% 1
call :get %GP_2% 2
call :get %GP_3% 3
call :get %GP_4% 4
call :get %GP_5% 5
call :get %GP_6% 6
@REM del .\temp
call :calc
call :match !min_avg:~4!
echo:
echo:
pause >nul | set /p="Fastest server is !ESC![4m!server!!ESC![0m | %min_ping%ms"
echo:
endlocal
exit /b 0

@REM get ping -function-
:get
REM set a default value for 'avg' and 'counterID':
set "avg= ---"
set "c=%2"
REM do the ping one time...:
>temp ping %1 -w 2000 -n 4 -4
REM ... and process the output several times to collect the data:
for /f "tokens=4 delims==" %%a in ('find "ms, " temp') do set "avg=%%a"
echo ^| %1 ^| %avg:~1%   ^|
echo  -----------------------------
if not "%avg%"==" ---" (
    set "avg_!c!=%avg:~1,1%"
) else (
    set "avg_!c!=2147483647"
)

@REM get lowest ping value -function-
:calc
for /f "usebackq tokens=1* delims==" %%a in (`set avg_`) do (
    set /a "this_ping=%%b"
    if !this_ping! lss !prev_ping! (
        set "min_avg=%%a"
        set "min_ping=%%b"
        set /a "prev_ping=%%b"
    )
)

@REM get fastest server name -function-
:match
for /f "usebackq tokens=1* delims==" %%a in (`set GP_`) do (
    set "server_name=%%a"
    if "%1"=="!server_name:~3!" (
        set "server=%%b"
        set "server=!server:~5,3!"
        @for /f "usebackq delims=" %%I in (`powershell "\"!server!\".toUpper()"`) do @set "server=%%~I"
    )
)