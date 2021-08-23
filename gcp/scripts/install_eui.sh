#!/bin/bash
set -ex

# this script takes 1 arguments:
# $1=EUI PR to checkout

repo_url="https://github.com/elastic/eui.git"
branch="master"

if [ -n "$1" ]; then
  content=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/elastic/eui/pulls/${1})
  repo_url=$( jq -r  '.head.repo.html_url' <<< "${content}" )
  branch=$( jq -r  '.head.ref' <<< "${content}" )
fi

# clone eui repo, check out branch, and build
if [ ! -d ~/eui ]
then
 git clone "$repo_url"
fi

cd ~/eui
git checkout "$branch"

