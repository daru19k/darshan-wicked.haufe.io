#!/bin/bash

set -e

this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

pushd ${this_dir}

branch=$(git rev-parse --abbrev-ref HEAD)
echo ${branch} > ./env/git_branch
git rev-parse --abbrev-ref HEAD > ./env/git_last_commit

echo "======================================================"
echo "BUILDING BRANCH ${branch}"
echo "======================================================"
echo ""

export TAG=${branch}
if [ ! -z "${DOCKER_TAG}" ]; then
    echo "INFO: Using tag ${DOCKER_TAG} instead of branch ${branch}"
    export TAG=${DOCKER_TAG}
fi

(
    source .env
    docker pull ${BASE_IMAGE_ALPINE}
    docker pull ${BASE_IMAGE_UBUNTU}
)

docker-compose --file=docker-compose.build.yml build --parallel node-sdk kong k8s-tool
docker-compose --file=docker-compose.build.yml build --parallel env env-alpine k8s-init
docker-compose --file=docker-compose.build.yml build --parallel

echo "======================================================"
echo "FINISHED BUILDING BRANCH ${branch}"
echo "======================================================"

popd
