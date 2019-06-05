# docker build -t ekambaram/azure-cli:1.0 .

FROM centos:centos7

LABEL description="Docker image with Azure CLI" \
      maintainer="Ekambaram Pasham <ekambaram.pasham@gmail.com>"

ENV PATH="${PATH}:/opt/azure-cli/bin"

# Adding AZ-CLI
RUN yum check-update; yum install -y gcc libffi-devel python-devel openssl-devel
RUN curl "https://bootstrap.pypa.io/get-pip.py" | python
RUN pip install --pre azure-cli

# Add custom scripts:
COPY scripts /opt/azure-cli/bin 
RUN chmod +x /opt/azure-cli/bin/*.sh

CMD ["sh", "/opt/azure-cli/acr-cleanup.sh"]
