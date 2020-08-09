#!/bin/bash
oldopt=$-
set -euxo pipefail
echo "Old options '$oldopt'"
echo "Shell is $SHELL"
id -a
uname -a
getent passwd $USER

sudo apt-get install -y libpq-dev libpcap0.8-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
#source /etc/profile.d/rvm.sh

echo -n "set '$-' -> "
set +euxo pipefail
echo " '$-'"
source /home/admin/.rvm/scripts/rvm
echo -n "set '$-' -> "
set -euxo pipefail
echo " '$-'"
if [ ! -d metasploit-framework ]; then
  git clone https://github.com/rapid7/metasploit-framework
  echo -n "set '$-' -> "
  set +euxo pipefail
  echo " '$-'"
  cd metasploit-framework
  echo -n "set '$-' -> "
  set -euxo pipefail
  echo " '$-'"
else
  echo "Exists, will pull"
  echo -n "set '$-' -> "
  set +euxo pipefail
  echo " '$-'"
  cd metasploit-framework
  git pull --ff-only
  echo -n "set '$-' -> "
  set -euxo pipefail
  echo " '$-'"
fi
echo -n "set '$-' -> "
set +euxo pipefail
echo " '$-'"
rvm install ruby-$(cat .ruby-version)
echo -n "set '$-' -> "
set -euxo pipefail
echo " '$-'"
#gem install bundler --no-ri --no-rdoc
gem install bundler --no-document
#gem install bundler
bundle install
