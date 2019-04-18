#!/bin/bash

DOCKER_NAME='no-op' # will be set correctly by bin/common.sh

. bin/common.sh

RUNNING_CONTAINER_IDS=$(docker ps -qa --filter label=com.sagemaker-example-tensorflow.name=$DOCKER_NAME)
if ! [[ -z "${RUNNING_CONTAINER_IDS// }" ]]; then
  echo Stopping Docker Containers $RUNNING_CONTAINER_IDS
  docker stop $RUNNING_CONTAINER_IDS;
else
  echo Stopping No Docker Containers
fi

STOPPED_CONTAINER_IDS=$(docker ps -qa --filter label=com.sagemaker-example-tensorflow.name=$DOCKER_NAME)
if ! [[ -z "${STOPPED_CONTAINER_IDS// }" ]]; then
  echo Removing Docker Containers $STOPPED_CONTAINER_IDS
  docker rm $STOPPED_CONTAINER_IDS;
else
  echo Deleting No Docker Containers
fi

IMAGE_IDS=$(docker images -q --filter label=com.sagemaker-example-tensorflow.name=$DOCKER_NAME)
if ! [[ -z "${IMAGE_IDS// }" ]]; then
  echo Removing Docker Images $IMAGE_IDS
  docker rmi $IMAGE_IDS;
else
  echo Deleting No Docker Images
fi
