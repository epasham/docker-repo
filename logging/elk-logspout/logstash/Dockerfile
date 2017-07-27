FROM docker.elastic.co/logstash/logstash:5.4.2

COPY logstash.conf /usr/share/logstash/pipeline/

CMD logstash -f /usr/share/logstash/pipeline/logstash.conf
