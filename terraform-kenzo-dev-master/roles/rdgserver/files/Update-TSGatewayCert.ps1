import RemoteDesktopServices
$subject =  "CN=rd.lithiumblue.com”
$existing = Get-Item -Path RDS:\GatewayServer\SSLCertificate\Thumbprint
$current = dir cert:\localmachine\my | where-object { $_.Subject -eq $subject }
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