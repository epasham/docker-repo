## Run the below command
docker service create \
  --name devents \
  --label com.group="events" \
  --mode global \
  --mount "type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock" \
  ekambaram/docker-events:v1

Use this image along with logspout to push docker events into Elasticsearch
