#!/bin/bash

export RUN_MODE="$1"

if [ "${RUN_MODE}" = "" ]; then
	echo "Must supply run mode train or serve as \`bin/run.sh train|serve\`"
	exit 1;
fi

DOCKER_NAME='no-op' # will be set correctly by bin/common.sh

. bin/common.sh

PORT_MAP=""

if [ "${RUN_MODE}" = "serve" ]; then
  PORT_MAP="-p 8080:8080 "
fi

ENTRY_POINT=""

if [ "${RUN_MODE}" = "shell" ]; then
  ENTRY_POINT="--entrypoint /bin/bash"
  RUN_MODE=""
fi

docker run $ENTRY_POINT \
  -it \
  --rm \
  $PORT_MAP \
  -v `pwd`:/opt/app \
  -v `pwd`/opt/train:/opt/ml/input/data/train \
  -v `pwd`/opt/model:/opt/ml/model \
  -v `pwd`/opt/output:/opt/ml/output \
  sagemaker-example-tensorflow/$DOCKER_NAME:dev $RUN_MODE
