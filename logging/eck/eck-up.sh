#!/bin/bash

################################################################################################
#                       Monitoring Solution with Prometheus Stack
# 										                  cAdvisor
#                                       Elasticsearch
#                                       Kibana
################################################################################################
network="logging-net"
LABEL_GROUP="eck-logging"

CONTAINER_EXPORTER_IMG_NAME="google/cadvisor"
CONTAINER_EXPORTER_IMG_TAG="latest"
CONTAINER_EXPORTER_SERVICE="cadvisor"

ES_IMG_NAME="elasticsearch"
ES_IMG_TAG="2.4.0"
ES_SERVICE_NAME="elasticsearch"
ES_SERVICE_PORT="9200"

KIBANA_IMG_NAME="kibana"
KIBANA_IMG_TAG="4.6.0"
KIBANA_SERVICE_NAME="kibana"
KIBANA_SERVICE_PORT="5601"

################################################################################################
# Create Networks
################################################################################################
networkFound=$(docker network ls --filter name=$network | awk '{print $2}' |grep $network|wc -l)
if [ $networkFound -eq 1 ]; then
  echo "[ NETWORK IS FOUND ] $network"
else
  echo "[ CREATING NETWORK ] $network"
  docker network create --driver overlay $network
  sleep 4s
fi

docker service create --network=logging-net \
  --mount type=volume,source=searchdata,target=/usr/share/elasticsearch/data \
  --name elasticsearch elasticsearch:2.4.0
  
docker service create --network=logging-net \
  --name kibana -e ELASTICSEARCH_URL="http://elasticsearch:9200" \
  -p 5601:5601 kibana:4.6.0


################################################################################################
# cadvisor
################################################################################################
# Spin up official cadvisor Docker image
docker service ls --filter label=com.group=$LABEL_GROUP |grep $CONTAINER_EXPORTER_SERVICE
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $CONTAINER_EXPORTER_SERVICE service..."
  docker service create \
    --name $CONTAINER_EXPORTER_SERVICE \
    --mode global \
    --network $network \
    --label com.group="$LABEL_GROUP" \
    --mount type=bind,source=/,target=/rootfs,readonly=true \
    --mount type=bind,source=/var/run,target=/var/run,readonly=false \
    --mount type=bind,source=/sys,target=/sys,readonly=true \
    --mount type=bind,source=/var/lib/docker/,target=/var/lib/docker,readonly=true \
    $CONTAINER_EXPORTER_IMG_NAME:$CONTAINER_EXPORTER_IMG_TAG \
    -storage_driver=elasticsearch \
    -storage_driver_es_host="http://elasticsearch:9200"
else
  echo "[ SERVICE IS ALREADY RUNNING ] $CONTAINER_EXPORTER_SERVICE"
fi
