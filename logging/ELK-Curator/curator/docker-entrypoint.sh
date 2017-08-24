#!/bin/sh

echo "0 * * * * /bin/curator /root/.curator/actions.yml" > /var/spool/cron/root
crond -n -s -x sch 2>&1
