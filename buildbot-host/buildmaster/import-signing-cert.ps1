param ([string] $workdir,
       [string] $password,
       [string] $fingerprint)

# Even though we connect to WinRM as "Administrator", internally WinRM uses the "Network Service" account. Therefore trying to import the certificate to
# Cert:\CurrentUser\My fails:
#
# <https://social.technet.microsoft.com/Forums/en-US/a07dab5a-3ad2-4982-84c1-28f7d4ba77f9/import-certificate-into-certcurrentusermy>
#
# That's why we run this script in buildbot, not during provisioning
#
if ( ! (Get-Item Cert:\CurrentUser\My\${fingerprint}) ) {
  $certfile = (Get-ChildItem $workdir -Filter *.pfx).fullname
  Import-PfxCertificate -FilePath $certfile -CertstoreLocation Cert:\CurrentUser\My -Password (ConvertTo-SecureString -String $password -Force -AsPlainText)
}
