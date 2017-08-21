FROM jenkinsci/jenkins

MAINTAINER Ekambaram Pasham <ekambaram.pasham@gmail.com>

USER jenkins

#Include the list of plugins to be installed
COPY plugins.txt /usr/share/jenkins/plugins.txt

#Install the plugins from plugins.txt file
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

#remove executors from jenkins master
COPY disable-executors.groovy /usr/share/jenkins/ref/init.groovy.d/

ENV JENKINS_MASTER localhost:8080
