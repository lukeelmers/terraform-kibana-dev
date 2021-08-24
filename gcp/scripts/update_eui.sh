#!/bin/bash
set -ex

# this script takes 1 arguments:
# $1=EUI PR to checkout

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" > /dev/null 2>&1 # This loads nvm

repo_url="https://github.com/elastic/eui.git"
branch="master"

if [ -n "$1" ]; then
  content=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/elastic/eui/pulls/${1})
  repo_url=$( jq -r  '.head.repo.html_url' <<< "${content}" )
  branch=$( jq -r  '.head.ref' <<< "${content}" )
fi

#stop kibana node processes
sudo systemctl stop kibana

cd ~/eui
git stash
git pull