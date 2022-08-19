#!/bin/sh
#
set -ex

# NOTE: we don't install mbedtls on CentOS 7 because it is too old

# pkcs11-helper-dev is only available in the EPEL repository
yum -y install epel-release
yum install -y scl-utils centos-release-scl-rh

yum -y install \
autoconf \
autoconf-archive \
automake \
bzip2 \
cmake3 \
devtoolset-10 \
fping \
gcc \
gcc-c++ \
git \
glib2-devel \
gnutls-devel \
iproute \
jsoncpp-devel \
libcap-devel \
libcap-ng-devel \
libcmocka-devel \
libtool \
libuuid-devel \
libxml2 \
lz4-devel \
lzo-devel \
make \
mbedtls-devel \
openssl-devel \
pam-devel \
pkcs11-helper-devel \
pkgconfig \
polkit \
python36 \
python36-dbus \
python36-gobject \
python36-pyOpenSSL \
python3-devel \
python-docutils \
python3-pip \
python3-setuptools \
python3-wheel \
selinux-policy-devel \
tinyxml2 \
tinyxml2-devel \
zlib-devel

echo "source /opt/rh/devtoolset-10/enable" >> /etc/profile
echo "source /opt/rh/devtoolset-10/enable" >> /etc/bashrc

# This is required for CentoOS 7 where "cmake" is missing, but "cmake3" is
# present.
test -e /usr/bin/cmake || ln -s /usr/bin/cmake3 /usr/bin/cmake
