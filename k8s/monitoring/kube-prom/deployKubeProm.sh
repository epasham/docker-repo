#!/bin/sh

# Verify/Create monitoring namespace
kubectl get ns monitoring >/dev/null 2>&1
if [ $? != 0 ]; then
  echo "[ INFO ] Namespace: monitoring is not found. Creating"
  kubectl create ns monitoring
else
  echo "[ INFO ] Namespace: monitoring is present"
fi

# Deploy CustomResourceDefinitions
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/01.crds.yaml
until timeout 60s kubectl get crds/prometheuses.monitoring.coreos.com; do echo "Waiting for CRDs to be created..."; done
until timeout 60s kubectl get crds/alertmanagers.monitoring.coreos.com; do echo "Waiting for CRDs to be created..."; done
until timeout 60s kubectl get crds/podmonitors.monitoring.coreos.com; do echo "Waiting for CRDs to be created..."; done
until timeout 60s kubectl get crds/prometheusrules.monitoring.coreos.com; do echo "Waiting for CRDs to be created..."; done
until timeout 60s kubectl get crds/servicemonitors.monitoring.coreos.com; do echo "Waiting for CRDs to be created..."; done 

kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/02.prom-operator.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/03.kube-state-metrics.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/04.node-exporter.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/05.alertmanager.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/06.grafana-dashboards.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/07.grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/08.prom-adapter.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/09.prom.rules.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/10.prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/epasham/docker-repo/master/k8s/monitoring/kube-prom/11.prom.serviceMonitors.yaml
