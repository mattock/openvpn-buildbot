#!/bin/sh
#
# Create "publish-incoming-debian-snapshots" Debian package
#
set -e

SRC=$(dirname -- "$( readlink -f -- "$0"; )";)/..
FILES_FOUND=yes

if [ "x${SRC}" = "x" ]; then
  echo "ERROR: unable to determine source directory!"
  exit 1
fi

for FILE in \
    "${SRC}/publish-debian-snapshot.sh" \
    "${SRC}/publish-incoming-debian-snapshots.sh" \
    "${SRC}/publish-incoming-debian-snapshots.service"
do
    if ! [ -r "${FILE}" ]; then
        echo "ERROR: ${FILE} missing, cannot build!"
	FILES_FOUND=no
    fi
done

if [ "${FILES_FOUND}" = "no" ]; then
    exit 1
fi

# Construct the package layout
rm -rf "${SRC}/target"
mkdir -vp "${SRC}/target/etc/systemd/system"
mkdir -vp "${SRC}/target/usr/local/bin"

cp -v "${SRC}/publish-debian-snapshot.sh" "${SRC}/target/usr/local/bin/"
cp -v "${SRC}/publish-incoming-debian-snapshots.sh" "${SRC}/target/usr/local/bin/"
cp -v "${SRC}/publish-incoming-debian-snapshots.service" "${SRC}/target/etc/systemd/system/"
cp -v "${SRC}/aptly.conf" "${SRC}/target/etc/"

fpm \
  -t deb \
  --force \
  --name "publish-incoming-debian-snapshots" \
  --description "Publish new Debian and Ubuntu packages created by Buildbot workers in aptly repositories" \
  --license "BSD-2-Clause" \
  --vendor "OpenVPN project" \
  --maintainer "Samuli Seppänen <samuli.seppanen@gmail.com>" \
  --url "https://github.com/OpenVPN/openvpn-buildbot" \
  --version "0.10.0" \
  --iteration "1" \
  --after-install "${SRC}/fpm/after-install.sh" \
  --after-upgrade "${SRC}/fpm/after-upgrade.sh" \
  --after-remove "${SRC}/fpm/after-remove.sh" \
  --deb-no-default-config-files \
  -d 'aptly >= 1.5.0' \
  -d 'inotify-tools >= 3.22.0' \
  -d 'gnupg >= 2.2.0' \
  -d 'pcregrep >= 2' \
  -C "${SRC}/target" \
  -s dir .

rm -rf "${SRC}/target"
