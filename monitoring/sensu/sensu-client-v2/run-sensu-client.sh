#!/bin/bash

usage(){
	echo "Usage: $0 SENSU_SERVER CLIENT_NAME CLIENT_IP_ADDRESS"
	exit 1
}
 
[[ $# -ne 3 ]] && usage

SENSU_SERVER=$1
SENSU_USER=sensu
SENSU_PASSWORD=password
CLIENT_NAME=$2
CLIENT_IP_ADDRESS=$3

cat /tmp/sensu/config.json \
	| sed s/SENSU_SERVER/${SENSU_SERVER}/g \
	| sed s/SENSU_USER/${SENSU_USER}/g \
	| sed s/SENSU_PASSWORD/${SENSU_PASSWORD}/g > /etc/sensu/config.json 

cat /tmp/sensu/conf.d/client.json \
	| sed s/CLIENT_NAME/${CLIENT_NAME}/g \
	| sed s/CLIENT_IP_ADDRESS/${CLIENT_IP_ADDRESS}/g > /etc/sensu/conf.d/client.json


/usr/bin/supervisord