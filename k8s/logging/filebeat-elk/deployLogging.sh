#kubectl create -f k8s-ns-logging.yml
kubectl create -f k8s-logging-cfg.yml
kubectl create -f k8s-logging-elasticsearch.yml
kubectl create -f k8s-logging-kibana.yml
kubectl create -f k8s-logging-logstash.yml
kubectl create -f k8s-logging-filebeat.yml
