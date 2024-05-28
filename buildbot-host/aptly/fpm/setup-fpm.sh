#!/bin/sh
#
# Install fpm and its dependencies
#
set -e
apt-get update
apt-get -y install ruby binutils
gem install fpm
