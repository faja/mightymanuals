#!/bin/bash -

CERT_OLD_FILE=${1:-/secrets/server.pem}
CERT_NEW_FILE=${2:-${CERT_OLD_FILE}}

CERT=$(cat "${CERT_NEW_FILE}")
if test -z "${CERT}"; then
  echo could NOT get new certificate from file "${CERT_NEW_FILE}"
  exit 1
fi

echo show ssl cert "${CERT_OLD_FILE}" | socat /tmp/haproxy.stats - | grep "SHA1 FingerPrint:" > /tmp/old_cert_sha1_fingerprint.txt
if test -z "$(cat /tmp/old_cert_sha1_fingerprint.txt)"; then
  echo could NOT get current certificate metadata from haproxy stats socket
  exit 1
fi

echo -e "set ssl cert ${CERT_OLD_FILE} <<\n${CERT}\n" | socat /tmp/haproxy.stats -
echo commit ssl cert "${CERT_OLD_FILE}" | socat /tmp/haproxy.stats -

echo show ssl cert "${CERT_OLD_FILE}" | socat /tmp/haproxy.stats - | grep "SHA1 FingerPrint:" > /tmp/new_cert_sha1_fingerprint.txt
if test -z "$(cat /tmp/new_cert_sha1_fingerprint.txt)"; then
  echo could NOT get new certificate metadata from haproxy stats socket
  exit 1
fi

if diff -q /tmp/old_cert_sha1_fingerprint.txt /tmp/new_cert_sha1_fingerprint.txt; then
  echo certificate has NOT been updated
  exit 1
fi
echo certificate has been updated
