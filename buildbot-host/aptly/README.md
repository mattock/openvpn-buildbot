# Automatic Debian/Ubuntu snapshot publishing

## Introduction

The openvpn-buildbot repository contains everything needed to publish
Debian/Ubuntu packages in local aptly repositories. The local aptly
repositories can then be rsynced to a remote repository if so desired
using a separate hook script.

## Basic workflow

The package publishing workflow is the following:
1. On dockerized buildbot workers (Debian/Ubuntu)
    1. Build the Debian packages
    1. Save the Debian packages  to their respective Docker volumes
1. On buildbot (docker) host
    1. A systemd service monitors the Docker volumes for new packages using *inotifywait*. When it notices a new package it launches the aptly publishing script.
    1. The publishing script GPG-signs and publishes the package in a local, per-distro (e.g. *debian-12*, *ubuntu-2404*) aptly repository
    1. An optional hook script runs and is passed the repository name (e.g. *debian-12*) as its first parameters; the script can, for example, rsync the updated per-distro repository over to a remote server

This workflow does not require aptly or its dependencies to be configured on
each buildbot worker. Aptly runs directly on the buildbot (docker) host instead
of in a container to further minimize implementation complexity.

## Setup

Debian packages need to be signed. For this to work you must import a private
GPG key used to sign the packages. The key must be in the default GnuPG keyring
of the root user.  The keyring should not have any other keys in it or aptly
might get confused.

In addition you must add the GPG private key passphrase to */etc/aptly.pass*
and set its ownership and mode properly (e.g. root:root and 0400).

Next install aptly. On Ubuntu:

    cd openvpn-buildbot/buildbot-host/aptly
    ./setup-aptly-ubuntu.sh

You can do the rest with a simple Debian package install:

    dpkg -i publish-incoming-debian-snapshots_0.9.14-1_amd64.deb

If you don't have the package you can generate it with
[fpm](https://fpm.readthedocs.io/en/latest/index.html). First install fpm:

    cd openvpn-buildbot/buildbot-host/aptly/fpm
    ./setup-fpm.sh

Then build the package (can be done from any directory):

    cd openvpn-buildbot/buildbot-host/aptly/fpm
    ./package.sh

## Using auto-publishing

Tail the systemd service to check if auto-publishing is working:

    journalctl -n0 -f --unit=publish-incoming-debian-snapshots.service

When a buildbot worker finishes a debian packaging build you should see output like this:

```
Publishing openvpn_2.7-1716968802_amd64.deb in repository debian-11
Loading packages...
[+] openvpn_2.7-1716968802_amd64 added
Generating metadata files and linking package files...
Finalizing metadata files...
Signing file 'Release' with gpg, please enter your passphrase when prompted:
Clearsigning file 'Release' with gpg, please enter your passphrase when prompted:
Cleaning up prefix "." components main...
Publish for local repo filesystem:debian-11:./debian-11 [amd64] publishes {main: [debian-11]: Buildbot-generated packages for debian-11)
has been successfully updated.
```

## Configuring an auto-publishing hook

The auto-publishing script supports running a hook script after a package has
been added to the local aptly repository. The script path is expected to be
*/usr/local/bin/publish-debian-snapshot-hook.sh*. If that script is present and
is executable it will run automatically whenever a package is added to an aptly
repository. It gets the aptly repository name (e.g. *debian-12*) as its first
parameter.

A simple hook script might look like this:

    #!/bin/sh
    #
    # /usr/local/bin/publish-debian-snapshot-hook.sh
    #
    mkdir -p /var/www/html/apt
    rsync -va /var/lib/aptly/public/$1 /var/www/html/apt/

This copies the updated aptly repository into a different directory on the
local filesystem.

# Local aptly repository layout

The out-of-the-box aptly configuration creates a repository layout like this:

```
$ tree /var/lib/aptly/public/
/var/lib/aptly/public/
└── debian-12
    ├── dists
    │   └── debian-12
    │       ├── Contents-amd64.gz
    │       ├── InRelease
    │       ├── Release
    │       ├── Release.gpg
    │       └── main
    │           ├── Contents-amd64.gz
    │           └── binary-amd64
    │               ├── Packages
    │               ├── Packages.bz2
    │               ├── Packages.gz
    │               └── Release
    └── pool
        └── main
            └── o
                └── openvpn
                    └── openvpn_2.7-1716445794_amd64.deb

10 directories, 10 files
```

Each distro's packages are completely isolated from other distros' packages.
