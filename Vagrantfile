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
    box.vm.provision "file", source: "scripts", destination: "C:\\Windows\\Temp\\scripts"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\evaltimer.ps1"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\base.ps1"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\git.ps1"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\cmake.ps1"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\msibuilder.ps1 -workdir C:\\Users\\vagrant\\Downloads"
    box.vm.provision "shell", inline: "powershell.exe C:\\Windows\\Temp\\scripts\\python.ps1"
    box.vm.provision "shell", inline: "powershell.exe C:\\Windows\\Temp\\scripts\\pip.ps1"
    box.vm.provision "shell", inline: "powershell.exe C:\\Windows\\Temp\\scripts\\vsbuildtools.ps1"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\vcpkg.ps1 -workdir C:\\Users\\vagrant\\Downloads"
    box.vm.provision "shell", inline: "powershell.exe C:\\Windows\\Temp\\scripts\\reboot.ps1"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\build-deps.ps1 -workdir C:\\users\\vagrant\\buildbot\\windows-server-2019-static-msbuild"
    box.vm.provision "shell", inline: "C:\\Windows\\Temp\\scripts\\buildbot.ps1 -openvpnvagrant C:\\vagrant -workdir C:\\Users\\vagrant\\buildbot -buildmaster 172.30.55.25 -workername windows-server-2019-static -workerpass vagrant -user vagrant -password vagrant"
    box.vm.provider "virtualbox" do |vb|
      vb.gui = false
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
