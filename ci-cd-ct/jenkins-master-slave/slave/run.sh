#! /bin/bash

/usr/local/bin/jenkins-slave.sh -master http://$JENKINS_MASTER \
 -username $JENKINS_USERNAME -password $JENKINS_USERNAME -showHostName -executors $WORKERS_NODES -labels $WORKER_LABELS
