#!/bin/bash
set -ex

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" > /dev/null 2>&1 # This loads nvm

if [ -d "$HOME/eui" ]
then
  echo "Building EUI package"
  # bootstrap kibana with the given EUI package
  cd ~/eui
  nvm install
  nvm use
  npm install -g yarn
  yarn install
  yarn build
  npm pack
  package=$(ls -t | head -n1)
  cd ~/kibana
  git stash
  cp "package.json" "package.json.backup"
  sed -e "s/\"@elastic\/eui\": \"[0-9]*.[0-9]*.[0-9]*\"/\"@elastic\/eui\": \"..\/eui\/${package}\"/g" package.json > package.json.new
  mv -- package.json.new package.json
fi

if [ -d "$HOME/elastic-charts" ]
then
  echo "Building elastic-charts package"
  # bootstrap kibana with the given elastic chart package
  cd ~/elastic-charts
  nvm install
  nvm use
  npm install -g yarn
  yarn install
  yarn build
  cd ~/elastic-charts/packages/charts
  npm pack
  package=$(ls -t | head -n1)
  cd ~/kibana
  git stash
  cp "package.json" "package.json.backup"
  sed -e "s/\"@elastic\/charts\": \"[0-9]*.[0-9]*.[0-9]*\"/\"@elastic\/charts\": \"..\/elastic-charts\/packages\/charts\/${package}\"/g" package.json > package.json.new
  mv -- package.json.new package.json
fi

cd ~/kibana
# bootstrap kibana & run dev server
nvm install
nvm use
npm install -g yarn

# make node available for systemctl
# taken from https://stackoverflow.com/questions/21215059/cant-use-nvm-from-root-or-sudo
n=$(which node); \
n=${n%/bin/node}; \
chmod -R 755 $n/bin/*; \
sudo cp -r $n/{bin,lib,share} /usr/local

BUILD_TS_REFS_DISABLE=true yarn kbn bootstrap --no-validate
