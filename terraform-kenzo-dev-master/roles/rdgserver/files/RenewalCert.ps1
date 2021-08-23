Submit-Renewal

##Current certificate Thumbprint
$currentThumb = (Get-PACertificate).Thumbprint

 #Installed certificate thumbprint
Import-Module RemoteDesktopServices
$oldThumb = (Get-Item RDS:\GatewayServer\SSLCertificate\Thumbprint).CurrentValue

if ($oldThumb -ne $currentThumb) {

            try {

                $RDCB = "CBVM01.INTERNAL.DOMAIN.COM"
                $CertificateRDP = (Get-PACertificate).PfxFullChain
                $Password = ConvertTo-SecureString -String "your_password" -AsPlainText -Force

                Import-Module RemoteDesktop

                Set-RDCertificate -Role RDPublishing -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -force
                Set-RDCertificate -Role RDWebAccess -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -force
                Set-RDCertificate -Role RDRedirector -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -force
                Set-RDCertificate -Role RDGateway -ImportPath $CertificateRDP -Password $Password -ConnectionBroker $RDCB -Force
                Import-RDWebClientBrokerCert -Path $CertificateRDP -Password $Password

            } catch {throw}

} else {
    Write-Warning "Specified certificate is already configured"
}