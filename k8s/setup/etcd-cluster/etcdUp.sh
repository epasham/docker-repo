#!/bin/bash

set -x
set -e

declare -A NODE_MAP=( ["etcd0"]="192.168.0.20" ["etcd1"]="192.168.0.21" ["etcd2"]="192.168.0.22" )

# Download ETCD binaries
etcd_download()
{
    ETCD_VERSION=v3.0.15
    DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download
    [ -f ${PWD}/temp-etcd/etcd ]  && return
    curl -L ${DOWNLOAD_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o ${PWD}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
    mkdir -p ${PWD}/temp-etcd && tar xzvf ${PWD}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -C ${PWD}/temp-etcd --strip-components=1
}

# Create ETCD service configuration
etcd_service_cfg()
{
cat <<EOF >${PWD}/etcd.service
[Unit]
Description=Etcd Server
After=network.target
 
[Service]
Type=notify
WorkingDirectory=/var/lib/etcd
EnvironmentFile=-/etc/etcd/10-etcd.conf
ExecStart=/usr/bin/etcd
Restart=always
RestartSec=8s
LimitNOFILE=40000
 
[Install]
WantedBy=multi-user.target
EOF
}








etcd_download
etcd_service_cfg
#etcd_deploy
#etcd_clean
