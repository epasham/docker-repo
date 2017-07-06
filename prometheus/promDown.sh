#!/bin/bash

#services=(prometheus node cadvisor grafana)
#networks=(prom-net)
source ./app.cfg

for service in "${services[@]}"
do
  serviceFound=$(docker service ls | awk '{print $2}'|grep $service|wc -l)
#  echo "Return Value: $serviceFound"
  if [ $serviceFound -eq 1 ]; then 
    echo "[SHUTTING DOWN] $service" 
    docker service rm $service
  else
    echo "[ SERVICE NOT FOUND ] $service"
  fi
done


for network in "${networks[@]}"
do 
  networkFound=$(docker network ls | awk '{print $2}' |grep $network|wc -l)
  if [ $networkFound -eq 1 ]; then
    echo "[DELETING NETWORK] $network" 
    docker network rm $network
  else
    echo "[ NETWORK NOT FOUND ] $network"
  fi
done
