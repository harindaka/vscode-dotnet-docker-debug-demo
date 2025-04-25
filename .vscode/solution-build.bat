@echo off

set SOLUTION_PATH=%1
set IMAGE_NAME=%2
set CONTAINER_NAME=%3

docker stop "%CONTAINER_NAME%" >nul 2>&1
docker run --name "%CONTAINER_NAME%" ^
    -it --rm ^
    -v "%SOLUTION_PATH%":/src ^
    -v "%SOLUTION_PATH%/.docker/nuget/packages":/root/.nuget/packages ^
    "%IMAGE_NAME%" ^
    dotnet build -c Debug /src
