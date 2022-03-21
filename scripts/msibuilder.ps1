Write-Host "Installing dependencies for building MSI packages"

# Chocolatey package bundles WiX version too old for building ARM64 MSIs.
#& choco.exe install -y wixtoolset

# Invoke-Webrequest seems to exit before the installer has been completely
# downloaded, resulting in a silent WiX installation failure. Therefore we
# wrap it into a Job to ensure that the installer has downloaded before
# attempting to run it.
Start-Job -Name "GetWiX" -ScriptBlock { Invoke-WebRequest -Uri https://wixtoolset.org/downloads/v3.14.0.4118/wix314.exe -Outfile "C:\Windows\Temp\wix314.exe" }
Wait-Job -Name "GetWiX"

& "C:\Windows\Temp\wix314.exe" /q

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
