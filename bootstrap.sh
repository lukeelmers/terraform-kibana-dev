#!/bin/bash
set -ex

# this script takes two arguments: $1=repo to clone, $2=branch to checkout
REPO=$1
BRANCH=$2

sudo apt-get update && sudo apt-get install build-essential -y
sudo sysctl -w fs.inotify.max_user_watches=524288 # need to increase this value to run Kibana in dev mode

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. $NVM_DIR/nvm.sh

# clone kibana repo, check out branch, and configure environment
git clone "$REPO.git"
cd kibana
git checkout $BRANCH
cp /tmp/kibana.dev.yml config/
touch kibana.log

# bootstrap kibana & run dev server
nvm install
npm install -g yarn
yarn kbn bootstrap
nohup yarn es snapshot &
nohup yarn start &
