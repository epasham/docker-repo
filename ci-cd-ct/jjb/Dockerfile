FROM ubuntu:trusty

RUN apt-get update && \
  apt-get install -y git curl \
  python-setuptools python-dev libyaml-dev python-pip python-yaml 

RUN pip install jenkins-job-builder

COPY . /jjb

CMD while ! curl --head --fail http://jenkins:8080/; \
  do sleep 1; echo -n .; done \
  && jenkins-jobs --conf /jjb/jenkins_jobs.ini update /jjb/config
