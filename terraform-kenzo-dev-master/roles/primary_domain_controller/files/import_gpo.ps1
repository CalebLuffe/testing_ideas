#Run one time to get GPO into a file
#Backup-GPO -Name "RemoteRDP" -Path C:\Scripts
#Install-Module BaselineManagement
#Import-Module BaselineManagement
#CD C:\Scripts
#ConvertFrom-GPO -Path "C:\Temp\{F4C92AE9-BA8F-4A70-9E47-B9C6F77DD367}" -OutputConfigurationScript
#RoboCopy C:\Temp c:\scripts
#Add to bootstrap process

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$DCPath,

    [Parameter(Mandatory=$true)]
    [string]$SecurityGroups,

    [Parameter(Mandatory=$true)]
    [string]$GpoFolder

)

try {
  $ErrorActionPreference = "Stop"

  New-ADGroup "RemoteUsers" `
    -Path "DC=Dev,DC=kenzo-dev,dc=com" `
    -GroupCategory Security `
    -GroupScope Global `
    -PassThru -Verbose

  Add-AdGroupMember -Identity RemoteUsers -Members "Domain Users"

  New-GPO -name RemoteUsersRestored
  New-GPlink -Name RemoteUsersRestored -Target "dc=dev,dc=kenzo-dev,dc=com" -LinkEnabled Yes
  Import-GPO -BackupGPOName RemoteRDP -TargetName RemoteUsersRestored -path c:\Scripts

}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
}
