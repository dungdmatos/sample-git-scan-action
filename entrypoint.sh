#!/bin/bash

if [ ! -z $INPUT_USERNAME ];
then echo $INPUT_PASSWORD | docker login $INPUT_REGISTRY -u $INPUT_USERNAME --password-stdin
fi

if [ ! -z $INPUT_DOCKER_NETWORK ];
then INPUT_OPTIONS="$INPUT_OPTIONS --network $INPUT_DOCKER_NETWORK"
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
# exec docker run -v "/var/run/docker.sock":"/var/run/docker.sock" -v $(pwd):/path cloudmatos/matos-iac-scan:latest scan -p /path/$INPUT_SCAN_DIR -o /path/matos-iac-results-dir
# docker run --rm -v $(pwd):/usr/src/project cloudmatos/matos-iac-scan:latest scan -p /usr/src/project/templates -o /usr/src/project/matos-iac-results-dir

/app/bin/kics scan $INPUT_PARAM $OUTPUT_PATH_PARAM

cp -r "${CP_PATH}" "/app/"
cd /app
echo "before run: `ls`"
# install and run nodejs
apk update && \
    apk upgrade && \
    apk add jq && apk add curl

jq -nc --argfile results "results.json" --arg git_url "$GIT_URL" '{$results,$git_url}' |
    curl -i \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X POST -d @- "https://console.cloudmatos.dev/app/iac-scan/store"