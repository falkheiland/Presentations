#region Import Module PSIGEL

Import-Module -FullyQualifiedName C:\GitHub\PSIGEL\PSIGEL\PSIGEL.psd1

#endregion

#region Set parameters

$CredPath = 'C:\Credentials\UmsRmdb.cred'
$PSDefaultParameterValues = @{
  '*-UMS*:Computername' = 'igelrmserver'
  '*-UMS*:TCPPort'      = 9443 #Default 8443, here NAT to VirtualBox
}
$DemoPath = 'C:\GitHub\Presentations\PSIGEL\Demo\'

#endregion

#region Create a websession

$WebSession = New-UMSAPICookie -Credential (Import-Clixml -Path $CredPath)
$PSDefaultParameterValues.Add('*-UMS*:WebSession', $WebSession)

#endregion

#region Check UMS Status

Get-UMSStatus

#endregion

#region Import Igel SerialNumber List

$ImportIgelSerialNumberProps = @{
  Path      = ('{0}ImportIgelSerialNumber.csv' -f $DemoPath)
  Delimiter = ';'
  Header    = '0', 'SerialNumber', 'MacAddress', '2', '3'
}
$ImportIgelSerialNumberColl = Import-Csv @ImportIgelSerialNumberProps
$ImportIgelSerialNumberColl

#endregion

#region Import Inventory List

$InventoryParams = @{
  Path      = ('{0}Inventory.csv' -f $DemoPath)
  Delimiter = ';'
  Header    = 'InventoryNumber', 'SerialNumber'
}
$InventoryColl = Import-Csv @InventoryParams
$InventoryColl

#endregion

#region Join Igel SerialNumber and Inventory List
# http://ramblingcookiemonster.github.io/Join-Object/
# or part of https://github.com/falkheiland/CommonTools

Import-Module -FullyQualifiedName C:\GitHub\CommonTools\CommonTools\CommonTools.psd1

$NewDeviceCollParams = @{
  Left              = $ImportIgelSerialNumberColl
  LeftJoinProperty  = 'SerialNumber'
  LeftProperties    = 'SerialNumber', 'MacAddress'
  Right             = $InventoryColl
  RightJoinProperty = 'SerialNumber'
  RightProperties   = 'InventoryNumber'
  Type              = 'AllInLeft'
}
$NewDeviceColl = Join-Object @NewDeviceCollParams
$NewDeviceColl

#endregion

#region Create the new devices

$DevicePrefix = 'DEV-'
$FirmwareId = (Get-UMSFirmware | Sort-Object -Property Version -Descending |
    Select-Object -First 1).Id

$CreatedDeviceColl = foreach ($NewDevice in $NewDeviceColl)
{
  $NewDeviceParams = @{
    Mac          = $NewDevice.MacAddress
    FirmwareId   = $FirmwareId
    Name         = '{0}{1}' -f $DevicePrefix, $NewDevice.InventoryNumber
    SerialNumber = $NewDevice.SerialNumber
    AssetId      = $NewDevice.InventoryNumber
  }
  New-UMSDevice @NewDeviceParams
}
$CreatedDeviceColl

#endregion

#region Remove the used websession

$null = Remove-UMSAPICookie

#endregion