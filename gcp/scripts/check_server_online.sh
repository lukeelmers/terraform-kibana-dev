#!/bin/bash

kibana_syslog=/var/log/syslog
grep -m 1 "Kibana is now available" <(tail -f -n +1 $kibana_syslog)
