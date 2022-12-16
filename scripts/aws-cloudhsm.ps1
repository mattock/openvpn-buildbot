param ([string] $workdir,
       [string] $configfiles)

Write-Host "Installing AWSCloudHSMClient"

. C:\Windows\Temp\scripts\ps_support.ps1

# Note: uses SDK v3 for import-key.exe
Invoke-WebRequest https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Windows/AWSCloudHSMClient-latest.msi -Outfile C:\AWSCloudHSMClient-latest.msi

Start-Process msiexec.exe -ArgumentList '/i C:\AWSCloudHSMClient-latest.msi /quiet /norestart /log C:\client-install.txt' -Wait
CheckLastExitCode

Write-Host "Installing config files for signing"

Copy-Item "${configfiles}\customerCA.crt" C:\ProgramData\Amazon\CloudHSM\customerCA.crt -Force
CheckLastExitCode

certutil -user -addstore my "${configfiles}\signingCert.p7b"
CheckLastExitCode

Copy-Item "${configfiles}\build-and-package-env.ps1" "${workdir}\openvpn-build\windows-msi" -Force
