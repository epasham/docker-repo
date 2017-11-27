#!/bin/bash

set -x
set -e

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
