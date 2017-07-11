Create docker volume to store elasticsearch data. setup the volume on manager
docker volume create -d local --name searchdata

Create cadvisor index pattern

1. Go to Kibana web page
2. click discover tab
3. update logstash-* with cadvisor*
4. create button gets in green color
5. hit the create button
6. cadvisor index should appear on left

Follow the below steps, if the above steps dont work

docker exec -ti <elasticsearch-container-name> sh
curl -XPUT http://localhost:9200/.kibana/index-pattern/cadvisor -d '{"title" : "cadvisor*",  "timeFieldName": "container_stats.timestamp"}'
OR
docker exec $(docker ps | grep elasticsearch | awk '{print $1}' | head -1) curl -XPUT http://localhost:9200/.kibana/index-pattern/cadvisor -d '{"title" : "cadvisor*",  "timeFieldName": "container_stats.timestamp"}'
 
