#!/bin/sh
#
# Install GDBus++ :: glib2 D-Bus C++ interface
#
# This is a prerequisite for building openvpn3-linux. We don't use "set -e" here
# because meson exit code may be non-zero (e.g. 130) even if all went well.
#
if [ "${INSTALL_GDBUSPP}" = "yes" ]; then
    git clone https://codeberg.org/OpenVPN/gdbuspp.git
    cd gdbuspp
    meson setup --prefix=/usr _builddir
    cd _builddir
    meson compile
    meson install
    ldconfig
fi
