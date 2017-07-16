#!/bin/bash

OPTION=$1
URL=$2
SECONDS=0
txtred=$(tput setaf 1)
txtbold=$(tput bold)
txtreset=$(tput sgr0)

if [ "$OPTION" == "url" ]; then
  TIMEOUT=$3
  CODE=1
  echo -e "Blocking until <${URL}> responds...\nTimeout: ${TIMEOUT} seconds."

  while [ "$CODE" -ne 0 ]; do
    curl -sfk \
         --connect-timeout 3 \
         --max-time 5 \
         --fail \
         --silent \
         "${URL}" >/dev/null

    CODE=$?

    sleep 2
    echo -n "."

      if [ "$SECONDS" -ge "$TIMEOUT" ]; then
        echo "$txtred $URL is not available after $SECONDS seconds...stopping the install!"
        exit 1
      fi
    done;

elif [ "$OPTION" == "file" ]; then
  TARGET_SIZE=$3
  TIMEOUT=$4
  SIZE=0
  echo -e "Blocking until $URL is accessible...\nTimeout: $TIMEOUT seconds."

  while [ "$SIZE" -lt "$TARGET_SIZE" ]; do
    SIZE=$(curl -Isk $URL | grep Content-Length | awk '{print $2}' | tr -d '\r\n')

    sleep 2
    echo -n "."

    if [ "$SECONDS" -ge "$TIMEOUT" ]; then
      echo "$txtred $URL is not available after $SECONDS seconds...stopping the install!"
      exit 1
    fi
  done;

else
  echo "$txtred $OPTION is not a valid choice. Please use 'url' or 'file'!"
  exit 1
fi

echo -e "\n$txtbold$URL$txtreset is accessible!"
