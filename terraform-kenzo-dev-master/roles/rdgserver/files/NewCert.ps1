$CFParams = @{CFAuthEmail='youremail@domain.com'; CFAuthKey='***************************'}
$CertPass = "yoursupersecretpassword"

New-PACertificate '*.domain.com','*.internal.domain.com' -AcceptTOS -Contact youremail@domain.com -PfxPass $CertPass -DnsPlugin CloudFlare -PluginArgs $CFParams

$RDCB = "CBVM01.INTERNAL.DOMAIN.COM"
$CertificateRDP =  (Get-PACertificate).PfxFullChain
$Password = ConvertTo-SecureString -String "$CertPass" -AsPlainText -Force

Import-Module RemoteDesktop
Set-RDCertificate -Role RDPublishing -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -force
Set-RDCertificate -Role RDWebAccess -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -force
Set-RDCertificate -Role RDRedirector -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -force
Set-RDCertificate -Role RDGateway -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -force