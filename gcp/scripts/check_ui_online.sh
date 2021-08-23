#!/bin/bash

kibana_syslog=/var/log/syslog

grep -m 1 "bundles compiled successfully" <(tail -f -n +1 $kibana_syslog)
