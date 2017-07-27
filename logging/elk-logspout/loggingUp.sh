#!/bin/bash

################################################################################################
#                       Loggining Solution with ELLK Stack
# 										Elasticsearch
#                                       Logspout
# 										Logstash
#                                       Kibana
################################################################################################

function wait_for_service {
    SERVICE_NAME=$1
    while true; do
        REPLICAS=$(docker service ls --filter "name=${SERVICE_NAME}" |awk 'NR>1'| awk '{print $3}')
        if [[ ${REPLICAS} == "1/1" ]]; then
            break
        else
            echo "Waiting for the ${SERVICE_NAME} service..."
            sleep 5
        fi
    done
}

network="logging-net"
LABEL_GROUP="ellk-logging"

ES_IMG_NAME="docker.elastic.co/elasticsearch/elasticsearch"
ES_IMG_TAG="5.4.2"
ES_SERVICE_NAME="elasticsearch"
ES_SERVICE_PORT="9200"

LOGSTASH_IMG_NAME="docker.elastic.co/logstash/logstash"
LOGSTASH_IMG_TAG="5.4.2"
LOGSTASH_SERVICE_NAME="logstash"

LOGSPOUT_IMG_NAME="ekambaram/logspout-logstash"
LOGSPOUT_IMG_TAG="v1"
LOGSPOUT_SERVICE_NAME="logspout"

KIBANA_IMG_NAME="docker.elastic.co/kibana/kibana"
KIBANA_IMG_TAG="5.4.2"
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

################################################################################################
#Create Elasticsearch
################################################################################################
# Spin up official Elasticsearch Docker image
docker service ls --filter label=com.group=$LABEL_GROUP |grep $ES_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $ES_SERVICE_NAME service..."
  docker service create \
    --name $ES_SERVICE_NAME \
    --network $network \
    --label com.group="$LABEL_GROUP" \
    --constraint 'node.role == manager' \
    -e "LOGSPOUT=ignore" \
    -e "ES_JAVA_OPTS=-Xms256m -Xmx256m" \
    -e "xpack.security.enabled=false" \
    -e "xpack.monitoring.enabled=false" \
    -e "xpack.graph.enabled=false" \
    -e "xpack.watcher.enabled=false" \
    --mount type=volume,source=esdata,target=/usr/share/elasticsearch/data \
    $ES_IMG_NAME:$ES_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $ES_SERVICE_NAME"
fi

wait_for_service $ES_SERVICE_NAME

################################################################################################
# Logstash
################################################################################################
# Spin up official Logstash Docker image
docker service ls --filter label=com.group=$LABEL_GROUP |grep $LOGSTASH_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $LOGSTASH_SERVICE_NAME service..."
  docker service create \
    --name $LOGSTASH_SERVICE_NAME \
    --network $network \
    --label com.group="$LABEL_GROUP" \
    --mount type=bind,source=/logstash/logstash.conf,target=/usr/share/logstash/pipeline/logstash.conf \
    $LOGSTASH_IMG_NAME:$LOGSTASH_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $LOGSTASH_SERVICE_NAME"
fi

wait_for_service $LOGSTASH_SERVICE_NAME

################################################################################################
#Create Logspout
################################################################################################
docker service ls --filter label=com.group=$LABEL_GROUP |grep $LOGSPOUT_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $LOGSPOUT_SERVICE_NAME service..."
  docker service create \
    --name $LOGSPOUT_SERVICE_NAME \
    --network $network \
    --mode global \
    -e "ROUTE_URIS=logstash://logstash:5000" \
    --label com.group="$LABEL_GROUP" \
    --mount "type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock" \
    $LOGSPOUT_IMG_NAME:$LOGSPOUT_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $LOGSPOUT_SERVICE_NAME"
fi
  

################################################################################################  
#Create Kibana
################################################################################################  
# Spin up official Kibana Docker image
docker service ls --filter label=com.group=$LABEL_GROUP |grep $KIBANA_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $KIBANA_SERVICE_NAME service..." 
  docker service create \
  --name $KIBANA_SERVICE_NAME \
  --network $network \
  --publish $KIBANA_SERVICE_PORT:$KIBANA_SERVICE_PORT \
  -e "ELASTICSEARCH_URL=http://elasticsearch:9200" \
  -e "XPACK_SECURITY_ENABLED=false" \
  -e "XPACK_MONITORING_ENABLED=false" \
  --label com.group="$LABEL_GROUP" \
  $KIBANA_IMG_NAME:$KIBANA_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $KIBANA_SERVICE_NAME"
fi
