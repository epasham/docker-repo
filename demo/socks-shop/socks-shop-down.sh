#!/bin/bash

services=(front-end catalogue catalogue-db cart cart-db orders orders-db shipping rabbitmq payment user user-db edge-router)
networks=(ms-net)

for service in "${services[@]}"
do
  serviceFound=$(docker service ls --filter name=$service |awk '{print $2}'|grep $service|wc -l)
#  echo "Return Value: $serviceFound"
  if [ $serviceFound -eq 1 ]; then
    echo "[SHUTTING DOWN] $service"
    docker service rm $service
  else
    echo "[ SERVICE NOT FOUND ] $service"
  fi
done
sleep 3s

for network in "${networks[@]}"
do
  networkFound=$(docker network ls --filter name=$network| awk '{print $2}' |grep $network|wc -l)
  if [ $networkFound -eq 1 ]; then
    echo "[DELETING NETWORK] $network"
    docker network rm $network
    sleep 3s
  else
    echo "[ NETWORK NOT FOUND ] $network"
  fi
done
