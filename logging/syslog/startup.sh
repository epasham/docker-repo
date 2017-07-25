#!/bin/bash

################################################################################################
#                       Centralized Logging Solution with ELK Stack
#                            		Elasticsearch
# 					Logspout
#                                       Logstash
#                                       Kibana
################################################################################################

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

network=log-net
ns=log			# namespace
STACK=syslog	# stack name
#ES_SERVICE_NAME=${ns}-es
ES_IMG_NAME="docker.elastic.co/elasticsearch/elasticsearch"
ES_IMG_TAG=5.4.2
ES_SERVICE_NAME=elasticsearch
ES_SERVICE_PORT=9200


LOGSTASH_IMG_NAME="docker.elastic.co/logstash/logstash"
LOGSTASH_IMG_TAG=5.4.2
LOGSTASH_SERVICE_NAME=logstash
LOGSTASH_SERVICE_PORT=5000

LOGSPOUT_IMG_NAME="gliderlabs/logspout"
LOGSPOUT_IMG_TAG=latest
LOGSPOUT_SERVICE_NAME=logspout

KIBANA_IMG_NAME="docker.elastic.co/kibana/kibana"
KIBANA_IMG_TAG=5.4.2
KIBANA_SERVICE_NAME=kibana
KIBANA_SERVICE_PORT=5601

################################################################################################
# Create Networks
################################################################################################
networkFound=$(docker network ls | grep -c $network)
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
docker service ls --filter label=docker.ns=${ns} |grep $ES_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $ES_SERVICE_NAME service..."
  docker service create \
    --name ${ES_SERVICE_NAME} \
    --network ${network} \
    --constraint 'node.role == manager' \
    -e "ES_JAVA_OPTS=-Xms256m -Xmx256m" \
    -e "xpack.security.enabled=false" \
    -e "xpack.monitoring.enabled=false" \
    -e "xpack.graph.enabled=false" \
    -e "xpack.watcher.enabled=false" \
    -e "LOGSPOUT=ignore" \
    --publish ${ES_SERVICE_PORT}:${ES_SERVICE_PORT} \
    --label docker.ns=${ns} \
    --container-label docker.stack=${STACK} \
    ${ES_IMG_NAME}:${ES_IMG_TAG}
else
  echo "[ SERVICE IS ALREADY RUNNING ] $ES_SERVICE_NAME"
fi

wait_for_service $ES_SERVICE_NAME

################################################################################################
# Logstash
################################################################################################
# Spin up official Logstash Docker image
docker service ls --filter label=docker.ns=${ns} |grep ${LOGSTASH_SERVICE_NAME}
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the ${LOGSTASH_SERVICE_NAME} service..."
  docker service create \
    --name ${LOGSTASH_SERVICE_NAME} \
    --network ${network} \
    -e LOGSPOUT=ignore \
    --label docker.ns=${ns} \
    --container-label docker.stack=${STACK} \
    --mount type=bind,source=/logstash/logstash.conf,target=/usr/share/logstash/pipeline/logstash.conf \
    ${LOGSTASH_IMG_NAME}:${LOGSTASH_IMG_TAG}
else
  echo "[ SERVICE IS ALREADY RUNNING ] ${LOGSTASH_SERVICE_NAME}"
fi

wait_for_service $LOGSTASH_SERVICE_NAME

################################################################################################  
#Create Kibana
################################################################################################  
# Spin up official Kibana Docker image
docker service ls --filter label=docker.ns=${ns} |grep ${KIBANA_SERVICE_NAME}
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the ${KIBANA_SERVICE_NAME} service..." 
  docker service create \
  --name $KIBANA_SERVICE_NAME \
  --network ${network} \
  --publish ${KIBANA_SERVICE_PORT}:${KIBANA_SERVICE_PORT} \
  -e ELASTICSEARCH_URL=http://${ES_SERVICE_NAME}:${ES_SERVICE_PORT} \
  -e "XPACK_SECURITY_ENABLED=false" \
  -e "XPACK_MONITORING_ENABLED=false" \
  --label docker.ns=${ns} \
  --container-label docker.stack=${STACK} \
  ${KIBANA_IMG_NAME}:${KIBANA_IMG_TAG}
else
  echo "[ SERVICE IS ALREADY RUNNING ] ${KIBANA_SERVICE_NAME}"
fi


################################################################################################
#Create Logspout
################################################################################################
docker service ls --filter label=docker.ns=${ns} |grep $LOGSPOUT_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the $LOGSPOUT_SERVICE_NAME service..."
  docker service create \
    --name ${LOGSPOUT_SERVICE_NAME} \
    --network $network \
    --mode global \
    --label docker.ns=${ns} \
    --container-label docker.stack=${STACK} \
    -e SYSLOG_FORMAT=rfc3164 \
    -e SYSLOG_HOSTNAME=${hostname} \
    --mount "type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock" \
    ${LOGSPOUT_IMG_NAME}:${LOGSPOUT_IMG_TAG} syslog://${LOGSTASH_SERVICE_NAME}:51415
else
  echo "[ SERVICE IS ALREADY RUNNING ] ${LOGSPOUT_SERVICE_NAME}"
fi
