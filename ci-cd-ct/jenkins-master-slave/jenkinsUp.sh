#!/bin/bash


# Define variables
network="ci-net"
LABEL_GROUP="ci-cd"
JENKINS_MASTER_SERVICE_NAME="jenkins"
JENKINS_MASTER_SERVICE_PORT="8080"
JENKINS_SLAVE_AGENT_PORT="50000"
JENKINS_SLAVE_SERVICE_NAME="worker"


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
#Create Master
################################################################################################
docker service ls --filter label=com.group=$LABEL_GROUP |grep $JENKINS_MASTER_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating jenkins master service..."
  docker service create \
    --name $JENKINS_MASTER_SERVICE_NAME \
    --network $network \
    --publish $JENKINS_MASTER_SERVICE_PORT:$JENKINS_MASTER_SERVICE_PORT \
    --publish $JENKINS_SLAVE_AGENT_PORT:$JENKINS_SLAVE_AGENT_PORT \
    --label app.name="jenkins-master" \
    --label com.group="$LABEL_GROUP" \
    --mount "type=volume,source=jenkinsdata,volume-driver=local,target=/var/jenkins_home" \
    --mount "type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock" \
    --mount "type=bind,source=/usr/bin/docker,destination=/usr/bin/docker" \
    --constraint 'node.role == manager' \
    ekambaram/jenkins-master:v1
else
  echo "[ SERVICE IS ALREADY RUNNING ] $JENKINS_MASTER_SERVICE_NAME"
fi
  

################################################################################################  
#Create Slave
################################################################################################  
# Spin up official Grafana Docker image
docker service ls --filter label=com.group=$LABEL_GROUP |grep $JENKINS_SLAVE_SERVICE_NAME
serviceFound=$?
if [ $serviceFound != 0 ]; then
  echo "Creating the jenkins slave service..." 
  docker service create \
  --name $JENKINS_SLAVE_SERVICE_NAME \
  --network $network \
  -e "JENKINS_MASTER=jenkins:8080" \
  -e "JENKINS_USERNAME=jenkins" \
  -e "WORKERS_NODES=1" \
  -e "WORKERS_LABELS=slave" \
  --label com.group="$LABEL_GROUP" \
  --label app.name="jenkins-slave" \
  --mount "type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock" \
  --mount "type=bind,source=/usr/bin/docker,destination=/usr/bin/docker" \
  --constraint 'node.role == manager' \
  ekambaram/jenkins-slave:v1
else
  echo "[ SERVICE IS ALREADY RUNNING ] $JENKINS_SLAVE_SERVICE_NAME"
fi


