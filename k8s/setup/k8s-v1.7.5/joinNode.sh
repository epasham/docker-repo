#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 join-token master-ip-address" >&2
  exit 1
fi
k8stoken=$1
masterip=$2
#echo $k8stoken $masterip

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
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Install docker
if [ -x "$(command -v docker)" ]; then
  echo "[Information] docker is already Installed"
  docker --version
else
  echo "[Information] docker is being Installed"
  yum install -y docker
  systemctl enable docker && systemctl start docker
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
  yum -y install kubelet-1.7.5-0 kubernetes-cni-0.5.1-0 kubectl-1.7.5-0 kubeadm-1.7.5-0
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

# Patch cgroup-driver
if [ ! -f /etc/systemd/system/kubelet.service.d/10-kubeadm.conf ]; then
  echo "[Error] contact administrator to verify kubeadm installation"
  exit 1
else
  echo "[Information] /etc/systemd/system/kubelet.service.d/10-kubeadm.conf is being patched"
  sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=-.*#Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --cgroup-driver=systemd"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  systemctl daemon-reload

  # Join the node to the cluster
  kubeadm join --token $k8stoken $masterip:6443
fi
