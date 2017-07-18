Elasticsearch uses a hybrid mmapfs / niofs directory by default to store its indices. The default operating system limits on mmap counts is likely to be too low, which may result in out of memory exceptions.

On Linux, you can increase the limits by running the following command as root:
    sysctl -w vm.max_map_count=262144
To set this value permanently, update the vm.max_map_count setting in /etc/sysctl.conf. To verify after rebooting, run sysctl vm.max_map_count


# Follow the below steps before launching the loggingUp.sh script

1. create docker volume esdata to be used for storing elasticsearch data
docker volume create -d local --name esdata

2. copy logstash folder to root directory
cp -r logstash /

3. Import the docker-dashboard.json file in Kibana
