
set SOLUTION_PATH=%1
set IMAGE_NAME=%3
set CONTAINER_NAME=%4

docker stop "%CONTAINER_NAME%"
docker run --name "%CONTAINER_NAME%" -d --rm -v "%SOLUTION_PATH%":/app "%IMAGE_NAME%"
