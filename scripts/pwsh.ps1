Write-Host "Installing pwsh"
& choco.exe install -y pwsh --install-arguments='"REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1"'
