#!/bin/sh -e

NODE_NAME=$(cat /etc/nodename)

echo "Node Name is: ${NODE_NAME}"
echo "nodes{node_id=\"$NODE_ID\", node_name=\"$NODE_NAME\"} 1" > /etc/node-exporter/nodes.prom

set -- $NODE_EXPORTER_BIN_PATH "$@"
exec "$@"
