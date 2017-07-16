#!/bin/bash

if [ ! -f post_install/rundeck_restarted_$2 ]; then
  systemctl restart rundeckd
  scripts/check_url.sh url http://"$1":4440 60
  if [[ ! -z "$2" ]]; then
    su $SUDO_USER -c "touch post_install/rundeck_restarted_$2"
  fi
fi
