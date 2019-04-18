@echo off
setlocal EnableDelayedExpansion

REM source setups
call bin\common.bat

REM ensure the needed state directories exist to simulate AWS SageMaker docker environment
IF NOT EXIST opt\train mkdir opt\train
IF NOT EXIST opt\model mkdir opt\model
IF NOT EXIST opt\output mkdir opt\output

REM stop any running containers
SET DOCKER_IDS=
FOR /f %%i in ('docker ps -qa --filter "label=com.sagemaker-example-tensorflow.name=%DOCKER_NAME%"') do SET "DOCKER_IDS=!DOCKER_IDS! %%i"

IF NOT "%DOCKER_IDS%" == "" (
	ECHO Stopping Docker Containers %DOCKER_IDS%
	docker stop %DOCKER_IDS%
) else (
	ECHO Stopping No Docker Containers
)

REM if any previous containrs are present, delete them
SET DOCKER_IDS=
FOR /f %%i in ('docker ps -qa --filter "label=com.sagemaker-example-tensorflow.name=%DOCKER_NAME%"') do SET "DOCKER_IDS=!DOCKER_IDS! %%i"

IF NOT "%DOCKER_IDS%" == "" (
	ECHO Removing Old Docker Containers %DOCKER_IDS%
	docker rm %DOCKER_IDS%
) else (
	ECHO Deleting No Docker Containers
)

REM this is the same build that would be used to deploy to production
docker build --label com.sagemaker-example-tensorflow.name=%DOCKER_NAME% --tag sagemaker-example-tensorflow/%DOCKER_NAME%:dev-base --compress -f Dockerfile .

REM this is a secondary image that simulates the AWS SageMaker sidecars that inject S3 data points into the running container
docker build --label com.sagemaker-example-tensorflow.name=%DOCKER_NAME% --tag sagemaker-example-tensorflow/%DOCKER_NAME%:dev --compress -f Dockerfile.develop --build-arg MY_BASE_IMAGE=sagemaker-example-tensorflow/%DOCKER_NAME%:dev-base .

REM if any previous images are no longer used, delete them
SET DOCKER_IDS=
FOR /f %%i in ('docker images -q --filter "dangling=true" --filter "label=com.sagemaker-example-tensorflow.name=%DOCKER_NAME%"') do SET "DOCKER_IDS=!DOCKER_IDS! %%i"

IF NOT "%DOCKER_IDS%" == "" (
	ECHO Removing Old Docker Images %DOCKER_IDS%
	docker rmi %DOCKER_IDS%
) else (
	ECHO Deleting No Docker Images
)
