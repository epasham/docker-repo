#!/bin/bash

usage(){
	echo "Usage: $0 SENSU_SERVER CLIENT_NAME"
	exit 1
}

[[ $# -ne 2 ]] && usage

#SENSU_SERVER=$(grep sensuserver /etc/hosts | awk '{ print $1}')
SENSU_SERVER=$1
SENSU_USER=sensu
SENSU_PASSWORD=password
CLIENT_NAME=$2
CLIENT_IP_ADDRESS=$(ifconfig|grep eth0 -A 1|grep inet| awk '{print $2}' | sed s/addr://g)

cat /tmp/sensu/config.json \
	| sed s/SENSU_SERVER/${SENSU_SERVER}/g \
	| sed s/SENSU_USER/${SENSU_USER}/g \
	| sed s/SENSU_PASSWORD/${SENSU_PASSWORD}/g > /etc/sensu/config.json

cat /tmp/sensu/conf.d/client.json \
	| sed s/CLIENT_NAME/${CLIENT_NAME}/g \
	| sed s/CLIENT_IP_ADDRESS/${CLIENT_IP_ADDRESS}/g > /etc/sensu/conf.d/client.json


/usr/bin/supervisord
