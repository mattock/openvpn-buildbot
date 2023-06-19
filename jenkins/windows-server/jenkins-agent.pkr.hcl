build {
  source "amazon-ebs.windows-server-2019" {
    name     = "jenkins-agent-windows-server-2019"
    ami_name = "jenkins-agent-windows-server-2019-5-${local.timestamp}"
  }
  source "amazon-ebs.windows-server-2022" {
    name     = "jenkins-agent-windows-server-2022"
    ami_name = "jenkins-agent-windows-server-2022-3-${local.timestamp}"
  }

  provisioner "file" {
    sources     = ["../../scripts/"]
    destination = "C:/Windows/Temp/scripts/"
  }
  provisioner "file" {
    sources     = ["jenkins/"]
    destination = "C:/config"
  }
  provisioner "powershell" {
    only   = ["amazon-ebs.jenkins-agent-windows-server-2022"]
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' status --block"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/base.ps1"]
  }
  provisioner "powershell" {
    elevated_password = var.windows_server_winrm_password
    elevated_user     = local.user_name
    inline            = ["C:/Windows/Temp/scripts/openssh.ps1 -configfiles C:\\config"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/git.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/cmake.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/python.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/pip.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/swig.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/vcpkg.ps1 -workdir C:\\Jenkins"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/vsbuildtools.ps1"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/create-buildbot-user.ps1 -password ${var.windows_server_buildbot_user_password}"]
  }
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/jenkins-agent-ssh.ps1 -workdir C:\\Jenkins"]
  }
  # Required for some installers
  provisioner "windows-restart" {}
  provisioner "powershell" {
    only = ["amazon-ebs.jenkins-agent-windows-server-2019"]
    # make sure to run user data scripts on first boot from AMI
    inline = ["C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule"]
  }
  provisioner "powershell" {
    only = ["amazon-ebs.jenkins-agent-windows-server-2022"]
    # make sure to run user data scripts on first boot from AMI
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' reset --clean"]
  }
}
