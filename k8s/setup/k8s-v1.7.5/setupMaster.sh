#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 fully-qualified-dns-name" >&2
  exit 1
fi
fqdn=$1
echo "FQDN: "$fqdn

# Check if the user running the script is root
if ! [ $(id -u) = 0 ]; then
   echo "[Alert] You should run this script as Root user"
   exit 1
fi

echo ""
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
echo ""

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
# Install docker
if [ -x "$(command -v docker)" ]; then
  echo "[Information] docker is already Installed"
  docker --version
else
  echo "[Information] docker is being Installed"
  yum install -y docker
  systemctl enable docker && systemctl start docker
fi

echo ""
# Check that docker systemd service is created
if [ ! -f /usr/lib/systemd/system/docker.service ]; then
   echo "[Error] contact administrator to verify docker installation"
   exit 1
else
  echo "[Information]/usr/lib/systemd/system/docker.service is Found"
fi

echo ""
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

echo ""
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

  # Initialize the cluster
  if [ -z "$fqdn" ]; then
    echo 'kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.244.0.0/16'
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.244.0.0/16
  else
    echo 'kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.244.0.0/16 --apiserver-cert-extra-sans $fqdn'
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.244.0.0/16 --apiserver-cert-extra-sans $fqdn
  fi
fi

# Add kube config for kubectl to communicate with the api server
if [ ! -f /etc/kubernetes/admin.conf ]; then
  echo "[Error] contact administrator to verify kubeadm installation"
  exit 1
else
  echo "[Information] kube config for kubectl is being performed"
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config

  # Deploy a pod network to the cluster
#  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  cat flannel/1-kube-flannel.yml | kubectl apply -f -
  cat flannel/2-kube-flannel-rbac.yml | kubectl apply -f -


  echo "--------------------------------------------------------------------------------------"
  echo "Cluster is Initialized"
  echo ""
  echo "You can now join any number of machines by running the following on each node as root:"
  echo "kubeadm join --token <token-id> <master-ip>:6443"
  echo ""
  echo "run kubeadm token list on master to get the token"
  echo "--------------------------------------------------------------------------------------"
fi
