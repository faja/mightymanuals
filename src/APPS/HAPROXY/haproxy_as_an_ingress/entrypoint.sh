#!/bin/bash -

set -eo pipefail

echo "[$(date -u)] Starting entrypoint.sh"
echo "[$(date -u)] AWAIT_FILES='${AWAIT_FILES}'"

for FILE in ${AWAIT_FILES}
do
  while ! test -f ${FILE}
  do
    echo "[$(date -u)] Awaiting secret to be mounted: ${FILE}"
    sleep 1
  done
done

echo "[$(date -u)] exec haproxy"

/usr/local/sbin/haproxy -c -f /etc/haproxy
exec /usr/local/sbin/haproxy -f /etc/haproxy
