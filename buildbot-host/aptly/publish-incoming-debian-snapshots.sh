#!/bin/sh
#
VOLUMES="/var/lib/docker/volumes"
INCLUDE='buildbot-worker-[[:alpha:]]+-[[:digit:]]+/_data/openvpn_2.*\.deb'
PUBLISH_SCRIPT="publish-debian-snapshot.sh"
PASSWORD_FILE="/etc/aptly.pass"
APTLY_ROOTDIR="/var/lib/aptly"
HOOK_SCRIPT="/usr/local/bin/publish-debian-snapshot-hook.sh"

# Enable hook script, if any
HOOK_PARAMS=""
if [ -x "${HOOK_SCRIPT}" ]; then
    HOOK_PARAMS="-s ${HOOK_SCRIPT}"
fi

which $PUBLISH_SCRIPT > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: publish-debian-snapshot.sh not found in PATH"
    exit 1
fi

if ! [ -r "${PASSWORD_FILE}" ]; then
    echo "ERROR: GnuPG password file ${PASSWORD_FILE} not found!"
    exit 1
fi

# Ensure that aptly repo configuration is up-to-date
test -d $APTLY_ROOTDIR || mkdir -p $APTLY_ROOTDIR

# Create aptly repositories for each matching Buildbot worker Docker volume
MATCH='buildbot-worker-((debian|ubuntu)-[[:digit:]]+)'
for VOLUME in $(ls $VOLUMES|grep -E $MATCH); do
    DISTRO=$(echo $VOLUME|pcregrep -o1 $MATCH)
    aptly repo show $DISTRO > /dev/null 2>&1 || aptly repo create -architectures="amd64" -comment="Buildbot-generated packages for ${DISTRO}" -component="main" -distribution="${DISTRO}" $DISTRO
done

inotifywait --format "%w%f" --event CREATE --monitor --recursive --exclude t_client_ips.rc --exclude ccache "${VOLUMES}"/buildbot-worker-*/_data |\
    while read PACKAGE; do
        $PUBLISH_SCRIPT -p $PACKAGE -f $PASSWORD_FILE $HOOK_PARAMS
    done
