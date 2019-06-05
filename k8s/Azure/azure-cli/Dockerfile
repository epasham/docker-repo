# docker build -t ekambaram/azure-cli:1.0 

FROM centos:centos7

LABEL description="Docker image with python, Azure CLI" \
      maintainer="Ekambaram Pasham <ekambaram.pasham@gmail.com>"

ENV PATH="${PATH}:/opt/azure-cli/bin"

# Install Python
RUN yum install -y  python36 python36-tools python36-devel 
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"; python3.6 get-pip.py; rm get-pip.py
RUN pip3 install virtualenv
RUN pip3 install awscli

# Install Azure CLI:
# Az is a bit more tricky, install steps are from here:
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
RUN set -x \
	&& echo "Import the Microsoft repository key" \
	&& rpm --import https://packages.microsoft.com/keys/microsoft.asc \
	&& echo "Create local azure-cli repository information" \
	&& echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo \
	\
	&& echo "Update the yum package index and install" \
	&& yum -y update && \
	&& yum install -y azure-cli

# Add custom scripts:
COPY scripts /opt/azure-cli/bin 

CMD ["sh", "/opt/azure-cli/acr-cleanup.sh"]
