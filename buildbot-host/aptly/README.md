# aptly support in openvpn-build

The openvpn-buildbot contains scripts for publishing Debian/Ubuntu packages in
local aptly repositories. The local aptly repositories can then be rsynced to a
remote repository if so desired.

# Basic architecture

Debian packages are created by Buildbot workers and save to Docker volumes. On
the Docker host ("buildbot-host") a systemd service called
*aptly-publish.service* uses *inotifywait* to monitor those Docker volumes.
When new Debian packages appear *aptly-publish.service* runs a script that
autodetects the operating system from the filesystem path, adds the package to
the repository and publishes it.

This architecture does not require aptly or its dependencies to be configured
on each Buildbot worker. Aptly runs directly on the Docker host instead of in a
container to minimize implementation complexity.

# Package dependencies

Aptly support depends on the following packages:

* [aptly](https://www.aptly.info)
* gnupg (2.x)
* pcregrep

Some dependencies should be installed by default. Those which are not can and
should be installed with [setup-aptly.sh](setup-aptly.sh).

# Assumptions

Currently aptly support makes a few assumptions:

* The first GnuPG private key found in the default keyring is used to sign packages
* */etc/aptly.pass* contains the passphrase for the GnuPG private key

# Repository layout

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

As can be seen each distro's packages are completely isolated from other
distros' packages.
