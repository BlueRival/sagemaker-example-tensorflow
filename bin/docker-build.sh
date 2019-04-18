#!/bin/bash

DOCKER_NAME='no-op' # will be set correctly by bin/common.sh

. bin/common.sh

# ensure the needed state directories exist to simulate AWS SageMaker docker environment
mkdir -p opt/train
mkdir -p opt/model
mkdir -p opt/output

# this is the same build that would be used to deploy to production
docker build --label com.sagemaker-example-tensorflow.name=$DOCKER_NAME --tag sagemaker-example-tensorflow/$DOCKER_NAME:dev-base --compress -f Dockerfile .

# this is a secondary image that simulates the AWS SageMaker sidecars that inject S3 data points into the running container
docker build --label com.sagemaker-example-tensorflow.name=$DOCKER_NAME --tag sagemaker-example-tensorflow/$DOCKER_NAME:dev --compress -f Dockerfile.develop --build-arg MY_BASE_IMAGE=sagemaker-example-tensorflow/$DOCKER_NAME:dev-base .

# if we modified the docker files, it is possible we left dangling images. remove them
IMAGE_IDS=$(docker images -q --filter "dangling=true" --filter label=com.sagemaker-example-tensorflow.name=$DOCKER_NAME)
if ! [[ -z "${IMAGE_IDS// }" ]]; then
  echo Removing Old Docker Images $IMAGE_IDS
  docker rmi $IMAGE_IDS;
else
  echo Deleting No Old Docker Images
fi
