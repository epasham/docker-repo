FROM jenkinsci/jenkins:alpine

LABEL DESCRIPTION="Jenkins Image" \
      Creator="Ekambaram"

ENV KUBECTL_VERSION "1.28.1"

# Install OS dependecies using the root user
USER root

ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN apk add --no-cache \
        busybox-suid \
        ca-certificates \
        curl \
        docker \
    && chmod +x /usr/local/bin/kubectl \
    && addgroup jenkins docker

RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
