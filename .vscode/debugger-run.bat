@echo off

set SOLUTION_PATH=%1
set DEBUGGER_IMAGE_NAME=%2
set DEBUGGER_CONTAINER_NAME=%3

set "PID_PATH=%SOLUTION_PATH%\.debugger\pid"
set "PID_FILE_PATH=%PID_PATH%\pid.txt"

setlocal enabledelayedexpansion

:: Initialize result variable
set "ARGS="

:: Coleascece remaining arguments into a single string starting from this position
set i=4
:loop
call set "arg=%%%i%%"
if defined arg (
    set "ARGS=!ARGS! !arg!"
    set /a i+=1
    goto :loop
)

endlocal & set "ARGS=%ARGS%"

docker stop "%DEBUGGER_CONTAINER_NAME%" >nul 2>&1

REM Check if the pid file exists and delete it
if exist "%PID_FILE_PATH%" (
    del /f /q "%PID_FILE_PATH%"
)

REM Check if the pid directory exists and create it if necessary
if not exist "%PID_PATH%" (
    mkdir "%PID_PATH%"
)

docker run --name "%DEBUGGER_CONTAINER_NAME%" ^
    -d --rm ^
    -v "%SOLUTION_PATH%":/src ^
    -v "%PID_PATH%":/pid ^
    --entrypoint "dotnet" "%DEBUGGER_IMAGE_NAME%" ^
    %ARGS%

REM Wait until startup hook creates the pid.txt file
echo Waiting for debuggable process id to be reported...
:wait_for_pid
if exist "%PID_FILE_PATH%" (
    goto pid_file_found
)
REM Wait for 1 second before checking again
timeout /t 1 >nul
goto wait_for_pid

:pid_file_found
set /p PID=<"%PID_FILE_PATH%"

echo Waiting for debugger to attach. Process ID: %PID%
