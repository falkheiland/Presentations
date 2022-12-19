#Requires -Version 5.0

<#
  .SYNOPSIS
    Gets processes
    
  .DESCRIPTION
    Gets processes

  .NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner.
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner.
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function,
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

  .Parameter Property
    Properties of processes, empty for all
#>

param(
  [String[]]
  $Property
)

try
{
  $out = if ($null -ne $Property)
  {
    Get-Service | Select-Object -Property $Property | ConvertTo-Html
  }
  else
  {
    Get-Service | Select-Object -Property * | ConvertTo-Html
  }

  if ($SRXEnv)
  {
    $SRXEnv.ResultHtml = $out
  }
  else
  {
    Write-Output $out
  }
}
catch
{
  throw
}
finally
{
}