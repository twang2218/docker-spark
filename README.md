# Supported tags and respective `Dockerfile` links

- [`2.0.2-hadoop2.3`, `2.0-hadoop2.3` (*2.0/hadoop2.3/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.0/hadoop2.3/Dockerfile)
- [`2.0.2-hadoop2.4`, `2.0-hadoop2.4` (*2.0/hadoop2.4/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.0/hadoop2.4/Dockerfile)
- [`2.0.2-hadoop2.6`, `2.0-hadoop2.6` (*2.0/hadoop2.6/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.0/hadoop2.6/Dockerfile)
- [`2.0.2-hadoop2.7`, `2.0-hadoop2.7`, `2.0` (*2.0/hadoop2.7/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.0/hadoop2.7/Dockerfile)
- [`2.1.1-hadoop2.3`, `2.1-hadoop2.3` (*2.1/hadoop2.3/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.1/hadoop2.3/Dockerfile)
- [`2.1.1-hadoop2.4`, `2.1-hadoop2.4` (*2.1/hadoop2.4/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.1/hadoop2.4/Dockerfile)
- [`2.1.1-hadoop2.6`, `2.1-hadoop2.6` (*2.1/hadoop2.6/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.1/hadoop2.6/Dockerfile)
- [`2.1.1-hadoop2.7`, `2.1-hadoop2.7`, `2.1` (*2.1/hadoop2.7/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.1/hadoop2.7/Dockerfile)
- [`2.2.0-hadoop2.6`, `2.2-hadoop2.6` (*2.2/hadoop2.6/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.2/hadoop2.6/Dockerfile)
- [`2.2.0-hadoop2.7`, `2.2-hadoop2.7`, `2.2`, `latest` (*2.2/hadoop2.7/Dockerfile*)](https://github.com/twang2218/spark/blob/master/2.2/hadoop2.7/Dockerfile)

[![Build Status](https://travis-ci.org/twang2218/docker-spark.svg?branch=master)](https://travis-ci.org/twang2218/docker-spark)
[![Image Layers and Size](https://images.microbadger.com/badges/image/twang2218/docker-spark.svg)](http://microbadger.com/images/twang2218/docker-spark)
[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/twang2218/docker-spark)

# Apache Spark Docker image

To minimize the size, this set of Spark docker images are based on [openjdk:8-alpine](https://hub.docker.com/r/library/openjdk/tags/8-alpine/).

## Usage

The image contains scala, R, and python dependencies, so it's easy to use for development environment.

To run a spark shell for scala:

```bash
docker run -it --rm twang2218/spark:2.2 spark-shell
```

To run a R shell with spark support:

```bash
docker run -it --rm twang2218/spark:2.2 sparkR
```

To run a Python shell:

```bash
docker run -it --rm twang2218/spark:2.2 pyspark
```

## Spark Standalone Cluster

It's easy to run a Spark standalone cluster with this docker image by using `docker-compose`. Here is a `docker-compose.yml` example:

```yml
version: '3'
services:
  spark-master:
    image: twang2218/spark:latest
    ports:
      - "7077:7077"
      - "8080:8080"
    environment:
      - "SPARK_MASTER_HOST=spark-master"
      # - "SPARK_MASTER_PORT=7077"
      # - "SPARK_MASTER_WEBUI_PORT=8080"
      # - "SPARK_PUBLIC_DNS=spark-master.example.com"
    command: start-master.sh

  spark-worker:
    image: twang2218/spark:latest
    ports:
      - "8081:8081"
    environment:
      # - "SPARK_WORKER_WEBUI_PORT=8081"
      - "SPARK_EXECUTOR_MEMORY=4G"
      - "SPARK_DRIVER_MEMORY=2G"
      # - "SPARK_PUBLIC_DNS=spark-worker.example.com"
    command: start-slave.sh --host spark-worker spark://spark-master:7077
```
