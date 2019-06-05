# docker build -t ekambaram/azure-cli:1.0 

FROM centos:7

LABEL description="Docker image with python, Azure CLI" \
      maintainer="Ekambaram Pasham <ekambaram.pasham@gmail.com>"

ENV PATH="${PATH}:/opt/azure-cli/bin"

# Install Python3
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
    yum -y update && \
    yum -y install python36u python36u-libs python36u-devel python36u-pip

# Install Azure CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
RUN yum install -y azure-cli

# Add custom scripts:
COPY scripts /opt/azure-cli/bin 

CMD ["sh", "/opt/azure-cli/acr-cleanup.sh"]
