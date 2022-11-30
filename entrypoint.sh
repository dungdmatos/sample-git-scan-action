#!/usr/bin/env bash

if [ ! -z $INPUT_USERNAME ];
then echo $INPUT_PASSWORD | docker login $INPUT_REGISTRY -u $INPUT_USERNAME --password-stdin
fi

if [ ! -z $INPUT_DOCKER_NETWORK ];
then INPUT_OPTIONS="$INPUT_OPTIONS --network $INPUT_DOCKER_NETWORK"
fi
echo "make result dir"
mkdir matos-iac-results-dir
echo "before run: `ls`"
exec docker run -v "/var/run/docker.sock":"/var/run/docker.sock" -v $INPUT_WORKING_DIR:/path cloudmatos/matos-iac-scan:latest scan -p /path/INPUT_SCAN_DIR -o /matos-iac-results-dir
cd matos-iac-results-dir
echo "after run: `ls`"