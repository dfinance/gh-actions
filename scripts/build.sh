#!/bin/bash

set -e

### use variables
# GITHUB_REF
# INPUT_NAME
# INPUT_USERNAME
# INPUT_PASSWORD
# INPUT_DOCKERFILE
# INPUT_BUILD_PARAMS


if [ -z "${INPUT_NAME}" ]; then
  echo "Unable to find the repository name. Did you set with.name?"
  exit 1
fi

if [ -z "${INPUT_USERNAME}" ]; then
  echo "Unable to find the username. Did you set with.username?"
  exit 1
fi

if [ -z "${INPUT_PASSWORD}" ]; then
  echo "Unable to find the password. Did you set with.password?"
  exit 1
fi



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

docker login -u ${INPUT_USERNAME} --password-stdin ${INPUT_REGISTRY} <<< ${INPUT_PASSWORD}
docker build ${_build_params} -t ${_docker_name} .
docker push ${_docker_name}
if [[ "${_isMaster}" == "true" || "${_isTag}" == "true" ]]; then
  docker push ${INPUT_NAME}:latest
fi
docker logout
