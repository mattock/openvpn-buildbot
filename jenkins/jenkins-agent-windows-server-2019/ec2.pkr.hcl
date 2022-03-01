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

variable "jenkinsmaster_address" {
  type = string
}

source "amazon-ebs" "windows-server-2019" {
  communicator     = "winrm"
  force_deregister = true
  instance_type    = "t3a.large"
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
    name     = "jenkins-agent-windows-server-2019"
    ami_name = "jenkins-agent-windows-server-2019-1"
  }

  provisioner "file" {
    sources      = [ "../../scripts/" ]
    destination  = "C:/Windows/Temp/"
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/base.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/git.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/cmake.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/python.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/pip.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/vcpkg.ps1 -workdir C:\\Jenkins"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/vsbuildtools.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/create-buildbot-user.ps1 -password ${var.buildbot_windows_server_2019_buildbot_user_password}"]
  }
  # Required for some installers
  provisioner "windows-restart" {}
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/jenkins-agent.ps1 -workdir C:\\Jenkins -jenkins ${var.jenkinsmaster_address} -user buildbot -password ${var.buildbot_windows_server_2019_buildbot_user_password}"]
  }
  provisioner "powershell" {
    # make sure to run user data scripts on first boot from AMI
    inline = ["C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule"]
  }

}
