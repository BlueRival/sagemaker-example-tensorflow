@echo off

SET RUN_MODE=%1

IF "%RUN_MODE%"=="" (
	echo Must supply run mode train or serve as bin\run.bat train or serve
	exit /B 1
)

REM will be set correctly by bin\common.bat
SET DOCKER_NAME=

REM source setup
call bin\common.bat

REM default port map
SET PORT_MAP=

REM will need to map port for serve 
IF "%RUN_MODE%"=="serve" (
  SET PORT_MAP=-p 8080:8080 
)

docker run -it --rm %PORT_MAP% -v "%CD%:/opt/app" -v "%CD%/opt/train:/opt/ml/input/data/train" -v "%CD%/opt/model:/opt/ml/model" -v "%CD%/opt/output:/opt/ml/output" sagemaker-example-tensorflow/%DOCKER_NAME%:dev %RUN_MODE%
