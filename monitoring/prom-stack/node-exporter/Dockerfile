FROM prom/node-exporter:v0.14.0

ENV NODE_EXPORTER_BIN_PATH "/bin/node_exporter"

COPY docker-entrypoint.sh /etc/node-exporter/docker-entrypoint.sh
RUN chmod +x /etc/node-exporter/docker-entrypoint.sh

ENTRYPOINT [ "/etc/node-exporter/docker-entrypoint.sh" ]
CMD [ "/bin/node_exporter" ]
