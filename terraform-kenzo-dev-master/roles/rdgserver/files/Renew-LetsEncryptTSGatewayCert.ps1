try
{
  $logfile = 'C:\Program Files\LetsEncryptSimple\log.txt';
  $subject = "CN=rd.lithiumblue.com"

  Start-Transcript -Path $logfile -Append
  write-host "------------------------------------------------" # | out-file $logfile -Append
  write-host "Certificate renewal check $(Get-Date)" #| out-file $logfile -Append
  & 'C:\Program Files\LetsEncryptSimple\letsencrypt.exe' --renew --baseuri "https://acme-v01.api.letsencrypt.org/" #| out-file $logfile  -Append

  ipmo RemoteDesktopServices
  $existing = Get-Item -Path RDS:\GatewayServer\SSLCertificate\Thumbprint
  $current = dir cert:\localmachine\my | where-object { $_.Subject -eq $subject }

  write-host "Validating TSGateway certificates"
  if ($existing.CurrentValue -ne $current.Thumbprint)
  {
      Write-Warning "Certificate mismatch between TSGateway and cert store";
      Set-Item -Path RDS:\GatewayServer\SSLCertificate\Thumbprint -Value $current.Thumbprint ;
      Restart-Service TSGateway;
  }
  else
  {
      write-host "Certificates match between TSGateway and cert store"
  }
}
catch
{
  write-host $_.Exception.Message
}
finally
{
  Stop-Transcript
}
