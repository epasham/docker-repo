FROM hiroakis/docker-sensu-server

RUN yum install python -y

ADD supervisor.conf /etc/supervisord.conf
ADD config.json /tmp/sensu/config.json
ADD client.json /tmp/sensu/conf.d/client.json
COPY *.py /etc/sensu/plugins/
ADD run-sensu-client.sh /opt/run-sensu-client.sh
RUN chmod 700 /opt/run-sensu-client.sh

ENTRYPOINT ["/opt/run-sensu-client.sh"]

