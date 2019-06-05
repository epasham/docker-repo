FROM docker:latest

LABEL description="Docker image with Azure CLI" \
      maintainer="Ekambaram Pasham <ekambaram.pasham@gmail.com>"

ENV PATH="${PATH}:/opt/azure-cli/bin"

# Install Python 3 and PIP:
RUN apk add --update --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

# Install Azure CLI:
RUN apk add --update --no-cache bash && \
    apk add --update --no-cache --virtual=build gcc libffi-dev make musl-dev openssl-dev python3-dev && \
    pip install -U pip && \
    pip install azure-cli && \
    apk del --purge build && \
    rm -r /root/.cache

# Add custom scripts:
COPY scripts /opt/azure-cli/bin
CMD ["sh", "/opt/azure-cli/acr-cleanup.sh"]
