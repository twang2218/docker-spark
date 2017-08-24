#!/bin/bash

DOCKER_USERNAME=${DOCKER_USERNAME:-twang2218}
IMAGE_NAME=${IMAGE_NAME:-${DOCKER_USERNAME}/spark}
IMAGE_TAG=${IMAGE_TAG:-latest}

SPARK_VERSION=2.2.0
HADOOP_VERSION=2.7

VARIATION="generic scala R python"

function generate_dockerfile() {
  local dep=$1
  local spark_version=$2
  local hadoop_version=$3
  local cmd=$4
  local file=$5

  mkdir -p `dirname $file`
  cat ./template/Dockerfile | sed \
    -e "s/#DEPS#/$dep/g" \
    -e "s/#SPARK_VERSION#/$spark_version/g" \
    -e "s/#HADOOP_VERSION#/$hadoop_version/g" \
    -e "s/#CMD#/$cmd/g" \
    > $file
}

function generate() {
  generate_dockerfile "" $SPARK_VERSION $HADOOP_VERSION spark-shell scala/Dockerfile
  generate_dockerfile "R" $SPARK_VERSION $HADOOP_VERSION sparkR R/Dockerfile
  generate_dockerfile "python" $SPARK_VERSION $HADOOP_VERSION pyspark python/Dockerfile
  generate_dockerfile "R python" $SPARK_VERSION $HADOOP_VERSION bash generic/Dockerfile
}

function build() {
  generate
  for t in $VARIATION; do
    docker build -t ${IMAGE_NAME}:${t} ${t}
  done
}

function run() {
  local version=${1:-$IMAGE_TAG}
  shift
  docker run -it --rm -p 7077:7077 -p 8080:8080 ${IMAGE_NAME}:${version} "$@"
}

function release() {
  for tag in $VARIATION; do
    docker push ${IMAGE_NAME}:${tag}
  done
}

function trigger_build() {
  local tag=$1
  if [ -n "$DOCKER_TRIGGER_TOKEN" ]; then
    curl --silent \
      --header "Content-Type: application/json" \
      --request POST \
      --data "{\"docker_tag\": \"$tag\"}" \
      https://registry.hub.docker.com/u/${IMAGE_NAME}/trigger/${DOCKER_TRIGGER_TOKEN}
    echo -e "\ndone."
  else
    echo -e "\nDOCKER_TRIGGER_TOKEN is empty"
  fi
}

function ci() {
  if [[ -n "${DOCKER_PASSWORD}" ]]; then
    docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
  else
    echo "Cannot login to Docker Hub (DOCKER_PASSWORD is empty)"
    return 1
  fi

  # We just trigger the `base` build to refresh the README on the Hub
  trigger_build scala

  if [ "$1" == "--force" ]; then
    # build all no matter it's changed or not
    build
    release
  else
    for tag in $VARIATION; do
      if (git show --pretty="" --name-only | grep Dockerfile | grep -q $tag); then
        echo "$tag has been updated, rebuilding ${IMAGE_NAME}:$tag ..."
        docker build -t ${IMAGE_NAME}:${tag} ${tag}
        echo "Publish image '${IMAGE_NAME}:${tag}' to Docker Hub ..."
        docker push ${IMAGE_NAME}:${tag}
      else
        echo "Nothing changed in $tag."
      fi
    done
  fi

  # List all the images
  docker images
}

function main() {
  local command=$1
  shift
  case $command in
    generate) generate "$@" ;;
    build)    build "$@" ;;
    run)      run "$@" ;;
    release)  release "$@" ;;
    ci)       ci "$@" ;;
    *)        echo "Usage: $0 (generate|build|run|release|ci)" ;;
  esac
}

main "$@"