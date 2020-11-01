#region Start Windows Terminal

wt -p "Windows | Windows PowerShell (5.1)" `; new-tab -p "Windows | PowerShell 7.0.3 (Core)" `; new-tab -p "Ubuntu |  PowerShell 7.0.3 (Core)" `; focus-tab -t 0

#endregion

#region Set Parameter

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
  $PSDefaultParameterValues.Add('New-UMSAPICookie:Credential', (Import-Clixml -Path 'C:\Credentials\UmsRmdb.cred'))
}
elseif ($PSEdition -eq 'core' -and (-Not $IsWindows) )
{
  # PS7 on Linux OR MacOS
  Import-Module -FullyQualifiedName ('/mnt/c/{0}' -f $PSIGELPath) -Force
  # Dont use the following method in production, since on linux the clixml file is not encrypted
  $PSDefaultParameterValues.Add('New-UMSAPICookie:Credential', (Import-Clixml -Path '/mnt/c/Credentials/UmsRmdbWsl.cred'))
}

$WebSession = New-UMSAPICookie
$PSDefaultParameterValues.Add('*-UMS*:WebSession', $WebSession)

#endregion

#region Get-UMSStatus

$UMSStatus = Get-UMSStatus
$UMSStatus

#endregion

#region Get-Firmware

$FirmwareColl = Get-UMSFirmware
$FirmwareColl

#endregion

#region Get latest Firmeware

$LatestFirmware = $FirmwareColl | Sort-Object -Property Version -Descending |
  Select-Object -First 1
$LatestFirmware

#endregion

#region Set Comment "Update" on device with older firmwares

$CommentUpdateColl = (Get-UMSDevice).where{ $_.FirmwareId -ne $LatestFirmware.Id } |
  Update-UMSDevice -Comment 'Update'
$CommentUpdateColl

#endregion

#region Get online Device information on Devicees with Comment "Update"

$DeviceOnlineColl = $CommentUpdateColl | Get-UMSDevice -Filter online
$DeviceOnlineColl

#endregion

#region Get Departments with device that have comment Comment "Update"

$DeviceDirectoryColl = Get-UMSDeviceDirectory
$DepartmentUpdateColl = ($DeviceDirectoryColl).Where{
  $_.ID -in $DeviceOnlineColl.ParentId
}
$DepartmentUpdateColl

#endregion

#region Remove-UMSAPICookie

$null = Remove-UMSAPICookie -WebSession $WebSession

#endregion