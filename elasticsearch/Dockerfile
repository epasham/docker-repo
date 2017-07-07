FROM openjdk:8u121-jre-alpine
LABEL maintainer "Ekambaram"

RUN apk -U add bash
ENV ES_VERSION=5.4.3

ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz /tmp
RUN cd /usr/share
RUN mv /tmp/elasticsearch-${ES_VERSION} .

EXPOSE 9200 9300
HEALTHCHECK --timeout=5s CMD wget -q -O - http://$HOSTNAME:9200/_cat/health

ENV ES_HOME=/usr/share/elasticsearch-${ES_VERSION} \
    ES_USER=elasticsearch \
    ES_JAVA_OPTS="-Xms2g -Xmx2g"
RUN adduser -S -s /bin/sh $ES_USER

VOLUME ["/data","/logs",/conf"]
WORKDIR $ES_HOME
COPY java.policy /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/
COPY docker-init.sh /docker-init.sh
RUN chmod +x ./docker-init.sh
COPY log4j2.properties $ES_HOME/config/

CMD ["/docker-init.sh"]
