#!/bin/bash

set -x
set -e

declare -A NODE_MAP=( ["etcd0"]="172.60.0.226" ["etcd1"]="172.60.0.86" ["etcd2"]="172.60.0.106" )

etcd_download()
{
    ETCD_VERSION=v3.0.15
    DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download
    [ -f ${PWD}/temp-etcd/etcd ]  && return
    curl -L ${DOWNLOAD_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o ${PWD}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
    mkdir -p ${PWD}/temp-etcd && tar xzvf ${PWD}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -C ${PWD}/temp-etcd --strip-components=1
}
