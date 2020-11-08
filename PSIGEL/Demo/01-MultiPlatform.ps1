$PSVersionTable

$DSC = [IO.Path]::DirectorySeparatorChar
$PSIGELPath = 'GitHub{0}PSIGEL{0}PSIGEL{0}PSIGEL.psd1' -f $DSC

$PSDefaultParameterValues = @{
  '*-UMS*:Computername' = 'igelrmserver'
  '*-UMS*:TCPPort'      = 9443
  '*-UMS*:Confirm'      = $False
}

if (($PSEdition -eq 'Core' -and $IsWindows) -or ($PSEdition -eq 'Desktop' -and ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 1)))
{
  # PS7 on Windows or Windows PowerShell 5.1
  Import-Module -FullyQualifiedName ('C:\{0}' -f $PSIGELPath) -Force
  $PSDefaultParameterValues.Add('New-UMSAPICookie:Credential',
    (Import-Clixml -Path 'C:\Credentials\UmsRmdb.cred'))
}
elseif ($PSEdition -eq 'core' -and (-Not $IsWindows) )
{
  # PS7 on Linux OR MacOS
  Import-Module -FullyQualifiedName ('/mnt/c/{0}' -f $PSIGELPath) -Force
  # Dont use the following method in production,
  # since on linux the clixml file is not encrypted
  $PSDefaultParameterValues.Add('New-UMSAPICookie:Credential',
    (Import-Clixml -Path '/mnt/c/Credentials/UmsRmdbWsl.cred'))
}

$WebSession = New-UMSAPICookie
$PSDefaultParameterValues.Add('*-UMS*:WebSession', $WebSession)

Get-UMSStatus

$null = Remove-UMSAPICookie -WebSession $WebSession