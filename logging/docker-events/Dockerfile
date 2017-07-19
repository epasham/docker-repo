FROM alpine:3.6

ENV DOCKERHOST="localhost"
RUN apk add --no-cache curl

ENTRYPOINT curl -sf --unix-socket /var/run/docker.sock -H "Content-Type: application/json" -X GET http:/${DOCKERHOST}/events
