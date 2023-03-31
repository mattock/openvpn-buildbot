build {
  source "amazon-ebs.windows-server-2022" {
    name     = "msitest-windows-server-2022"
    ami_name = "msitest-agent-windows-server-2022-2"
  }

  provisioner "file" {
    sources     = ["../../scripts/"]
    destination = "C:/Windows/Temp/scripts/"
  }
  provisioner "powershell" {
    only   = ["amazon-ebs.msitest-windows-server-2022"]
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' status --block"]
  }
  provisioner "file" {
    sources     = ["ta/"]
    destination = "C:/TA"
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/base.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/pwsh.ps1"]
  }
  provisioner "powershell" {
    elevated_password = var.windows_server_winrm_password
    elevated_user     = local.user_name
    inline            = ["C:/Windows/Temp/scripts/openssh.ps1 -configfiles C:\\TA"]
  }
  # Required for some installers
  #provisioner "windows-restart" {}
  provisioner "powershell" {
    only = ["amazon-ebs.msitest-windows-server-2022"]
    # make sure to run user data scripts on first boot from AMI
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' reset --clean"]
  }

}
