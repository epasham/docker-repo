#!/bin/sh -e

if [ -z ${NODE_NAME+x} ]; then
  echo "Environment variable 'NODE_NAME' is not set. node name is not available"
else
  host_hostname=$(cat ${NODE_NAME})
  echo "Node Name is: ${host_hostname}"
  echo "host{host=\"$host_hostname\"} 1" > /etc/node-exporter/host_hostname.prom
fi

set -- $NODE_EXPORTER_BIN "$@"
exec "$@"
