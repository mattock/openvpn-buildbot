packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  ami_name = "msitest-agent-windows-server-2022-2"
  user_name = "Administrator"
}

variable "windows_server_2022_ec2_region" {
  type = string
}

variable "windows_server_2022_ec2_subnet" {
  type = string
  default = null
}

variable "windows_server_2022_winrm_password" {
  type = string
}

source "amazon-ebs" "windows-server-2022" {
  communicator     = "winrm"
  force_deregister = true
  instance_type    = "t3a.large"
  region           = var.windows_server_2022_ec2_region
  subnet_id        = var.windows_server_2022_ec2_subnet

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 80
    volume_type = "gp2"
    delete_on_termination = true
  }

  source_ami_filter {
    filters     = {
      #name                = "Windows_Server-2022-English-Full-Base-*"
      name = "Windows_Server-2022-English-Full-Base-2022.10.12"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"]
  }
  user_data        = templatefile("${path.root}/../../pkrtpl/bootstrap_win.pkrtpl.hcl", { winrm_password = var.windows_server_2022_winrm_password })
  winrm_password   = var.windows_server_2022_winrm_password
  winrm_username   = local.user_name

  tags          = {
    Name          = local.ami_name
    SourceAMI     = "{{ .SourceAMI }}"
    SourceAMIName = "{{ .SourceAMIName }}"
    Login         = local.user_name
  }
  snapshot_tags = {
    Name          = local.ami_name
  }
}

build {
  source "amazon-ebs.windows-server-2022" {
    name     = "msitest-windows-server-2022"
    ami_name = local.ami_name
  }

  provisioner "file" {
    sources      = [ "../../scripts/" ]
    destination  = "C:/Windows/Temp/scripts/"
  }
  provisioner "powershell" {
    only  = ["amazon-ebs.msitest-windows-server-2022"]
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' status --block"]
  }
  provisioner "file" {
    sources      = [ "ta/" ]
    destination  = "C:/TA"
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/base.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/pwsh.ps1"]
  }
  provisioner "powershell" {
    elevated_password = var.windows_server_2022_winrm_password
    elevated_user     = local.user_name
    inline = ["C:/Windows/Temp/scripts/openssh.ps1 -configfiles C:\\TA"]
  }
  # Required for some installers
  #provisioner "windows-restart" {}
  provisioner "powershell" {
    only  = ["amazon-ebs.msitest-windows-server-2022"]
    # make sure to run user data scripts on first boot from AMI
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' reset --clean"]
  }

}
