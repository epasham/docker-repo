#!/bin/sh -e

cat /etc/alertmanager/config.yml | \
    sed "s|EMAIL_TO|'$EMAIL_TO'|g" | \
    sed "s|USERNAME|'$SENDGRID_USER_NAME'|g" | \
    sed "s|EMAIL_FROM|'$EMAIL_FROM'|g" | \
    sed "s|EMAIL_PASSWORD|'$EMAIL_PASSWORD'|g" > /tmp/config.yml

mv /tmp/config.yml /etc/alertmanager/config.yml

set -- $ALERTMANAGER_BIN_PATH "$@"

exec "$@"
