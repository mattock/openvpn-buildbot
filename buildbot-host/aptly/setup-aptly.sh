#!/bin/sh
#
# Set up aptly
#
set -e

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A0546A43624A8331
echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list
apt-get update
apt-get install -y aptly pcregrep
mkdir -p /var/lib/aptly
cp -v aptly.conf /etc/aptly.conf

for DISTRO in \
  debian-11 \
  debian-12 \
  ubuntu-2204 \
  ubuntu-2404
do
    aptly repo show $DISTRO > /dev/null 2>&1 || aptly repo create -architectures="amd64" -comment="Buildbot-generated packages for ${DISTRO}" -component="main" -distribution="${DISTRO}" $DISTRO
done
