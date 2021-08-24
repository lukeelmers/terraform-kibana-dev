#!/bin/bash

kibana_online=false
while [ $kibana_online == false ]; do
  content=$(curl -s http://elastic:changeme@localhost:5601/api/status)
  state=$( jq -r  '.status.overall.state' <<< "${content}" )
  if [[ $state == 'green' ]]
  then
    kibana_online=true
  else
    sleep 5
  fi;
done