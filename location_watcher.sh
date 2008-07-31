#!/bin/bash

# automatically change configuration of Mac OS X based on location
# author: Onne Gorter <o.gorter@gmail.com>
# url: http://tech.inhelsinki.nl/locationchanger/
# version: 0.4
#
# 2008-07-31 UnderpantsGnome
#   moved all the execution to external files
#   modified to call external scripts based on the location
#   Made it easier to handle multiple locations
#   made it read a config file in ~/.location_watcher

# redirect all IO to /dev/null (comment this out if you want to debug)
# exec 1>/dev/null 2>/dev/null

# get a little breather before we get data for things to settle down
sleep 3

# get various system information
SSID=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I\
 | grep ' SSID:' | cut -d ':' -f 2 | tr -d ' '`
EN0IP=`ifconfig en0 | grep 'inet ' | cut -d' ' -f 2`
EN1IP=`ifconfig en1 | grep 'inet ' | cut -d' ' -f 2`

LOCATION='default'
USE_NOTIFICATIONS="true"

LOCATIONS=()
SSIDS=()
EN0IPS=()
EN1IPS=()

. HOME_DIR/.location_watcher

message() {
  if [ "true" = "$USE_NOTIFICATIONS" ]; then
    if [ -e GROWL_PATH ]; then
      GROWL_PATH -p ${2} -m "${1}" location_watcher ${3}
    else
      osascript -l AppleScript -e "tell Application \"Finder\" to display alert \"location_watcher $1\"" 
    fi
  fi
}

for (( i = 0 ; i < ${#LOCATIONS[@]} ; i++ )); do
  if [ "$SSID" = "${SSIDS[$i]}" ]; then
    REASON=$SSID
    LOCATION=${LOCATIONS[$i]}
    break
  fi

  if [ "$EN0IP" ! -e "" && "$EN0IP" = "${EN0IPS[$i]}" ]; then
    REASON=$EN0IP
    LOCATION=${LOCATIONS[$i]}
    break
  fi

  if [ "$EN1IP" ! -e "" && "$EN1IP" = "${EN1IPS[$i]}" ]; then
    REASON=$EN1IP
    LOCATION=${LOCATIONS[$i]}
    break
  fi
done

if [ $LOCATION ]; then
  SCRIPT="HOME_DIR/bin/location_watcher/${LOCATION}"

  if [ -f "${SCRIPT}" ]; then
    if [ -x "${SCRIPT}" ]; then
      $SCRIPT
      message "executed ${SCRIPT}" 1
    else
      message "${SCRIPT} exists, but it not executable" 2 -s
    fi
  else
    message "failed, ununable to find script, ${SCRIPT}" 2 -s
  fi
fi

# do some stuff here that needs to happen after every network change
echo `date` "Location: $LOCATION - $REASON" >> HOME_DIR/.locationchanger.log
exit 0
