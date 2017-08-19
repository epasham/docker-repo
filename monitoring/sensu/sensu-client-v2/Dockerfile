FROM phusion/baseimage

RUN apt-get update
RUN apt-get install wget sudo
RUN wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
RUN echo "deb     http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list

RUN apt-get update
RUN apt-get install python -y
RUN apt-get install sensu -y
RUN apt-get install supervisor -y


RUN apt-get install git -y
RUN git clone https://github.com/joemiller/joemiller.me-intro-to-sensu.git /tmp/joemiller.me-intro-to-sensu
RUN cd /tmp/joemiller.me-intro-to-sensu/; ./ssl_certs.sh clean && ./ssl_certs.sh generate
RUN mkdir -p /etc/sensu/ssl \
  && cp /tmp/joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem \
  && cp /tmp/joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

ADD supervisor.conf /etc/supervisord.conf
ADD config.json /tmp/sensu/config.json
ADD client.json /tmp/sensu/conf.d/client.json
ADD run-sensu-client.sh /opt/run-sensu-client.sh
ADD load-docker-metrics.sh /etc/sensu/plugins/load-docker-metrics.sh

RUN chmod 700 /opt/run-sensu-client.sh
RUN chmod 700 /etc/sensu/plugins/load-docker-metrics.sh
RUN chown sensu:sensu /etc/sensu/plugins/load-docker-metrics.sh
ENTRYPOINT ["/opt/run-sensu-client.sh"]
