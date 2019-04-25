FROM ubuntu:trusty

RUN apt-get update && \
  apt-get install -y git curl \
  python-setuptools python-dev libyaml-dev python-pip python-yaml 

RUN pip install jenkins-job-builder
