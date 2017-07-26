docker service create \
  --publish 9000:9000 \
  --name portainer \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  portainer/portainer:linux-386-1.13.4 

docker service create \
  --publish=8000:8080 \
  --limit-cpu 0.5 \
  --name visualizer \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer:stable
