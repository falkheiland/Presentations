#region init
#requires -modules SRXEnv
# https://www.powershellgallery.com/packages/SRXEnv
# Install-Module -Name SRXEnv

if (!(Test-Path .\Invoke-ScriptSRXEnv.ps1))
{
  throw 'Set Location to the path where this script is located!'
}

Import-Module SRXEnv -ErrorAction Stop

# load libraries
. .\Diverse\_LIB_\CommonLibrary.ps1
#endregion

#region stop full script execution via F5
throw 'use F8 to execute the regions individually!'
#endregion

#region Get-Service.ps1
Reset-SRXEnv
$cmdArgs = @{
  Property = 'Name', 'DisplayName', 'StartType', 'Status', 'UserName'
}
.\WinSystemManagement\Get-Services.ps1 @cmdArgs
$SRXEnv.ResultMessage
#endregion

#region Get-Services_Html.ps1
Reset-SRXEnv
$cmdArgs = @{
  Property = 'Name', 'DisplayName', 'StartType', 'Status', 'UserName'
}
.\WinSystemManagement\_REPORTS_\Get-Services_HTML.ps1 @cmdArgs
$SRXEnv.ResultHtml > .\Invoke-ScriptSRXEnv.html
#endregion

#region Get-Services_PSWriteHtml.ps1
Reset-SRXEnv
$cmdArgs = @{
  Property = 'Name', 'DisplayName', 'StartType', 'Status', 'UserName'
}
.\WinSystemManagement\_REPORTS_\Get-Services_PSWriteHTML.ps1 @cmdArgs
$SRXEnv.ResultHtml > .\Invoke-ScriptSRXEnv.html
#$SRXEnv.ResultMessage
#endregion