#!/bin/sh
#
VOLUMES="/var/lib/docker/volumes"
INCLUDE='buildbot-worker-[[:alpha:]]+-[[:digit:]]+/_data/openvpn_2.*\.deb'
PUBLISH_SCRIPT="/root/openvpn-buildbot/buildbot-host/aptly/publish-aptly.sh"

inotifywait --format "%w%f" --event CREATE --monitor --recursive --include "${INCLUDE}" "${VOLUMES}" |\
    while read PACKAGE; do
        $PUBLISH_SCRIPT -p $PACKAGE -f /etc/aptly.pass
    done
