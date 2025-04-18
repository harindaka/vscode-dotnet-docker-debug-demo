
set IMAGE_NAME=%1
set CONTAINER_NAME=%2

docker stop "%CONTAINER_NAME%"
docker run --name "%CONTAINER_NAME%" -d --rm "%IMAGE_NAME%"
