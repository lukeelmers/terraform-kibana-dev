#!/bin/bash
echo "Pull latest changes from git repo"
sudo systemctl stop elasticsearch
sudo systemctl stop kibana
cd ~/kibana || exit
yarn kbn clean
git pull
echo "Pull latest changes from git repo - successful"
