FROM openjdk:10-slim
MAINTAINER Ekambaram Pasham <ekambaram_pasham@infosys.com>

USER root

ARG EXPORTER_VERSION=2.0.0
ARG EXPORTER_SHA512=7baa4e13f0a3c4228ba9d6cb848027f8837de0a0bc2a6b4fc3d8265e00a53fe926a6eac75a32a84de5e0771b355c1a8715dd46886c134710c6f26f477010b9d3
ARG EXPORTER_GROUP=container
ARG EXPORTER_USER=container


RUN apt-get update \
  && apt-get install -y --no-install-recommends netcat wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/cassandra_exporter /opt/cassandra_exporter

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
  && mv dumb-init_1.2.1_amd64 /sbin/dumb-init


RUN wget https://github.com/criteo/cassandra_exporter/releases/download/${EXPORTER_VERSION}/cassandra_exporter-${EXPORTER_VERSION}-all.jar \
  && mv cassandra_exporter-${EXPORTER_VERSION}-all.jar /opt/cassandra_exporter/cassandra_exporter.jar

RUN echo "${EXPORTER_SHA512}  /opt/cassandra_exporter/cassandra_exporter.jar" > sha512_checksum.txt && sha512sum -c sha512_checksum.txt
ADD config.yml /etc/cassandra_exporter/
ADD run.sh /

RUN chmod +x /sbin/dumb-init

# creating group and user
RUN groupadd ${EXPORTER_GROUP}
RUN adduser -g ${EXPORTER_GROUP} --home-dir /home/${EXPORTER_USER} --create-home ${EXPORTER_USER}
RUN echo "${EXPORTER_USER}:${EXPORTER_USER}"|chpasswd

# chown owner:group
RUN chown -R ${EXPORTER_USER}:${EXPORTER_GROUP} /opt/cassandra_exporter/

USER ${EXPORTER_USER}

CMD ["/sbin/dumb-init", "/bin/bash", "/run.sh"]
