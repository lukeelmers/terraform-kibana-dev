#!/bin/bash
set -ex

# this script takes two arguments: $1=repo to clone, $2=branch to checkout
REPO=$1
BRANCH=$2

# need to increase this value to run Kibana in dev mode
sudo sysctl -w fs.inotify.max_user_watches=524288

# clone kibana repo, check out branch, and configure environment
git clone "$REPO.git"
git -C ~/kibana checkout $BRANCH
cp /tmp/kibana.dev.yml ~/kibana/config/
sudo touch /var/log/kibana.log
sudo chown ubuntu /var/log/kibana.log

sudo cp /tmp/kibana.service  /lib/systemd/system/
sudo cp /tmp/elasticsearch.service  /lib/systemd/system/
sudo systemctl daemon-reload
