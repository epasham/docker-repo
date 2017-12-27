#!/bin/bash

# gcr.io URL
#https://console.cloud.google.com/kubernetes/images/list?location=GLOBAL&project=google-containers
#https://kubernetes.io/docs/admin/kubeadm/

KUBE_VERSION=v1.7.5
KUBE_PAUSE_VERSION=3.0
ETCD_VERSION=3.0.17
DNS_VERSION=1.14.4

GCR_URL=gcr.io/google_containers
MY_REPO_URL=docker.io/ekambaram # Change the repo url

images=(kube-proxy-amd64:${KUBE_VERSION}
kube-scheduler-amd64:${KUBE_VERSION}
kube-controller-manager-amd64:${KUBE_VERSION}
kube-apiserver-amd64:${KUBE_VERSION}
pause-amd64:${KUBE_PAUSE_VERSION}
etcd-amd64:${ETCD_VERSION}
k8s-dns-sidecar-amd64:${DNS_VERSION}
k8s-dns-kube-dns-amd64:${DNS_VERSION}
k8s-dns-dnsmasq-nanny-amd64:${DNS_VERSION})

# kube components
for img in ${images[@]} ; do
  docker pull $GCR_URL/$img
  docker tag $GCR_URL/$img $MY_REPO_URL/$img
  docker push $MY_REPO_URL/$img
  docker rmi $MY_REPO_URL/$img
done

# flannel network plugin components
docker pull quay.io/coreos/flannel:v0.8.0-amd64
docker tag quay.io/coreos/flannel:v0.8.0-amd64 $MY_REPO_URL/flannel:v0.8.0-amd64
docker push $MY_REPO_URL/flannel:v0.8.0-amd64
docker rmi $MY_REPO_URL/flannel:v0.8.0-amd64
