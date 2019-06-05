# docker build -t ekambaram/azure-cli:1.0 .

FROM centos:centos7

LABEL description="Docker image with python, Azure CLI" \
      maintainer="Ekambaram Pasham <ekambaram.pasham@gmail.com>"

ENV PATH="${PATH}:/opt/azure-cli/bin"

# Install Python3
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
    yum -y update && \
    yum -y install python36u python36u-libs python36u-devel python36u-pip

# Install Azure CLI:
RUN curl "https://bootstrap.pypa.io/get-pip.py" | python
RUN pip install --pre azure-cli

# Add custom scripts:
COPY scripts /opt/azure-cli/bin 

CMD ["sh", "/opt/azure-cli/acr-cleanup.sh"]
