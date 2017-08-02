FROM java:8u111-jdk-alpine
LABEL Description="Datazenit is a modern web-based database administration tool for MySQL and PostgreSQL"

ENV DATAZENIT_VERSION 1.1.0

RUN curl -L -o datazenit.tgz https://datazenit.com/store/download/server/linux \
    && tar xvfz datazenit.tgz \
    && mv datazenit-${DATAZENIT_VERSION} /usr/src/datazenit \
    && chmod +x /usr/src/datazenit/bin/datazenit

WORKDIR /usr/src/datazenit/

EXPOSE 8080

CMD ["/usr/src/datazenit/bin/datazenit"]
