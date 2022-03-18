# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vagrant.plugins = [ "vagrant-vbguest" ]

  config.vm.define "buildbot-host" do |box|
    box.vm.box = "generic/ubuntu2004"
    box.vm.box_version = "3.4.2"
    box.vm.hostname = "buildbot-host"
    box.vm.network "private_network", ip: "192.168.59.114"
    box.vm.synced_folder ".", "/vagrant"
    box.vm.provision "shell",
      inline: "/bin/sh /vagrant/buildbot-host/provision.sh"
    box.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = 8096
      #vb.customize ["modifyvm", :id, "--cpus", "4"]
    end
    box.vm.provider "hyperv" do |hv, override|
      hv.maxmemory = 8096
      hv.memory = 8096
    end
  end

  config.vm.define "buildbot-worker-windows-server-2019" do |box|
    box.vm.box = "gusztavvargadr/windows-server"
    box.vm.box_version = "1809.0.2012"
    box.winrm.max_tries = 90
    box.winrm.retry_delay = 2
    box.winrm.timeout = 360
    box.vm.boot_timeout = 360
    box.vm.hostname = "buildbot-worker-windows-server-2019"
    box.vm.network "private_network", ip: "192.168.59.115"
    box.vm.synced_folder ".", "/vagrant"
    box.vm.provision "shell", path: "scripts/evaltimer.ps1"
    box.vm.provision "shell", path: "scripts/base.ps1"
    box.vm.provision "shell", path: "scripts/git.ps1"
    box.vm.provision "shell", path: "scripts/cmake.ps1"
    box.vm.provision "shell", path: "scripts/msibuilder.ps1"
    box.vm.provision "shell", path: "scripts/python.ps1"
    box.vm.provision "shell", path: "scripts/pip.ps1"
    box.vm.provision "shell", path: "scripts/vsbuildtools.ps1"
    box.vm.provision "shell" do |s|
      s.path = "scripts/vcpkg.ps1"
      s.args = ["-workdir", "C:\\users\\vagrant\\buildbot\\windows-server-2019-static-msbuild"]
    end
    box.vm.provision "shell", path: "scripts/reboot.ps1"
    box.vm.provision "shell" do |s|
      s.path = "scripts/build-deps.ps1"
      s.args = ["-workdir", "C:\\users\\vagrant\\buildbot\\windows-server-2019-static-msbuild",
                "-openvpn_ref", "master",
                "-openvpn_build_ref", "master",
                "-openvpn_gui", "master",
                "-openssl", "openssl3"]
    end
    box.vm.provision "file", source: "buildbot-host/buildbot.tac", destination: "C:\\Windows\\Temp\\buildbot.tac"
    box.vm.provision "shell", inline: "C:\\vagrant\\scripts\\buildbot.ps1 -workdir C:\\Users\\vagrant\\buildbot -buildmaster 192.168.59.114 -workername windows-server-2019-static -workerpass vagrant -user vagrant -password vagrant"
    box.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.cpus = 2
      vb.memory = 3072
    end
    box.vm.provider "hyperv" do |hv, override|
      hv.maxmemory = 3072
      hv.memory = 3072
    end
  end

  config.vm.define "buildbot-worker-ubuntu-2004" do |box|
    box.vm.box = "generic/ubuntu2004"
    box.vm.box_version = "3.4.2"
    box.vm.hostname = "buildbot-worker-ubuntu-2004"
    box.vm.network "private_network", ip: "192.168.59.116"
    box.vm.synced_folder ".", "/vagrant"
    box.vm.provision "shell",
      inline: "/bin/sh /vagrant/buildbot-host/scripts/setup-buildbot-ubuntu.sh"
    box.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = 1280
    end
  end
end
