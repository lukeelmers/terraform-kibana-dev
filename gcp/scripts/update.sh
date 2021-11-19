#!/bin/bash
echo "Pull latest changes from kibana git repo"
sudo systemctl stop elasticsearch
sudo systemctl stop kibana
cd ~/kibana || exit
yarn kbn clean
git stash
git pull
echo "Pull latest changes from kibana git repo - successful"
cd ..

if [ -d "$HOME/eui" ]
then
  echo "Pull latest changes from EUI git repo"
  # bootstrap EUI with the given EUI package
  cd ~/eui || exit
  git stash
  git pull
  echo "Pull latest changes from EUI git repo - successful"
  cd ..
fi

if [ -d "$HOME/elastic-charts" ]
then
  echo "Pull latest changes from Elastic charts git repo"
  # bootstrap Elastic charts with the given EUI package
  cd ~/elastic-charts || exit
  git stash
  git pull
  echo "Pull latest changes from Elastic charts git repo - successful"
  cd ..
fi
