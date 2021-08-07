#!/bin/bash
set -ex

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm


cd ~/kibana
# bootstrap kibana & run dev server
nvm install
npm install -g yarn

# make node available for systemctl
# taken from https://stackoverflow.com/questions/21215059/cant-use-nvm-from-root-or-sudo
n=$(which node); \
n=${n%/bin/node}; \
chmod -R 755 $n/bin/*; \
sudo cp -r $n/{bin,lib,share} /usr/local

BUILD_TS_REFS_DISABLE=true yarn kbn bootstrap
