#!/bin/bash
set -ex

# this script takes 3 arguments: $1=repo to clone, $2=branch to checkout, $3=PASSWORD of the elastic user
REPO=$1
BRANCH=$2
PASSWORD=$3

# need to increase this value to run Kibana in dev mode
sudo sysctl -w fs.inotify.max_user_watches=524288

[[ $PASSWORD != "changeme" ]] && PASSWORD_REPLACE="--password=${PASSWORD}" || PASSWORD_REPLACE=""

# Adaptions and deployment of systemd services
sudo sed -e "s/{PASSWORD}/${PASSWORD_REPLACE}/g" /tmp/elasticsearch.service > /tmp/elasticsearch.edited.service
sudo cp /tmp/elasticsearch.edited.service  /lib/systemd/system/elasticsearch.service
sudo cp /tmp/kibana.service  /lib/systemd/system/kibana.service
sudo systemctl daemon-reload

# Clone kibana repo, check out branch, and configure environment
git clone --branch "${BRANCH}" --single-branch --depth 1 "${REPO}.git" kibana
sudo touch /var/log/kibana.log
sudo chown ubuntu /var/log/kibana.log

# Configuration of Kibana
cp kibana/config/kibana.yml kibana/config/kibana.dev.yml
[[ $PASSWORD != "changeme" ]] && echo -e "\nelasticsearch.password: \"${PASSWORD}\"" >> kibana/config/kibana.dev.yml


