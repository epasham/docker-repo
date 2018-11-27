FROM centos:7
MAINTAINER Ekambaram Pasham <ekambaram_pasham@infosys.com>

USER root

ARG EXPORTER_VERSION=parent-0.3.1
ARG EXPORTER_REPO=github.com/prometheus/jmx_exporter
ARG EXPORTER_GROUP=container
ARG EXPORTER_USER=container

ENV EXPORTER_HOME=/opt/jmx_exporter
ENV EXPORTER_CONFIG=/etc/jmx_exporter

RUN yum install -y nc wget which java-1.8.0-openjdk-devel \
 && yum clean all

RUN mkdir -p $EXPORTER_CONFIG $EXPORTER_HOME

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
 && mv dumb-init_1.2.1_amd64 /sbin/dumb-init

RUN set -ex \
 && MAVEN_VERSION=3.5.2 PATH=$PATH:$(pwd)/maven/bin \
 && mkdir ./maven \
 && curl -SLs https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzf - --strip-components=1 -C ./maven \
 && mvn --version \
 && mkdir ./jmx_exporter \
 && curl -SLs https://$EXPORTER_REPO/archive/$EXPORTER_VERSION.tar.gz | tar -xzf - --strip-components=1 -C ./jmx_exporter \
 && cd ./jmx_exporter \
 && mvn package \
 && find jmx_prometheus_httpserver/ -name *-jar-with-dependencies.jar -exec mv -v '{}' ${EXPORTER_HOME}/jmx_prometheus_httpserver.jar \; \
 && mv example_configs ${EXPORTER_HOME} \
 && cd .. \
              # rm -Rf ./jmx_exporter ./maven /root/.m2;
 && rm -Rf ./maven /root/.m2

RUN chmod +x /sbin/dumb-init

# creating group and user
RUN groupadd ${EXPORTER_GROUP}
RUN adduser -g ${EXPORTER_GROUP} --home-dir /home/${EXPORTER_USER} --create-home ${EXPORTER_USER}
RUN echo "${EXPORTER_USER}:${EXPORTER_USER}"|chpasswd

# chown owner:group
RUN chown -R ${EXPORTER_USER}:${EXPORTER_GROUP} ${EXPORTER_HOME} \
 && chmod -R 777 ${EXPORTER_HOME}

ADD jmx_cassandra.yaml ${EXPORTER_CONFIG}
ADD ca.key ca.crt /etc/ssl/certs/
ADD run.sh /

USER ${EXPORTER_USER}

# ports
EXPOSE 8080

CMD ["/sbin/dumb-init", "/bin/bash", "/run.sh"]
