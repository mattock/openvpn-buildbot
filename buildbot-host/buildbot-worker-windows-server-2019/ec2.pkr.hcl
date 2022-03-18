packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "buildbot_authenticode_cert" {
  type = string
}

variable "buildbot_authenticode_password" {
  type = string
}

variable "buildbot_windows_server_2019_buildbot_user_password" {
  type = string
}

variable "buildbot_windows_server_2019_ec2_region" {
  type = string
}

variable "buildbot_windows_server_2019_ec2_subnet" {
  type = string
  default = null
}

variable "buildbot_windows_server_2019_winrm_password" {
  type = string
}

variable "buildbot_windows_server_2019_worker_password" {
  type = string
}

variable "buildmaster_address" {
  type = string
}

source "amazon-ebs" "windows-server-2019" {
  communicator     = "winrm"
  force_deregister = true
  instance_type    = "t3a.xlarge"
  region           = var.buildbot_windows_server_2019_ec2_region
  subnet_id        = var.buildbot_windows_server_2019_ec2_subnet

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 80
    volume_type = "gp2"
    delete_on_termination = true
  }

  source_ami_filter {
    filters     = {
      name                = "Windows_Server-2019-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"]
  }
  user_data        = templatefile("${path.root}/../../pkrtpl/bootstrap_win.pkrtpl.hcl", { winrm_password = var.buildbot_windows_server_2019_winrm_password })
  winrm_password   = var.buildbot_windows_server_2019_winrm_password
  winrm_username   = "Administrator"
}

build {
  source "amazon-ebs.windows-server-2019" {
    name     = "buildbot-worker-windows-server-2019"
    ami_name = "buildbot-worker-windows-server-2019-3"
  }

  provisioner "file" {
    sources     = ["../../scripts/"]
    destination = "C:/Windows/Temp/scripts/"
  }

  provisioner "file" {
    sources     = [ var.buildbot_authenticode_cert ]
    destination = "C:/Windows/Temp/scripts/"
  }

  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/base.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/git.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/cmake.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/msibuilder.ps1 -workdir C:\\Windows\\Temp"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/python.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/pip.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/vsbuildtools.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/vcpkg.ps1 -workdir C:\\Users\\buildbot\\buildbot\\windows-server-2019-latent-ec2-msbuild"]
  }
  # Required for some installers
  provisioner "windows-restart" {}
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/build-deps.ps1 -workdir C:\\Users\\buildbot\\buildbot\\windows-server-2019-latent-ec2-msbuild"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/create-buildbot-user.ps1 -password ${var.buildbot_windows_server_2019_buildbot_user_password}"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/get-openvpn-vagrant.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/buildbot.ps1 -openvpnvagrant C:\\Users\\buildbot\\openvpn-vagrant -workdir C:\\Users\\buildbot\\buildbot -buildmaster ${var.buildmaster_address} -workername windows-server-2019-latent-ec2 -workerpass ${var.buildbot_windows_server_2019_worker_password} -user buildbot -password ${var.buildbot_windows_server_2019_buildbot_user_password}"]
  }
  provisioner "powershell" {
    # make sure to run user data scripts on first boot from AMI
    inline = ["C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule"]
  }
}
