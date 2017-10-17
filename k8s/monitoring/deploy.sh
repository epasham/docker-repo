#kubectl create -f k8s-monitoring-ns.yml
kubectl create -f k8s-monitoring-cfg.yml
kubectl create -f k8s-monitoring-prom-rules-cfg.yml
kubectl create -f k8s-monitoring-kube-state-metrics.yml
kubectl create -f k8s-monitoring-alertmanager.yml
kubectl create -f k8s-monitoring-node-exporter.yml
kubectl create -f k8s-monitoring-prometheus.yml
kubectl create -f k8s-monitoring-grafana.yml
