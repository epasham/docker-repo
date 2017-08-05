# Selenium stack
    docker network create -d overlay devops-net

    docker service create \
      --network devops-net \
      --name seleniumhub \
      -p 4444:4444 \
      selenium/hub:3.4.0

    docker service create --network devops-net \
      --endpoint-mode dnsrr --name chrome \
      --mount type=bind,source=/dev/shm,target=/dev/shm \
      -e HUB_PORT_4444_TCP_ADDR=selenium-hub \
      -e HUB_PORT_4444_TCP_PORT=4444 \
      --replicas 1 \
      -e NODE_MAX_INSTANCES=5 \
      -e NODE_MAX_SESSION=3 \
      selenium/node-chrome:3.4.0 bash -c 'SE_OPTS="-host $HOSTNAME -port 5555" /opt/bin/entry_point.sh'

    docker service create --network devops-net \
      --endpoint-mode dnsrr --name firefox \
      --mount type=bind,source=/dev/shm,target=/dev/shm \
      -e HUB_PORT_4444_TCP_ADDR=selenium-hub 
      -e HUB_PORT_4444_TCP_PORT=4444 \
      --replicas 1 \
      -e NODE_MAX_INSTANCES=5 \
      -e NODE_MAX_SESSION=3 \
      selenium/node-firefox:3.4.0 bash -c 'SE_OPTS="-host $HOSTNAME -port 5555" /opt/bin/entry_point.sh'
