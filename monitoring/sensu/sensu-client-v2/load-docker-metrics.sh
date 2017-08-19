#!/bin/bash
set -e

# Count all running containers
running_containers=$(echo -e "GET /containers/json HTTP/1.0\r\n" | nc -U /var/run/docker.sock \
    | tail -n +5                                                           \
    | python -m json.tool                                                  \
    | grep \"Id\"                                                          \
    | wc -l)
# Count all containers
total_containers=$(echo -e "GET /containers/json?all=1 HTTP/1.0\r\n" | nc -U /var/run/docker.sock \
 | tail -n +5 \
 | python -m json.tool \
 | grep \"Id\" \
 | wc -l)

# Count all images
total_images=$(echo -e "GET /images/json HTTP/1.0\r\n" | nc -U /var/run/docker.sock \
 | tail -n +5 \
 | python -m json.tool \
 | grep \"Id\" \
 | wc -l)

echo "docker.HOST_NAME.running_containers ${running_containers}"
echo "docker.HOST_NAME.total_containers ${total_containers}"
echo "docker.HOST_NAME.total_images ${total_images}"

if [ ${running_containers} -lt 3 ]; then
    exit 1;
fi