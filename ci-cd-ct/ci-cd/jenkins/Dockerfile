FROM jenkins

USER root
RUN apt-get update \
      && apt-get install -y sudo \
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /usr/share/jenkins/ref/plugins.txt | tr -d '\r' | tr '\n' ' ')

############################################
# Configure Jenkins
############################################
# Jenkins settings
COPY config/config.xml /usr/share/jenkins/ref/config.xml
