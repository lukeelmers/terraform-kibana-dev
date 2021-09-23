#!/bin/bash
set -ex

# this script takes 1 arguments:
# $1=ELASTIC-CHARTS PR to checkout

repo_url="https://github.com/elastic/elastic-charts.git"
branch="master"

if [ -n "$1" ]; then
  content=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/elastic/elastic-charts/pulls/${1})
  repo_url=$( jq -r  '.head.repo.html_url' <<< "${content}" )
  branch=$( jq -r  '.head.ref' <<< "${content}" )
fi

if [ ! -d ~/elastic-charts ]
then
  git clone --branch "${branch}" --single-branch --depth 1 "${repo_url}"
fi
ploy
