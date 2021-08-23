[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ServerFQDN,

    [Parameter(Mandatory=$true)]
    [string]$ConnectionBroker,

    [Parameter(Mandatory=$true)]
    [string]$SessionHost,

    [Parameter(Mandatory=$true)]
    [string]$PfxFilename,

    [Parameter(Mandatory=$true)]
    [string]$PfxPassword

)

try {
  $ErrorActionPreference = "Stop"

  Start-Transcript -Path c:\Deploy-RDGW.ps1.txt -Append

  # Reference https://docs.microsoft.com/en-us/powershell/module/remotedesktop/?view=win10-ps

  Import-Module RemoteDesktop

  New-RDSessionDeployment `
    -ConnectionBroker $ConnectionBroker `
    -SessionHost $SessionHost

  Set-RDDeploymentGatewayConfiguration `
    -GatewayMode Custom `
    -GatewayExternalFQDN $ServerFQDN `
    -LogonMethod AllowUserToSelectDuringConnection `
    -UseCachedCredentials $True `
    -BypassLocal $True `
    -ConnectionBroker $ConnectionBroker `
    -Force

  Add-RDServer `
    -Server $ConnectionBroker `
    -Role "RDS-GATEWAY" `
    -ConnectionBroker $ConnectionBroker `
    -GatewayExternalFqdn $ServerFQDN

  $PfxPasswordSecure = ConvertTo-SecureString -String "$PfxPassword" -AsPlainText -Force

  Import-PFXCertificate -FilePath "$PfxFilename" -CertStoreLocation Cert:\LocalMachine\Root -password $PfxPasswordSecure

  Set-RDCertificate `
    -Role RDRedirector `
    -ImportPath "$PfxFilename" `
    -Password $PfxPasswordSecure `
    -ConnectionBroker $ConnectionBroker `
    -Force

  Set-RDCertificate `
    -Role RDPublishing `
    -ImportPath "$PfxFilename" `
    -Password $PfxPasswordSecure `
    -ConnectionBroker $ConnectionBroker `
    -Force

  Set-RDCertificate `
    -Role RDGateway `
    -ImportPath "$PfxFilename" `
    -Password $PfxPasswordSecure `
    -ConnectionBroker $ConnectionBroker `
    -Force

  Restart-Service tsgateway

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
}

#new-rdvirtualdesktopdeployment -ConnectionBroker $ServerFQDN -SessionHost $ServerFQDN
#

#If you want to add an additional RD Session Host or RD Licensing
#Add-RDServer -Server srv1.ad.contoso.com -Role RDS-RD-SERVER -ConnectionBroker

#If you want remote apps
#New-RDSessionCollection –CollectionName PetriRemoteApps –SessionHost srv1.ad.contoso.com –CollectionDescription ‘Remote Apps’ –ConnectionBroker srv1.ad.contoso.com
#New-RDRemoteApp -Alias Wordpad -DisplayName WordPad -FilePath ‘C:\Program Files\Windows NT\Accessories\wordpad.exe’ -ShowInWebAccess 1 -CollectionName PetriRemoteApps -ConnectionBroker srv1.ad.contoso.com

#$Password = ConvertTo-SecureString -String "Cups34Horses&&" -AsPlainText -Force
#Set-RDCertificate -Role RDRedirector -ImportPath "C:\Certificates\Redirector07.pfx" -Password $Password -ConnectionBroker "RDCB.Contoso.com"

# Add-RDServer -Server $LicenseServer `
#   -Role RDS-LICENSING `
#   -ConnectionBroker $ConnectionBroker

# Set-RDLicenseConfiguration `
#   -LicenseServer $LicenseServer `
#   -Mode PerUser `
#   -ConnectionBroker $ConnectionBroker

# New-RDSessionCollection `
#   –CollectionName SessionDesktops `
#   –SessionHost $SessionHost `
#   –CollectionDescription 'Desktop sessions' `
#   –ConnectionBroker $ConnectionBroker

# New-RDSessionCollection -CollectionName "Session Collection 01" -SessionHost @("db0.dev.jiee-dev.com","web0.dev.jiee-dev.com") -CollectionDescription "Session collection for JIEE developers." -ConnectionBroker "rdg0.dev.jiee-dev.com"
