#!/bin/bash

#set -x

YAMAHA_IP="192.168.111.81"
VOLUMIO_INPUT="line2"

VOLUMIO_STATUS=$(volumio status | jq -r '.status')

function read_yamaha () {
    YAMAHA_STATUS=$(curl -s ${YAMAHA_IP}/YamahaExtendedControl/v1/main/getStatus)
    YAMAHA_POWER=$(jq -r '.power' <<< ${YAMAHA_STATUS})
    YAMAHA_INPUT=$(jq -r '.input' <<< ${YAMAHA_STATUS})
}

echo ${VOLUMIO_STATUS}

if [ "${VOLUMIO_STATUS}" = "play" ]; then
    read_yamaha
    if [ "${YAMAHA_POWER}" != "on" ]; then
        echo "power on"
        curl -s "http://${YAMAHA_IP}/YamahaExtendedControl/v1/main/setPower?power=on"
        sleep 8
    fi
    if [ "${YAMAHA_INPUT}" != "${VOLUMIO_INPUT}"  ]; then
        echo "input=${VOLUMIO_INPUT}"
        curl -s "http://${YAMAHA_IP}/YamahaExtendedControl/v1/main/setInput?input=${VOLUMIO_INPUT}"
    fi
fi
