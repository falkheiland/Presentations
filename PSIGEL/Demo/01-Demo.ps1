#region Import Module PSIGEL
Import-Module -FullyQualifiedName C:\GitHub\PSIGEL\PSIGEL\PSIGEL.psd1
#endregion

#region set parameters
$CredPath = 'C:\Credentials\UmsRmdb.cred'
$PSDefaultParameterValues = @{
  '*-UMS*:Computername' = 'igelrmserver'
  '*-UMS*:TCPPort'      = 9443 #Default 8443, here NAT to VirtualBox
}
#endregion

#region create a websession
$WebSession = New-UMSAPICookie -Credential (Import-Clixml -Path $CredPath)
$PSDefaultParameterValues.Add('*-UMS*:WebSession', $WebSession)
#endregion

#region get all firmwares
$FirmwareColl = Get-UMSFirmware
$FirmwareColl
#endregion

#region get latest firmware
$LatestFirmware = $FirmwareColl | Sort-Object -Property Version -Descending |
  Select-Object -First 1
$LatestFirmware
#endregion

#region remove a comment "update" from all devices with the latest firmware
$null = Get-UMSDevice -Filter details | Where-Object {
  $_.Comment -eq 'update' -and $_.FirmwareId -eq $LatestFirmware.Id
} | Update-UMSDevice -Comment ''
#endregion

#region get all online devices that do not have the latest firmware
# because the devices here are non bon existing, $false is used for online detection
$UpdateDeviceColl = Get-UMSDevice -Filter online | Where-Object {
  $_.Online -eq $false -and $_.FirmwareId -ne $LatestFirmware.Id
}
$UpdateDeviceColl
#endregion

#region set a comment "update" to all devices with not the latest firmware
$UpdateDeviceColl | Update-UMSDevice -Comment 'update'
#endregion

#region remove the used websession
$null = Remove-UMSAPICookie
#endregion

#region create view and job
promptly after the execution of this script, a scheduled job "update on Shutdown"
on a view for all devices with the comment "update" should start in the UMS.
#endregion