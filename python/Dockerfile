FROM openjdk:8-alpine

# bash: for spark shell
# procps: for `ps -p`
RUN apk --no-cache add bash procps python

ENV SPARK_VERSION 2.2.0
ENV HADOOP_VERSION 2.7
ENV SPARK_HOME /usr/local/share/spark

ENV SPARK_NO_DAEMONIZE=true

RUN set -xe \
  && cd tmp \
  && wget http://www.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
  && tar -zxvf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
  && rm *.tgz \
  && mkdir -p `dirname ${SPARK_HOME}` \
  && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME}


ENV PATH=$PATH:${SPARK_HOME}/sbin:${SPARK_HOME}/bin

WORKDIR ${SPARK_HOME}

# SPARK_MASTER_PORT
EXPOSE 7077
# SPARK_MASTER_WEBUI_PORT
EXPOSE 8080

CMD ["pyspark"]
