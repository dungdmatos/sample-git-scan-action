#!/bin/bash

if [ ! -z $INPUT_USERNAME ];
then echo $INPUT_PASSWORD | docker login $INPUT_REGISTRY -u $INPUT_USERNAME --password-stdin
fi

if [ ! -z $INPUT_DOCKER_NETWORK ];
then INPUT_OPTIONS="$INPUT_OPTIONS --network $INPUT_DOCKER_NETWORK"
fi

if [ -z "$INPUT_API_KEY" ]; then
    echo "${DATETIME} - ERR input api key can't be empty"
    exit 1
fi

if [ -z "$INPUT_SCAN_DIR" ]; then
    echo "${DATETIME} - ERR input path can't be empty"
    exit 1
else
    INPUT_PARAM="-p $INPUT_SCAN_DIR"
fi

CP_PATH="./results.json"
OUTPUT_PATH_PARAM="-o ./"
cd $GITHUB_WORKSPACE
/app/bin/kics scan --no-progress $INPUT_PARAM $OUTPUT_PATH_PARAM

cp -r "${CP_PATH}" "/app/"
cd /app
# echo "before run: `ls`"
# install and run nodejs
apk update && \
    apk upgrade && \
    apk add jq && apk add curl

jq -nc --argfile results "results.json" --arg git_url "$GIT_URL_INPUT" '{$results,$git_url}' |
    curl -i \
    -H "Accept: application/json" \
    -H "X-Api-Key: $INPUT_API_KEY" \
    -H "Content-Type:application/json" \
    -X POST -d @- "https://2281-171-240-138-201.ngrok.io/app/iac-scan/store"