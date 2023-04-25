#!/bin/sh
#
# Install buildbot
#
set -ex

BUILDBOT_VERSION=3.7.0

# hardcode cryptography version since newer don't work on CentOS 7
pip3 install $PIP_INSTALL_OPTS --upgrade pip
pip --no-cache-dir install $PIP_INSTALL_OPTS cryptography==37.0.4
pip --no-cache-dir install $PIP_INSTALL_OPTS twisted[tls]
pip --no-cache-dir install $PIP_INSTALL_OPTS buildbot_worker==$BUILDBOT_VERSION

useradd --create-home --home-dir=/var/lib/buildbot buildbot
