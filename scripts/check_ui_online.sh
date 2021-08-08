#!/bin/bash

kibana_log=/var/log/kibana.log
kibana_syslog=/var/log/syslog

if [ -e $kibana_log ] ; then
    grep -m 1 "Kibana is now available" <(tail -f -n +1 $kibana_log)
    echo "✅ Kibana server running..."
    grep -m 1 "bundles compiled successfully" <(tail -f -n +1 $kibana_syslog)
    echo "✅ Kibana bundles have been compiled..."
fi

echo "Kibana is online and status is green"