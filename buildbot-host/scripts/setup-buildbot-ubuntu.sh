#!/bin/sh
#
# Standalone script to set up an Ubuntu buildbot worker using files from
# openvpn-vagrant/buildbot-host
#
if [ "$1" = "" ]; then
    BUILDBOT_HOST_DIR=/vagrant/buildbot-host
else
    BUILDBOT_HOST_DIR=$1
fi

# Install build dependencies for OpenVPN
mkdir -p /buildbot
cd /buildbot
$BUILDBOT_HOST_DIR/scripts/install-openvpn-build-deps-ubuntu.sh

# Set up buildbot worker
$BUILDBOT_HOST_DIR/scripts/install-buildbot.sh
cp $BUILDBOT_HOST_DIR/buildbot.tac /buildbot/
mkdir -p /home/buildbot
