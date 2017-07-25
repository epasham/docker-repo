#!/bin/bash

function wait_for_service {
    SERVICE_NAME=$1
    while true; do
	REPLICAS=$(docker service ls --filter "name=${SERVICE_NAME}" | grep ${SERVICE_NAME} | awk '{print $4}')
        if [[ ${REPLICAS} == "1/1" ]]; then
            break
        else
            echo "Waiting for the ${SERVICE_NAME} service..."
            sleep 5
        fi
    done
}

network=efk-net
LABEL_GROUP=efk-logging

ES_IMG_NAME="docker.elastic.co/elasticsearch/elasticsearch"
ES_IMG_TAG=5.4.2
ES_SERVICE=elasticsearch
ES_VERSION=5.4.2

KIBANA_IMG_NAME="docker.elastic.co/kibana/kibana"
KIBANA_IMG_TAG=5.4.2
KIBANA_SERVICE=kibana
KIBANA_SERVICE_PORT=5601

FLUENTD_IMG_NAME="ekambaram/fluentd"
FLUENTD_IMG_TAG=v1
FLUENTD_SERVICE_NAME=fluentd
FLUENTD_SERVICE_PORT=24224


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

################################################################################################
# 			Logging Solution with EFK Stack
# 					Elasticsearch
# 					Kibana
# 					Fluentd
################################################################################################  

################################################################################################
#Create elasticsearch
################################################################################################
# Spin up official elasticsearch Docker image
docker service ls --filter label=docker.group=$LABEL_GROUP |grep $ES_SERVICE
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $ES_SERVICE service..."
  docker service create \
    --name $ES_SERVICE \
    --network $network \
    --label docker.group="$LABEL_GROUP" \
	--constraint 'node.role == manager' \
    --env "ES_JAVA_OPTS=-Xms256m -Xmx256m" \
    --env "xpack.security.enabled=false" \
    --env "xpack.monitoring.enabled=false" \
    --env "xpack.graph.enabled=false" \
    --env "xpack.watcher.enabled=false" \
    $ES_IMG_NAME:$ES_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $ES_SERVICE"
fi

wait_for_service $ES_SERVICE

################################################################################################
# Kibana
################################################################################################
# Spin up official Kibana Docker image
docker service ls --filter label=docker.group=$LABEL_GROUP |grep $KIBANA_SERVICE
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $KIBANA_SERVICE service..."
  docker service create \
    --name $KIBANA_SERVICE \
    --network $network \
    --label docker.group="$LABEL_GROUP" \
	--publish $KIBANA_SERVICE_PORT:$KIBANA_SERVICE_PORT \
    --env "ELASTICSEARCH_URL=http://elasticsearch:9200" \
    --env "XPACK_SECURITY_ENABLED=false" \
    --env "XPACK_MONITORING_ENABLED=false" \
    $KIBANA_IMG_NAME:$KIBANA_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $KIBANA_SERVICE"
fi

################################################################################################
#Create Fluentd
################################################################################################ 
docker service ls --filter label=docker.group=$LABEL_GROUP |grep $FLUENTD_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $FLUENTD_SERVICE_NAME service..."
  docker service create \
  --name $FLUENTD_SERVICE_NAME \
  --network $network \
  --label docker.group="$LABEL_GROUP" \
  --publish $FLUENTD_SERVICE_PORT:$FLUENTD_SERVICE_PORT \
  $FLUENTD_IMG_NAME:$FLUENTD_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $FLUENTD_SERVICE_NAME"
fi
