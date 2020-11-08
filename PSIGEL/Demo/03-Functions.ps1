#region Import Module PSIGEL

Import-Module -FullyQualifiedName C:\GitHub\PSIGEL\PSIGEL\PSIGEL.psd1

#endregion

#region Set parameters

$CredPath = 'C:\Credentials\UmsRmdb.cred'
$PSDefaultParameterValues = @{
  '*-UMS*:Computername' = 'igelrmserver'
  '*-UMS*:TCPPort'      = 9443 #Default 8443, here NAT to VirtualBox
}

#endregion

#region Create a websession

$WebSession = New-UMSAPICookie -Credential (Import-Clixml -Path $CredPath)
$PSDefaultParameterValues.Add('*-UMS*:WebSession', $WebSession)

#endregion

#region Check UMS Status

Get-UMSStatus

#endregion

#region Create new device directories
# with names SanFrancisco", Bremen, Augsburg and Leipzig

$NewDeviceDirectoryColl = 'SanFrancisco', 'Bremen', 'Augsburg', 'Leipzig' |
  New-UMSDeviceDirectory
$NewDeviceDirectoryColl

#endregion

#region Create new device
# with Mac address '00E0C5235065' and the latest firmware,
# using all supported properties

$LatestFirmware = (Get-UMSFirmware) |
  Sort-Object -Property Version -Descending |
  Select-Object -First 1

$Parent = ((Get-UMSDeviceDirectory).where{ $_.Name -eq 'Leipzig' })[0]

$Params = @{
  Mac           = '00E1C5235065'
  FirmwareId    = $LatestFirmware.Id
  AssetId       = '1101'
  Comment       = 'Comment'
  CostCenter    = '85500'
  Department    = 'Marketing'
  InserviceDate = 'InServiceDate'
  LastIP        = '192.168.56.3'
  Name          = 'DEV-1101'
  ParentId      = $Parent.Id
  SerialNumber  = '14D3F5001B18240065'
  Site          = $Parent.Name
}
$NewDeviceColl = New-UMSDevice @Params
$NewDeviceColl

#endregion

#region Move devices

$RootDeviceColl = (Get-UMSDevice).where{ $_.ParentId -eq -1 }
$i = 0
$j = $RootDeviceColl.Count
$k = $NewDeviceDirectoryColl.Count
($NewDeviceDirectoryColl).ForEach{
  $ParentDirectory = $_
  for ($l = $i; $l -le (($j / $k - 1) + $i); $l++)
  {
    $RootDeviceColl[$l] | Move-UMSDevice -DestId $ParentDirectory.Id
  }
  $i = $l
}

#endregion

#region Create new profile directories

$ProfileDirectoryColl = @(
  '01-Sessions'
  '02-Accessories'
  '03-UserInterface'
  '04-Network'
  '05-Devices'
  '06-Security'
  '07-System'
)
$ProfileDirectoryColl | New-UMSProfileDirectory

#endregion

#region Move profiles

$ProfileColl = Get-UMSProfile
$ProfileDirColl = Get-UMSProfileDirectory
$ProfileColl[0] | Move-UMSProfile -DestId $ProfileDirColl[0].Id
$ProfileColl[1] | Move-UMSProfile -DestId $ProfileDirColl[1].Id

#endregion

#region Update profiles

(Get-UMSProfile).foreach{
  $i = 1
  $s = (Get-UMSProfileDirectory -Id $_.ParentId)
  $_ | Update-UMSProfile -Name ( '{0}|{1:d2}' -f $s.Name, $i )
  $i++
}

#endregion

#region Update devices

$DepartmentColl = @{
  'Marketing' = @{
    Location = 'Augsburg'
    Number   = 10
  }
  'HR'        = @{
    Location = 'Bremen'
    Number   = 15
  }
  'Finance'   = @{
    Location = 'SanFrancisco'
    Number   = 5
  }
  'Support'   = @{
    Location = 'Leipzig'
    Number   = 25
  }
}

$DeviceDirectoryColl = Get-UMSDeviceDirectory
$DeviceColl = Get-UMSDevice

