#!/bin/bash

# This file not meant to be run directly

if ! [ -f .env ]; then
  echo ".env file missing. See .env.example for how to create it."
  exit 1;
fi

. .env

if ! [[ $DOCKER_NAME =~ ^[a-z0-9\-]+$ ]]; then
  echo ".env file must export DOCKER_NAME, and the value must be lower case characters, numbers or dashes"
  exit 1;
fi