#!/bin/bash

IP=$3
NODE_NAME=$4

if [ "$1" == "-a" ]; then
   #/usr/sbin/ipset add wns $IP
fi

if [ "$1" == "-d" ]; then
  echo "removing node $NODE_NAME"
  salt-key -y -d $NODE_NAME
  #/usr/sbin/ipset del wns $IP
  echo "deleting carbon database for $NODE_NAME"
  rm -rf /var/lib/carbon/whisper/$NODE_NAME
fi

