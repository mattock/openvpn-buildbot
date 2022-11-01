#!/bin/sh
#
# Install buildbot
#
set -ex

BUILDBOT_VERSION=3.5.0

# hardcode cryptography version since newer don't work on CentOS 7
pip3 install --upgrade pip && \
pip --no-cache-dir install cryptography==37.0.4 && \
pip --no-cache-dir install twisted[tls] && \
pip --no-cache-dir install buildbot_worker==$BUILDBOT_VERSION

useradd --create-home --home-dir=/var/lib/buildbot buildbot
