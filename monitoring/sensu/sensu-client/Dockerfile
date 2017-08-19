FROM ubuntu

# Install sensu
RUN apt-get update \
        && apt-get install -y wget \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Install sensu repository
RUN wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
RUN echo "deb http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list

# Install sensu
RUN apt-get update \
        && apt-get install -y sensu \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Install sensu plugins
RUN sensu-install -p process-checks:0.0.6

# Install sensu client configuration
ADD config.json /etc/sensu/config.json
ADD check_cron.json /etc/sensu/conf.d/check_cron.json

# Launch sensu
CMD ["/opt/sensu/embedded/bin/ruby", "/opt/sensu/bin/sensu-client", "-c", "/etc/sensu/config.json", "-d", "/etc/sensu/conf.d", "-e", "/etc/sensu/extensions", "-p", "/var/run/sensu-client.pid", "-L", "info"]
