
set SOLUTION_PATH=%1
set DEBUGGER_IMAGE_NAME=%2
set DEBUGGER_CONTAINER_NAME=%3

@echo off
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

@echo on

docker stop "%DEBUGGER_CONTAINER_NAME%"
docker run --name "%DEBUGGER_CONTAINER_NAME%" ^
    -d --rm ^
    -v "%SOLUTION_PATH%":/src ^
    --entrypoint "dotnet" "%DEBUGGER_IMAGE_NAME%" ^
    %ARGS%
