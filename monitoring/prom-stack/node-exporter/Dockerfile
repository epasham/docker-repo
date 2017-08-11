FROM prom/node-exporter:v0.14.0

ENV "NODE_EXPORTER_BIN=/bin/node_exporter"

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/bin/node_exporter" ]
