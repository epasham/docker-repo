FROM jenkins:2.7.3

USER root

# Install Docker
RUN apt-get update
RUN apt-get install -y software-properties-common apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list.d/docker.list
RUN apt-get update
RUN apt-get install -y docker-engine
RUN systemctl enable docker

# Install Jenkins 
RUN mkdir -p /var/jenkins_home
RUN chown -R 1000:1000 /var/jenkins_home/
