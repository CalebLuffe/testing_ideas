[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ServerFQDN,

    [Parameter(Mandatory=$true)]
    [string]$ConnectionBroker,

    [Parameter(Mandatory=$true)]
    [string]$PfxFilename,

    [Parameter(Mandatory=$true)]
    [string]$PfxPassword

)

try {
  $ErrorActionPreference = "Stop"

  Start-Transcript -Path c:\Deploy-RDGW.ps1.txt -Append

  # Reference https://docs.microsoft.com/en-us/powershell/module/remotedesktop/?view=win10-ps

  Enable-PSRemoting -Force

  Import-Module RemoteDesktop

  Add-RDServer `
    -Server "" `
    -Role "RDS-GATEWAY" `
    -ConnectionBroker `
    "RDCB.Contoso.com" `
    -GatewayExternalFqdn "ExternalFQDN.NorthWindTraders.com"

  $PfxPasswordSecure = ConvertTo-SecureString -String "$PfxPassword" -AsPlainText -Force

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

