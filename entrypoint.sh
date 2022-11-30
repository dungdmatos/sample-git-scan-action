#!/bin/bash

if [ ! -z $INPUT_USERNAME ];
then echo $INPUT_PASSWORD | docker login $INPUT_REGISTRY -u $INPUT_USERNAME --password-stdin
fi

if [ ! -z $INPUT_DOCKER_NETWORK ];
then INPUT_OPTIONS="$INPUT_OPTIONS --network $INPUT_DOCKER_NETWORK"
fi
echo "make result dir"
mkdir matos-iac-results-dir
echo "before run: `ls`"
echo "git repo: $INPUT_WORKING_DIR"
# exec docker run -v "/var/run/docker.sock":"/var/run/docker.sock" -v $(pwd):/path cloudmatos/matos-iac-scan:latest scan -p /path/$INPUT_SCAN_DIR -o /path/matos-iac-results-dir
docker run --rm -v $(pwd):/usr/src/project cloudmatos/matos-iac-scan:latest scan -p /usr/src/project/$INPUT_SCAN_DIR -o /usr/src/project/matos-iac-results-dir
cd matos-iac-results-dir
echo "after run: `ls`"
echo "post scan result"
jq -nc --argfile results "matos-iac-results-dir/results.json" --arg git_url "$GIT_URL" '{$results,$git_url}' |
    curl -i \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X POST -d @- "https://console.cloudmatos.dev/app/iac-scan/store"