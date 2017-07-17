Follow the below steps before launching the loggingUp.sh script

1. create docker volume esdata to be used for storing elasticsearch data
docker volume create -d local --name esdata

2. copy logstash folder to root directory
cp -r logstash /

3. Import the docker-dashboard.json file in Kibana
