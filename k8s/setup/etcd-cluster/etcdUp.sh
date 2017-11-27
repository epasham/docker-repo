#!/bin/bash

set -x
set -e

root=$(id -u)
if [ "$root" -ne 0 ] ;then
    echo "Must run as root"
    exit 1
fi

SSH_OPTS="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oLogLevel=ERROR -C"
scp()
{
  local host="$1"
  local src=($2)
  local dst="$3"
  scp -r ${SSH_OPTS} ${src[*]} "${host}:${dst}"
}

ssh()
{
  local host="$1"
  shift
  ssh ${SSH_OPTS} -t "${host}" "$@" >/dev/null 2>&1
}


ssh_nowait()
{
  local host="$1"
  shift
  ssh ${SSH_OPTS} -t "${host}" "nohup $@" >/dev/null 2>&1 &
}

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

# ETCD Configuration
etcd_config()
{
    local node_index=$1

cat <<EOF >${PWD}/${node_index}.conf
ETCD_NAME=${node_index}
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${NODE_MAP[${node_index}]}:2380"
ETCD_LISTEN_PEER_URLS="http://${NODE_MAP[${node_index}]}:2380"
ETCD_LISTEN_CLIENT_URLS="http://${NODE_MAP[${node_index}]}:2379,http://127.0.0.1:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://${NODE_MAP[${node_index}]}:2379"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-378"
ETCD_INITIAL_CLUSTER="etcd0=http://${NODE_MAP['etcd0']}:2380,etcd1=http://${NODE_MAP['etcd1']}:2380,etcd2=http://${NODE_MAP['etcd2']}:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
# ETCD_DISCOVERY=""
# ETCD_DISCOVERY_SRV=""
# ETCD_DISCOVERY_FALLBACK="proxy"
# ETCD_DISCOVERY_PROXY=""
#
# ETCD_CA_FILE=""
# ETCD_CERT_FILE=""
# ETCD_KEY_FILE=""
# ETCD_PEER_CA_FILE=""
# ETCD_PEER_CERT_FILE=""
# ETCD_PEER_KEY_FILE=""
EOF
}

# Deploy ETCD
etcd_deploy()
{
    for key in ${!NODE_MAP[@]}
    do
        etcd_config $key
        ssh "root@${NODE_MAP[$key]}" "mkdir -p /var/lib/etcd /etc/etcd"
        scp "root@${NODE_MAP[$key]}" "${key}.conf" "/etc/etcd/10-etcd.conf"
        scp "root@${NODE_MAP[$key]}" "etcd.service" "/usr/lib/systemd/system"
        scp "root@${NODE_MAP[$key]}" "${PWD}/temp-etcd/etcd ${PWD}/temp-etcd/etcdctl" "/usr/bin"
        ssh "root@${NODE_MAP[$key]}" "chmod 755 /usr/bin/etcd*"
        ssh_nowait "root@${NODE_MAP[$key]}" "systemctl daemon-reload && systemctl enable etcd && nohup systemctl start etcd"
    done
 
}

# Clean temp files
etcd_clean()
{
  for key in ${!NODE_MAP[@]}
  do
    rm -f ${PWD}/${key}.conf
  done
  rm -f ${PWD}/etcd.service
}


etcd_download
etcd_service_cfg
etcd_deploy
etcd_clean

echo -e "\033[32m etcdctl cluster-health \033[0m"
