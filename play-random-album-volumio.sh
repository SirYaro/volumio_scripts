#!/bin/bash

#set -x

VOLUMIO='music.lan'

####

ACTION=$1

function f_addAlbum()
{
    ALBUMS_COUNT=$(( $(curl -s http://${VOLUMIO}/api/v1/collectionstats | jq .albums) - 1 ))
    RANDOM_ALBUM_NUM=$(shuf --input-range=0-${ALBUMS_COUNT} -n 1)
    ALBUM_DATA=$(curl -s "http://${VOLUMIO}/api/v1/browse?uri=albums://" | jq -r ".navigation.lists[].items[${RANDOM_ALBUM_NUM}]")

    curl -s http://${VOLUMIO}/api/v1/commands/?cmd=clearQueue
    curl -s --header "Content-Type: application/json" "http://${VOLUMIO}/api/v1/replaceAndPlay" --data "${ALBUM_DATA}" > /dev/null
}

if [ "$ACTION" == "single" ]; then
    f_addAlbum
    exit
fi

x=always; while x=always;
do
    STATUS=$(curl -s http://${VOLUMIO}/api/v1/getState | jq -r .status)

    if [ "$STATUS" = "stop" ]; then
	f_addAlbum
    fi
    sleep 15
done
