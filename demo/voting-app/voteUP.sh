#!/bin/bash

docker network create --driver overlay vote-net

docker service create \
	--name vote \
	--publish 80:80 \
	--network vote-net \
        ekambaram/votingui:v1 python app.py

docker service create \
	--name redis \
	--publish 6379:6379 \
	--network vote-net \
	redis:alpine

docker service create \
	--name db \
	--network vote-net \
	postgres:9.4

docker service create \
	--name result \
	--publish 8888:80 \
	--network vote-net \
	ekambaram/votingresult:v1 nodemon --debug server.js

docker service create \
	--name worker \
	--network vote-net \
	--replicas 3 \
	ekambaram/votingworker:v1
