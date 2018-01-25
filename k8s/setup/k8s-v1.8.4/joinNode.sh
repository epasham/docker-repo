#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 join-token master-ip-address discovery-token-ca-cert-hash" >&2
  exit 1
fi
k8stoken=$1
masterip=$2
discoverytokenhash=$3
#echo $k8stoken $masterip $discoverytokenhash

# Check if the user running the script is root
if ! [ $(id -u) = 0 ]; then
   echo "[Alert] You should run this script as Root user"
   exit 1
fi

if [ ! -f /etc/yum.repos.d/kubernetes.repo ]; then
  echo "[Information] kubernetes.repo is being created"
  cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
else
  echo "[Information] kubernetes.repo is Found"
fi

# Turn off SELinux
selinux_value=$(cat /etc/sysconfig/selinux | grep SELINUX=disabled | wc -l)
#echo $selinux_value
if [ $selinux_value = 0 ]; then
  echo "[Information] SElinux is being turned off"
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
else
  echo "[Information] SElinux is already turned off"
fi


echo ""
# Install docker version 17.03
if [ -x "$(command -v docker)" ]; then
  echo "[Information] docker is already Installed"
  docker --version
else
  echo "[Information] docker is being Installed"
  #yum install -y docker
  wget -c -O /tmp/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm

  wget -c -O /tmp/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm

  chmod +x /tmp/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
  chmod +x /tmp/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm

  yum -y install /tmp/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
  yum -y install /tmp/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm

  systemctl enable docker
  systemctl daemon-reload
  systemctl restart docker
  systemctl status docker

  rm -f /tmp/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
  rm -f /tmp/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm

fi

# Check that docker systemd service is created
if [ ! -f /usr/lib/systemd/system/docker.service ]; then
   echo "[Error] contact administrator to verify docker installation"
   exit 1
else
  echo "[Information]/usr/lib/systemd/system/docker.service is Found"
fi

# Install kubeadm
if [ -x "$(command -v kubeadm)" ]; then
  echo "[Information] kubeadm is already Installed"
  kubeadm version
else
  echo "[Information] kubeadm  is being Installed"
#  yum install kubeadm -y
  yum -y install kubelet-1.8.4-0 kubernetes-cni-0.5.1-1 kubectl-1.8.4-0 kubeadm-1.8.4-0
  systemctl enable kubelet
fi

# Check that kubelet  systemd service is created
if [ ! -f /etc/systemd/system/kubelet.service  ]; then
  echo "[Error] contact administrator to verify kubeadm installation"
  exit 1
else
  echo "[Information] /etc/systemd/system/kubelet.service is Found"
fi

echo ""
# Check iptables bridge
iptable_bridge_value=$(cat /proc/sys/net/bridge/bridge-nf-call-iptables)
#echo $iptable_bridge_value
if [ $iptable_bridge_value = 0 ]; then
  echo "[Information] Updating iptables_bridge_value"
  echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
fi

echo ""
iptable_bridge_value=$(cat /proc/sys/net/bridge/bridge-nf-call-ip6tables)
#echo $iptable_bridge_value
if [ $iptable_bridge_value = 0 ]; then
  echo "[Information] Updating ip6tables_bridge_value"
  echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
fi

# Docker 1.13 and above changes the behaviour of iptables defaults from allow to drop.
# This patch disables docker's iptables management as it was in Docker 1.12
isDropped=$(iptables -S |grep FORWARD|grep DROP|wc -l)
if [ $isDropped = 0 ]; then
  echo "iptables patching is not required"
else
  echo "patching iptables FORWARD policy"
  iptables -P FORWARD ACCEPT
fi


dDriver=$(docker info|grep -i cgroup |awk {'print $3'})
echo "Cgroup Driver: $dDriver"
# Patch cgroup-driver
if [ ! -f /etc/systemd/system/kubelet.service.d/10-kubeadm.conf ]; then
  echo "[Error] contact administrator to verify kubeadm installation"
  exit 1
else
  if [ "$dDriver" == "cgroupfs" ]; then
    echo "[ INFO ] updating cgroupfs driver"
    sed -i 's|systemd|cgroupfs|g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  else
    echo "[Information] /etc/systemd/system/kubelet.service.d/10-kubeadm.conf is being patched"
    sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=-.*#Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --cgroup
-driver=systemd"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  fi
  systemctl daemon-reload


  # Join the node to the cluster
  kubeadm join --token $k8stoken $masterip:6443 --discovery-token-ca-cert-hash sha256:$discoverytokenhash
fi
