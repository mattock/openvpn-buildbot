param ([string] $workdir)

. C:\Windows\Temp\scripts\ps_support.ps1

Write-Host "Setting up openvpn build dependencies with vcpkg"

if (-Not (Test-Path $workdir)) {
  New-Item -Type directory $workdir
  CheckLastExitCode
}

Add-MpPreference -ExclusionPath $workdir
CheckLastExitCode

if (-Not (Test-Path "${workdir}\openvpn")) {
  & git.exe clone -b master https://github.com/OpenVPN/openvpn.git "${workdir}\openvpn"
  CheckLastExitCode
}

if (-Not (Test-Path "${workdir}\openvpn-build")) {
  & git.exe clone https://github.com/OpenVPN/openvpn-build.git "${workdir}\openvpn-build"
  CheckLastExitCode
}

if (-Not (Test-Path "${workdir}\openvpn-gui")) {
  & git.exe clone https://github.com/OpenVPN/openvpn-gui.git "${workdir}\openvpn-gui"
  CheckLastExitCode
}

# Install OpenVPN build dependencies
$architectures = @('x64','x86','arm64')
foreach ($arch in $architectures) {
    & "${workdir}\vcpkg\vcpkg.exe" --overlay-ports="${workdir}\openvpn\contrib\vcpkg-ports" --overlay-triplets="${workdir}\openvpn\contrib\vcpkg-triplets" install "lz4:${arch}-windows-ovpn" "lzo:${arch}-windows-ovpn" "openssl3:${arch}-windows-ovpn" "pkcs11-helper:${arch}-windows-ovpn" "tap-windows6:${arch}-windows-ovpn"
    CheckLastExitCode
}

# Ensure that we can convert the man page from rst to html
& pip.exe --no-cache-dir install docutils
