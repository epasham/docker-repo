FROM docker.elastic.co/logstash/logstash:5.4.2

COPY logstash.yml /usr/share/logstash/config/
COPY logstash.conf /usr/share/logstash/pipeline/

CMD logstash -f /usr/share/logstash/pipeline/logstash.conf
