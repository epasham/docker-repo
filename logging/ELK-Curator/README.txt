# Bringup ELK Curator stack

    docker stack deploy -c docker-stack-es-curator.yml elk

The above command would launch below containers in docker swarm
Elasticsearch, Logstash, Kibana, X-Pack, Curator, NGINX


This stack exposes the following ports:
    5044: Logstash Beats input.
    5601: Kibana with default X-Pack credentials (user: elastic, password: changeme)
    9200: Elasticsearch with default X-Pack credentials (user: elastic, password: changeme)
    
# Update the Logstash configuration    
The Logstash configuration is stored in config/logstash/logstash.conf
It is configured to receive data by a Beats client on port 5044 without filters. 
You might want to configure this file as per yours requirements

# Update the Curator configuration
The Curator configuration is stored in config/curator/curator.yml and config/curator/actions.yml.
NOTE: Curator is configured to purge documents from logstash-* index that are older than 30 days. You might want to configure 
these files according yours needs.

# NGINX as a proxy?
We need DNS Round Robin in ( dnsrr ) Swarm service configuration for Elasticsearch to achieve scaling on unicast messages.
Docker can't publish on ingress network (VIP is required). So an NGINX included in front of Elasticsearch as a proxy.
