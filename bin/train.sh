#!/bin/bash

rm -rf opt/model/*
touch opt/model/.gitignore
/bin/bash bin/run.sh train
