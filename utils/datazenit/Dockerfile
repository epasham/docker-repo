FROM java:8
LABEL Description="Datazenit is a modern web-based database administration tool for MySQL and PostgreSQL"

ENV DATAZENIT_VERSION 1.1.0

RUN curl -L -o datazenit.tgz https://datazenit.com/store/download/server/linux \
    && tar xvfz datazenit.tgz \
    && mv datazenit-${DATAZENIT_VERSION} /usr/src/datazenit \
    && chmod +x /usr/src/datazenit/bin/datazenit

EXPOSE 9000
CMD ["/usr/src/datazenit/bin/datazenit"]
