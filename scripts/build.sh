#!/bin/bash

set -e

### use variables
# GITHUB_REF
# INPUT_NAME
# INPUT_USERNAME
# INPUT_PASSWORD
# INPUT_REGISTRY
# INPUT_DOCKERFILE
# INPUT_BUILD_PARAMS
# INPUT_CACHE
# INPUT_DEBUG
# INPUT_DOCKER_CONTEXT

function iprintf {
  echo -e "\033[0;32m$(date +"%Y.%m.%d %H:%M:%S")\t$@\033[0m"
}
function eprintf {
  echo -e "\033[0;31m$(date +"%Y.%m.%d %H:%M:%S")\t$@\033[0m"
  exit 1
}

INPUT_DOCKER_CONTEXT=${INPUT_DOCKER_CONTEXT:-.}
[[ -z "${INPUT_NAME}" ]]      && eprintf "Unable to find the repository name. Did you set with.name?"
[[ -z "${INPUT_USERNAME}" ]]  && eprintf "Unable to find the username. Did you set with.username?"
[[ -z "${INPUT_PASSWORD}" ]]  && eprintf "Unable to find the password. Did you set with.password?"


_branch=$(sed -e 's/refs\/tags\///g; s/refs\/heads\///g;' <<< ${GITHUB_REF})
_docker_name="${INPUT_NAME}:${_branch}"
_build_params="${INPUT_BUILD_PARAMS}"

if [ "${_branch}" == "master" ]; then
  _build_params="$_build_params -t ${INPUT_NAME}:latest"
  _isMaster=true
fi;
# if contains /refs/tags/
if [ $(sed -e 's/refs\/tags\///g' <<< ${GITHUB_REF}) != ${GITHUB_REF} ]; then
  _build_params="$_build_params -t ${INPUT_NAME}:latest"
  _isTag=true
fi
if [ ! -z "${INPUT_DOCKERFILE}" ]; then
  _build_params="$_build_params -f ${INPUT_DOCKERFILE}"
fi


iprintf "Docker login"
docker login -u ${INPUT_USERNAME} --password-stdin ${INPUT_REGISTRY} <<< ${INPUT_PASSWORD}

[[ "${INPUT_DEBUG}" == 'true' ]] && set -x
if [ ! -z "${INPUT_CACHE}" ]; then
  iprintf "Pull docker cache: ${_docker_name}"
  docker pull ${_docker_name}
  _build_params="$_build_params --cache-from ${_docker_name}"
fi

iprintf "Start docker build"
docker build ${_build_params} -t ${_docker_name} ${INPUT_DOCKER_CONTEXT}

iprintf "Push docker image: ${_docker_name}"
docker push ${_docker_name}

if [[ "${_isMaster}" == "true" || "${_isTag}" == "true" ]]; then
  iprintf "Push docker image: ${INPUT_NAME}:latest"
  docker push ${INPUT_NAME}:latest
fi
[[ "${INPUT_DEBUG}" == 'true' ]] && set +x

iprintf "Docker logout"
docker logout
