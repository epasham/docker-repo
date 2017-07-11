create cadvisor index pattern

docker exec -ti <elasticsearch-container-name> sh
curl -XPUT http://localhost:9200/.kibana/index-pattern/cadvisor -d '{"title" : "cadvisor*",  "timeFieldName": "container_stats.timestamp"}'
OR
docker exec $(docker ps | grep elasticsearch | awk '{print $1}' | head -1) curl -XPUT http://localhost:9200/.kibana/index-pattern/cadvisor -d '{"title" : "cadvisor*",  "timeFieldName": "container_stats.timestamp"}'
 
