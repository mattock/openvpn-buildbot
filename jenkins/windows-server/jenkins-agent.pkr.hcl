build {
  source "amazon-ebs.windows-server-2019" {
    name     = "jenkins-agent-windows-server-2019"
    ami_name = "jenkins-agent-windows-server-2019-3"
  }
  source "amazon-ebs.windows-server-2022" {
    name     = "jenkins-agent-windows-server-2022"
    ami_name = "jenkins-agent-windows-server-2022-1"
  }

  provisioner "file" {
    sources      = [ "../../scripts/" ]
    destination  = "C:/Windows/Temp/scripts/"
  }
  provisioner "powershell" {
    only  = ["amazon-ebs.jenkins-agent-windows-server-2022"]
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' status --block"]
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
  # Required for some installers
  provisioner "windows-restart" {}
  provisioner "powershell" {
    inline = ["C:/Windows/Temp/scripts/jenkins-agent.ps1 -workdir C:\\Jenkins -jenkins ${var.jenkinsmaster_address} -user buildbot -password ${var.windows_server_buildbot_user_password}"]
  }
  provisioner "powershell" {
    only  = ["amazon-ebs.jenkins-agent-windows-server-2019"]
    # make sure to run user data scripts on first boot from AMI
    inline = ["C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule"]
  }
  provisioner "powershell" {
    only  = ["amazon-ebs.jenkins-agent-windows-server-2022"]
    # make sure to run user data scripts on first boot from AMI
    inline = ["& 'C:/Program Files/Amazon/EC2Launch/EC2Launch.exe' reset --clean"]
  }
}
