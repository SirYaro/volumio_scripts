#!/bin/bash

#set -x

function read_yamaha () {
    YAMAHA_STATUS=$(curl -s ${YAMAHA_IP}/YamahaExtendedControl/v1/main/getStatus)
    YAMAHA_POWER=$(jq -r '.power' <<< ${YAMAHA_STATUS})
    YAMAHA_INPUT=$(jq -r '.input' <<< ${YAMAHA_STATUS})
}


YAMAHA_IP="192.168.111.81"
VOLUMIO_INPUT="line2"
VOLUMIO_STATUS=$(volumio status | jq -r '.status')
TIMESTAMP=$(date +%s)
STANDBY_MINUTES=30
FILE="/tmp/standbytime.txt"

#############################

read_yamaha
STANDBY_SECONDS=$((${STANDBY_MINUTES}*60))

if [ "$YAMAHA_INPUT" = "$VOLUMIO_INPUT" ] && [ "$VOLUMIO_STATUS" != "play" ] && [ "$YAMAHA_POWER" = "on" ]; then

    TIME=$(cat "$FILE" 2>/dev/null) 

    if [ -z ${TIME} ]; then
	echo ${TIMESTAMP} > ${FILE}
    elif [ $((${TIME} + ${STANDBY_SECONDS})) -lt ${TIMESTAMP} ]; then
	echo "Standby"
	curl -s "http://${YAMAHA_IP}/YamahaExtendedControl/v1/main/setPower?power=standby"
	rm -f ${FILE}
    fi

fi