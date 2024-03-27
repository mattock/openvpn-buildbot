Write-Host "Installing dependencies for building MSI packages"

. $PSScriptRoot\ps_support.ps1

# Chocolatey package doesn't install correctly
#& choco.exe install -y wixtoolset

Invoke-WebRequest -Uri "https://github.com/wixtoolset/wix3/releases/download/wix3141rtm/wix314.exe" -Outfile "C:\Windows\Temp\wix314.exe"

& "C:\Windows\Temp\wix314.exe" /q
CheckLastExitCode

# Add WiX tools to PATH. Adapted from https://www.yudhistiramauris.com/add-new-entry-to-path-variable-permanently-using-windows-powershell
$wixpath = "C:\Program Files (x86)\WiX Toolset v3.14\bin"
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path

# Only append to PATH when required
ForEach ($path in $oldpath.split(";")) {
    if ($path -eq $wixpath) {
        exit 0
    }
}

$newpath = "$oldpath;$wixpath"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath
