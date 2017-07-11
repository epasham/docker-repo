create cadvisor index pattern

docker exec -ti <cadvisor-container-name> sh
curl -XPUT http://elasticsearch:9200/.kibana/index-pattern/cadvisor -d '{"title" : "cadvisor*",  "timeFieldName": "container_stats.timestamp"}'
OR
docker exec $(docker ps | grep cadvisor | awk '{print $1}' | head -1) curl -XPUT http://elasticsearch:9200/.kibana/index-pattern/cadvisor -d '{"title" : "cadvisor*",  "timeFieldName": "container_stats.timestamp"}'
 
