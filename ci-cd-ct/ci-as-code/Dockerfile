FROM jenkins:2.7.3

USER root

# Install Docker
RUN apt-get update
apt-get install software-properties-common apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
RUN apt-get update
RUN apt-get install docker-engine -y
RUN systemctl enable docker

# Install Jenkins 
RUN mkdir -p /var/jenkins_home
RUN chown -R 1000:1000 /var/jenkins_home/
