FROM jenkinsci/jenkins:2.73

ENV JENKINS_USER jenkins
ENV JENKINS_PASSWORD jenkins

# Install plugins
COPY plugins.txt /var/jenkins_home/plugins.txt
RUN /usr/local/bin/plugins.sh /var/jenkins_home/plugins.txt

# Copy groovy the scripts
COPY groovy/create-admin.groovy /usr/share/jenkins/ref/init.groovy.d/create-admin.groovy
COPY groovy/hello-world-seed-job,groovy /usr/share/jenkins/ref/init.groovy.d/hello-world-seed-job,groovy
