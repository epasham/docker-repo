#!/bin/bash

docker network create monitoring -d overlay

docker service create --network=monitoring \
  --mount type=volume,source=searchdata,target=/usr/share/elasticsearch/data \
  --name elasticsearch elasticsearch:2.4.0
  
docker service create --network=monitoring \
  --name kibana -e ELASTICSEARCH_URL="http://elasticsearch:9200" \
  -p 5601:5601 kibana:4.6.0
  
docker service create --network=monitoring \
  --mode global --name cadvisor \
  --mount type=bind,source=/,target=/rootfs,readonly=true \
  --mount type=bind,source=/var/run,target=/var/run,readonly=false \
  --mount type=bind,source=/sys,target=/sys,readonly=true \
  --mount type=bind,source=/var/lib/docker/,target=/var/lib/docker,readonly=true \
  google/cadvisor:latest \
  -storage_driver=elasticsearch \
  -storage_driver_es_host="http://elasticsearch:9200"

