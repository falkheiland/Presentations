#region Set parameters
[Int]$NumberOfDevice = 100
$SerialNumberStart = '14D3F5001B18240'
$MACAddressStart = '00E0C5235'
[int]$InventoryNumberStart = '1000'
$DemoPath = 'C:\GitHub\Presentations\PSIGEL\Demo\'
$InventoryCsv = '{0}\Inventory.csv' -f $DemoPath
$ImportIgelSerialNumber = '{0}\ImportIgelSerialNumber.csv' -f $DemoPath
#endregion

#region create Inventory list (procurement department)
$InventoryColl = 1..$NumberOfDevice  | ForEach-Object { 
  [PSCustomObject]@{
    InventoryNumber = $InventoryNumberStart++
    SerialNumber    = '{0}{1}' -f $SerialNumberStart, $_.ToString("X3")
  }
}
$InventoryColl | ConvertTo-Csv -NoTypeInformation -Delimiter ';' |
  Select-Object -Skip 1 |
  ForEach-Object { $_.Replace('"', '') } |
  Out-File $InventoryCsv

code $InventoryCsv
#endregion

#region create Import Igel SerialNumber list (IGEL reseller)
# https://kb.igel.com/endpointmgmt-6.05/en/import-with-igel-serial-number-31599394.html

$ImportIgelSerialNumberColl = 1..$NumberOfDevice  | ForEach-Object { 
  [PSCustomObject]@{
    0            = ''
    SerialNumber = '{0}{1}' -f $SerialNumberStart, $_.ToString("X3")
    MACAddress   = '{0}{1}' -f $MACAddressStart, $_.ToString("X3")
    3            = ''
    4            = ''
  }
}
$ImportIgelSerialNumberColl | ConvertTo-Csv -NoTypeInformation -Delimiter ';' |
  Select-Object -Skip 1 |
  ForEach-Object { $_.Replace('"', '') } |
  Out-File $ImportIgelSerialNumber

code $ImportIgelSerialNumber
#endregion