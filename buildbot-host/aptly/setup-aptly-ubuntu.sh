#!/bin/sh
#
# Set up aptly on Ubuntu
#
set -e

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A0546A43624A8331
echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list
apt-get update
apt-get install -y aptly
