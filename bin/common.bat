@echo off 

REM This file not meant to be run directly

IF NOT EXIST %CD%\.env.bat (
  ECHO .env file missing. See .env.example for how to create it.
  exit /B 1
)

REM prevent polution between projects if one missing docker config
SET DOCKER_NAME=

call .env.bat

IF "%DOCKER_NAME%"=="" (
	ECHO .env.bat file must set DOCKER_NAME, and the value must be lower case characters, numbers or dashes
	exit /B 1
)