foreach ($Department in $DepartmentColl.GetEnumerator())
{
  $DepartmentDirectory = ($DeviceDirectoryColl).where{
    $_.Name -eq $Department.Value.Location
  }
  $UMSDirectoryRecursiveParams = @{
    DirectoryColl = $DeviceDirectoryColl
    ElementColl   = $DeviceColl
    Id            = $DepartmentDirectory.Id
  }
  Get-UMSDirectoryRecursive @UMSDirectoryRecursiveParams |
    Select-Object -First $Department.Value.Number |
    Update-UMSDevice -Department $Department.Key
}

#endregion

#region Assign profiles
# 01-Sessions|01 -> Location Augsburg
# 01-Sessions|01 -> Department HR
# 02-Accessories|01 -> DEV-1001, DEV-1040, DEV-1043

$DeviceDirectoryAugsburg = (Get-UMSDeviceDirectory).where{
  $_.Name -eq 'Augsburg'
}

$DeviceHRColl = (Get-UMSDevice -Filter details).where{
  $_.Department -eq 'HR'
}

$ProfileColl = Get-UMSProfile

$Sessions01 = (Get-UMSProfile).where{
  $_.Name -eq '01-Sessions|01'
}
$Accessories01 = (Get-UMSProfile).where{
  $_.Name -eq '02-Accessories|01'
}

$NewUMSProfileAssignmentParams = @{
  ReceiverId   = $DeviceDirectoryAugsburg.Id
  ReceiverType = 'tcdirectory'
}
$Sessions01 | New-UMSProfileAssignment @NewUMSProfileAssignmentParams

$DeviceHRColl.ForEach{
  $Sessions01 | New-UMSProfileAssignment -ReceiverId $_.Id -ReceiverType tc
}

(Get-UMSDevice).where{
  $_.Name -in 'DEV-1001', 'DEV-1040', 'DEV-1043'
} | ForEach-Object {
  $Accessories01 | New-UMSProfileAssignment -ReceiverId $_.Id -ReceiverType tc
}

#endregion

#region Pipeline device
# create, move, update and remove device in one pipeline

New-UMSDevice -Mac 001122334455 -FirmwareId 1 |
  Move-UMSDevice -DestId ((Get-UMSDeviceDirectory).where{
      $_.Name -eq 'Leipzig'
    }).Id -Confirm:$true |
  Update-UMSDevice -Name DEV-Leipzig01 -Confirm:$true |
  Reset-UMSDevice | Remove-UMSDevice

#endregion

#region Get devices in directory with name Leipzig

(Get-UMSDeviceDirectory -Filter children).where{
  $_.Name -eq 'Leipzig'
}.DirectoryChildren | Get-UMSDevice

#endregion

#region Get device assignment for profile '01-Sessions|01'

$ProfileAssignment = @(
  (Get-UMSProfile).where{ $_.Name -eq '01-Sessions|01' } |
    Get-UMSProfileAssignment
  (Get-UMSProfile).where{ $_.Name -eq '01-Sessions|01' } |
    Get-UMSProfileAssignment -Directory
)
$ProfileAssignment

#endregion

#region Get profile assignment for device 'DEV-1001'

(Get-UMSDevice).where{ $_.Name -eq 'DEV-1001' } | Get-UMSDeviceAssignment

#endregion

#region Get directories recurse

$UMSDirectoryRecursive = @{
  Id            = -1
  DirectoryColl = Get-UMSDeviceDirectory
}
Get-UMSDirectoryRecursive @UMSDirectoryRecursive

#endregion

#region region Remove all elements

Get-UMSProfile | Get-UMSProfileAssignment |
  Remove-UMSProfileAssignment -Confirm:$false
Get-UMSProfile | Get-UMSProfileAssignment -Directory |
  Remove-UMSProfileAssignment -Confirm:$false
Get-UMSProfile | Remove-UMSProfile -Confirm:$false
Get-UMSProfileDirectory | Remove-UMSProfileDirectory -Confirm:$false
Get-UMSDevice | Remove-UMSDevice -Confirm:$false
Get-UMSDeviceDirectory | Remove-UMSDeviceDirectory -Confirm:$false

#endregion

#region remove the used websession

Remove-UMSAPICookie
#$null = Remove-UMSAPICookie

#endregion
