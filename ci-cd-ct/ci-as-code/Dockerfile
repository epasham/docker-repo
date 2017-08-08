FROM jenkinsci/jenkins:2.73

ENV JENKINS_USER jenkins
ENV JENKINS_PASSWORD jenkins

COPY plugins.txt /var/jenkins_home/plugins.txt
RUN /usr/local/bin/plugins.sh /var/jenkins_home/plugins.txt
