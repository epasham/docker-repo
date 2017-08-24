FROM centos:7

ENV CURATOR_VERSION 5.1.2

RUN yum -y update && \
    yum clean all && \
    yum -y install cronie

RUN curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python
RUN pip install elasticsearch-curator==${CURATOR_VERSION}

ADD config/curator.yml /root/.curator/curator.yml
ADD config/actions.yml /root/.curator/actions.yml
ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 755 /docker-entrypoint.sh
 
ENTRYPOINT ["/docker-entrypoint.sh"]
