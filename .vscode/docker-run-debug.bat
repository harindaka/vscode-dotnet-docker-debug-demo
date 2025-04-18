
set SOLUTION_PATH=%1
set REL_STARTUP_HOOKS_PATH=%2
set IMAGE_NAME=%3
set CONTAINER_NAME=%4

docker build --build-arg ARG_REL_STARTUP_HOOKS_PATH="%REL_STARTUP_HOOKS_PATH%" -t "%IMAGE_NAME%" "%SOLUTION_PATH%"
docker stop "%CONTAINER_NAME%"
docker run --name "%CONTAINER_NAME%" -d --rm -v "%SOLUTION_PATH%":/src "%IMAGE_NAME%"
