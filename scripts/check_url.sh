#!/bin/bash

URL=$1
CODE=1
SECONDS=0
TIMEOUT=$2

echo -e "Blocking until <${URL}> responds...\nTimeout: ${TIMEOUT} seconds."

while [ $CODE -ne 0 ]; do
  curl -sfk \
       --connect-timeout 3 \
       --max-time 5 \
       --fail \
       --silent \
       ${URL} >/dev/null

  CODE=$?

  sleep 2
  echo -n "."

  if [ $SECONDS -ge $TIMEOUT ]; then
    echo "$URL is not available after $SECONDS seconds...stopping the install!"
    exit 1
  fi

done;

echo -e "\n\e[1m$URL\e[0m is accessible!"
