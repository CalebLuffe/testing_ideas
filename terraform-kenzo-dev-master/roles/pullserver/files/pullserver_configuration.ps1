Configuration PullServer {
  Import-DscResource -ModuleName xPSDesiredStateConfiguration


          # Load the Windows Server DSC Service feature
          WindowsFeature DSCServiceFeature
          {
            Ensure = 'Present'
            Name = 'DSC-Service'
          }

          # Use the DSC Resource to simplify deployment of the web service
          xDSCWebService PSDSCPullServer
          {
            Ensure = 'Present'
            EndpointName = 'PSDSCPullServer'
            Port = 8080
            PhysicalPath = "$env:SYSTEMDRIVE\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint = 'AllowUnencryptedTraffic'
            ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State = 'Started'
            DependsOn = '[WindowsFeature]DSCServiceFeature'
            UseSecurityBestPractices = $false
          }

  }
  PullServer -OutputPath 'C:\scripts\PullServerConfig\'
  Start-DscConfiguration -Wait -Force -Verbose -Path 'C:\scripts\PullServerConfig\'