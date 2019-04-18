@echo off
setlocal EnableDelayedExpansion

REM source setups
call bin\common.bat

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

REM if any previous images are no longer used, delete them
SET DOCKER_IDS=
FOR /f %%i in ('docker images -q --filter "label=com.sagemaker-example-tensorflow.name=%DOCKER_NAME%"') do SET "DOCKER_IDS=!DOCKER_IDS! %%i"

IF NOT "%DOCKER_IDS%" == "" (
	ECHO Removing Old Docker Images %DOCKER_IDS%
	docker rmi %DOCKER_IDS%
) else (
	ECHO Deleting No Docker Images
)
