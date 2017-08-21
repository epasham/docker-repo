FROM java:8

ENV JENKINS_SWARM_VERSION 2.2
ENV HOME /var/jenkins_home

RUN apt-get update && apt-get install -y net-tools && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 998 docker
RUN groupadd -g 1000 jenkins
RUN useradd -u 1000 -G users,docker -g jenkins -m  -d $HOME -r  jenkins
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
  && chmod 755 /usr/share/jenkins


#
# Install Docker Compose
#
ENV DOCKER_COMPOSE_VERSION 1.12.0
RUN \
    curl --insecure -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose


COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
COPY run.sh /usr/local/bin/run.sh
RUN chmod 755 /usr/local/bin/jenkins-slave.sh
RUN chmod 755 /usr/local/bin/run.sh


ENV JENKINS_MASTER master:8080
ENV WORKERS_NODES=1
ENV WORKER_LABELS=generic
USER jenkins
VOLUME /var/jenkins_home

ENTRYPOINT ["/usr/local/bin/run.sh"]
