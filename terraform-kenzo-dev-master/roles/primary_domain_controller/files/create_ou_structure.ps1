param (

[Parameter(
    Mandatory = $True,
    HelpMessage = 'Please provide the path of the CSV file containing the OU name and OU path')]
    [String]$pathofcsvfile,
[Parameter(Mandatory = $true)]
    [string]$domainName
)

$result = @{data = ""; domain = "" };

try {

  $oufile = Import-Csv $pathofcsvfile

  # check for domain configured
  start-sleep -s 3

  $nltestresults = ((nltest /dsgetdc:$domainName) -replace ":", "=" |
    Where-Object {$_ -match "="}) -join "`r`n" |
    ConvertFrom-StringData

  new-object -TypeName PSCustomObject -Property $nltestresults | Out-null

  if (($nltestresults.Count -eq 0)) {
    Fail-Json -obj $result -message "Unable to connect to domain $domainName please check configuration"
  }
  elseif (($nltestresults.'Dom Name').ToLower() -eq ($domainName).ToLower()) {
    #Create the loop
    $domainfound = "$nltestresults.'Dom Name'"
    $result.domain += "$domainfound domain found"

    foreach ($entry in $oufile) {

      $ouname = $entry.ouname
      $oupath = $entry.oupath

      ## Validation, if the OU is already exist
      $ouidentity = "OU=" + $ouname + "," + $oupath
      $oucheck = [adsi]::Exists("LDAP://$ouidentity")

      ## Condition of creation
      if ($oucheck -eq "True") {
        # Write-Output $result.msg = "OU $ouname is already exist in the location $oupath"
        $result.data += "OU $ouname is already exist in the location $oupath`n"
      }
      else {

        ## Create the OU with Accidental Deletion enabled
        $result.msg += "Creating the OU $ouname .....`n"

        New-ADOrganizationalUnit -Name $ouname -Path $oupath

        # $result.msg = "OU $ouname is created in the location $oupath"
        $result.data += "OU $ouname is created in the location $oupath`n"

      }
    }
  }
  else {
    Fail-Json -obj $result -message "Domain $domainName Not Found"
  }

  Exit-Json -obj $result

}
catch {
  Fail-Json -obj $result -message "Exception.Message=$($_.Exception.Message); ScriptStackTrace=$($_.ScriptStackTrace); Exception.StackTrace=$($_.Exception.StackTrace); FullyQualifiedErrorId=$($_.FullyQualifiedErrorId); Exception.InnerException=$($_.Exception.InnerException)"
}
