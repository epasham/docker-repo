#!/bin/bash

set -e

export JVM_OPTS="${JVM_OPTS}" # i.e -Xmx1024m
XHOME="${EXPORTER_HOME:-/opt/jmx_exporter}"
echo "[ INFO ] Exporter Home:$XHOME"

CASSANDRA_KEYSTORE_PASSWORD=cassandra
CASSANDRA_KEYSTORE_ALIAS="client-alias"

mkdir -p $XHOME/certs

echo "[ INFO ] create truststore"
echo 'yes' | keytool -import -trustcacerts -file /etc/ssl/certs/ca.crt -keystore $XHOME/certs/cacerts -storepass ${CASSANDRA_KEYSTORE_PASSWORD}

echo "[ INFO ] Copy config file to exporter home"
cp /etc/jmx_exporter/jmx_cassandra.yaml $XHOME/config.yml

echo "[ INFO ] Starting Cassandra exporter"
echo "[ INFO ] JVM_OPTS: $JVM_OPTS"

host=$(grep -m1 'host' $XHOME/config.yml | cut -d ':' -f2)
port=$(grep -m1 'host' $XHOME/config.yml | cut -d ':' -f3)
echo "[ INFO ] Host and Port From config:$host:$port"

while ! nc -z $host $port; do
  echo "[ INFO ] Waiting for Cassandra JMX to start on $host:$port"
  sleep 1
done

/sbin/dumb-init /usr/bin/java ${JVM_OPTS} -jar ${EXPORTER_HOME}/jmx_prometheus_httpserver.jar 8080 $XHOME/config.yml
