#!/bin/sh

IMAGE_NAME=twang2218/spark
IMAGE_TAG=test

SPARK_VERSION=2.2.0
HADOOP_VERSION=2.7

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
  for t in scala R python generic; do
    docker build -t ${IMAGE_NAME}:${t} ${t}
  done
}

function run() {
  local version=${1:-$IMAGE_TAG}
  shift
  docker run -it -p 7077:7077 -p 8080:8080 ${IMAGE_NAME}:${version} "$@"
}

function service_run() {
  local version=${1:-$IMAGE_TAG}
  shift
  docker network create spark
  docker run -d \
    -p 7077:7077 \
    -p 8080:8080 \
    --network spark \
    --name spark-master \
    ${IMAGE_NAME}:${version} \
    start-master.sh \
      --host spark-master

  docker run -d \
    -p 8081:8081 \
    --network spark \
    --name spark-worker \
    ${IMAGE_NAME}:${version} \
    start-slave.sh \
      --host spark-worker \
      spark://spark-master:7077
}

function service_clean() {
  docker container rm -f spark-worker spark-master
  docker network rm spark
}

function service() {
  local command=$1
  shift
  case $command in
    run)    service_run scala ;;
    clean)  service_clean ;;
    *)      echo "Usage: $0 service (run|clean)" ;;
  esac
}

function release() {
  for tag in scala R python generic; do
    docker push ${IMAGE_NAME}:${tag}
  done
}

function main() {
  local command=$1
  shift
  case $command in
    generate) generate "$@" ;;
    build)    build "$@" ;;
    run)      run "$@" ;;
    service)  service "$@" ;;
    release)  release "$@" ;;
    *)        echo "Usage: $0 (generate|build|run|service|release)" ;;
  esac
}

main "$@"