# openvpn-buildbot

## Introduction

OpenVPN buildbot configuration files.

Right now these are highly specific to the official OpenVPN buildbot 
infrastructure, but making them more generic is definitely doable. A good place 
to start would be to load configuration (e.g. passwords, email addresses and 
URLs) from a separate configuration file.

The .gitignore file is set to ignore everything by default. This is because the 
buildmaster runtime directory is full of directories and files that are of no 
interest to Git.

The master.cfg has only been tested on Buildbot 0.8.6p1.

## License

These files are licensed under [CC-BY-SA 3.0](http://code.activestate.com/help/terms).
This license came about by accident when [external code](http://code.activestate.com/recipes/190465)
was integrated into master.cfg.

The actual buildmaster code is (C) 2016 OpenVPN Technologies, Inc. The 
permutation/combination functions are (C) 2003 Ulrich Hoffman.
