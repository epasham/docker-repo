#!/bin/bash

################################################################################################
#                       Monitoring Solution with Prometheus Stack
#                                       Prometheus
#                                       Grafana
################################################################################################

function wait_for_service {
    SERVICE_NAME=$1
    while true; do
        REPLICAS=$(docker service ls --filter "name=${SERVICE_NAME}" | grep ${SERVICE_NAME} | awk '{print $3}')
        if [[ ${REPLICAS} == "1/1" ]]; then
            break
        else
            echo "Waiting for the ${SERVICE_NAME} service..."
            sleep 5
        fi
    done
}

network="prom-net"
LABEL_GROUP="prom-monitoring"
PROMETHEUS_IMG_NAME="ekambaram/prom"
PROMETHEUS_IMG_TAG="1.7.1"
PROMETHEUS_SERVICE_NAME="prometheus"
PROMETHEUS_SERVICE_PORT="9090"

GRAFANA_IMG_NAME="ekambaram/grafana"
GRAFANA_IMG_TAG="4.3.2.5"
GRAFANA_SERVICE_NAME="grafana"
GRAFANA_SERVICE_PORT="3000"
GRAFANA_ADMIN_PASSWORD="password"

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
#Create Prometheus
################################################################################################
docker service ls --filter label=com.group=$LABEL_GROUP |grep $PROMETHEUS_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the prometheus service..."
  docker service create \
    --name $PROMETHEUS_SERVICE_NAME \
    --network $network \
    --publish $PROMETHEUS_SERVICE_PORT:$PROMETHEUS_SERVICE_PORT \
    --label com.group="$LABEL_GROUP" \
    --constraint 'node.role == manager' \
    $PROMETHEUS_IMG_NAME:$PROMETHEUS_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $PROMETHEUS_SERVICE_NAME"
fi
  

################################################################################################  
#Create Grafana
################################################################################################  
# Spin up official Grafana Docker image
docker service ls --filter label=com.group=$LABEL_GROUP |grep $GRAFANA_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the grafana service..." 
  docker service create \
  --name $GRAFANA_SERVICE_NAME \
  --network $network \
  --publish $GRAFANA_SERVICE_PORT:$GRAFANA_SERVICE_PORT \
  -e "GF_SECURITY_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASSWORD" \
  -e "GF_USERS_ALLOW_SIGN_UP=false" \
  -e "PROMETHEUS_ENDPOINT=prometheus:9090" \
  -e "IMPORT_DASHBOARDS=Y" \
  --label com.group="$LABEL_GROUP" \
  --constraint 'node.role == manager' \
  $GRAFANA_IMG_NAME:$GRAFANA_IMG_TAG
else
  echo "[ SERVICE IS ALREADY RUNNING ] $GRAFANA_SERVICE_NAME"
fi
