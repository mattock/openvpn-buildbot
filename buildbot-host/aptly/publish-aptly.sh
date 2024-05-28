#!/bin/sh
#
# Publish packages to an apt repository
#
# Exit on any error
set -e

usage() {
    echo "Usage: aptly-publish.sh -f <file> -p <passphrase-file> [-h]"
    echo
    echo "Options:"
    echo "    -f    the debian (.deb) package to publish"
    echo "    -p    GPG passphrase file"
    echo "    -h    show this help"
    echo
    exit 2
}

while getopts 'f:p:h' arg
do
  case $arg in
    p) PACKAGE=$OPTARG ;;
    f) PASSPHRASE_FILE=$OPTARG ;;
    h) usage ;;
  esac
done

# Ensure that mandatory parameters have been defined
if [ "x${PACKAGE}" = "x" ] || [ "x${PASSPHRASE_FILE}" = "x" ]; then
    usage
fi

# Only accept absolute paths
echo $PACKAGE|grep "^/" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: must provide absolute path to the package!"
    usage
fi

if ! [ -r "${PACKAGE}" ]; then
    echo "ERROR: package ${PACKAGE} not found!"
    exit 1
fi

if ! [ -r "${PASSPHRASE_FILE}" ]; then
    echo "ERROR: passphrase file ${PASSPHRASE_FILE} not found!"
    exit 1
fi

MATCH='/buildbot-worker-([[:alpha:]]+-[[:digit:]]+)/'
REPO=$(echo "${PACKAGE}"|pcregrep -o1 $MATCH) || true

if [ "x${REPO}" = "x" ]; then
    echo "ERROR: unable to determine repository name from package file path:"
    echo
    echo $PACKAGE
    echo
    echo "Ensure that file path matches pattern ${MATCH}"
    exit 1
fi

echo "Publishing $(basename $PACKAGE) in repository ${REPO}"

aptly repo add $REPO $PACKAGE

PUBLISH_PARAMS="-batch -passphrase-file=$PASSPHRASE_FILE $REPO filesystem:$REPO:."
aptly publish repo $PUBLISH_PARAMS 2> /dev/null || aptly publish update $PUBLISH_PARAMS
