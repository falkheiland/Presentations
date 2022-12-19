#Requires -Version 5.0

<#
.SYNOPSIS
    Removes files depending on filter, age and / or number sorted by age

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner.
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner.
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function,
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.Parameter Path
    Specifies the folder name

.Parameter Filter
    Specifies a filter for the file selection.

.Parameter Days
    Specifies the number of days for the retention of files.

.Parameter Count
    Specifies the number of files, sorted by LastWriteTime, for the retention of files

.Parameter And
    Switch for the use of Days and Count, when both specified, for the retention of files

.Parameter Or
    Switch for the use of Days or Count, when both specified, for the retention of files

.Parameter Credential
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter SRXConfirm
    ScriptRunner Emulated Confirm

.Parameter SRXWhatIf
    ScriptRunner Emulated WhatIf

.EXAMPLE
    $cmdArgs = @{
      Path    = 'C:\Temp'
      Filter  = '*.html'
      #Days    = 7
      Count   = 3
      #And     = $true
      #Or    = $true
      WhatIf  = $true
      Confirm = $false
    }
    .\Clear-FilMFiles.ps1 @cmdArgs
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'And')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Or')]
[CmdLetBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'All')]
Param(
  [Parameter(Mandatory = $true)]
  [ValidateScript({
      if (-Not ($_ | Test-Path -PathType Container) )
      {
        throw 'The Path argument must be a folder. File paths are not allowed.'
      }
      return $true
    })]
  [string]
  $Path,

  [string]
  $Filter,

  [Parameter(Mandatory = $true, ParameterSetName = 'Days')]
  [Parameter(Mandatory = $true, ParameterSetName = 'DaysAndCount')]
  [Parameter(Mandatory = $true, ParameterSetName = 'DaysOrCount')]
  [int]
  $Days,

  [Parameter(Mandatory = $true, ParameterSetName = 'Count')]
  [Parameter(Mandatory = $true, ParameterSetName = 'DaysAndCount')]
  [Parameter(Mandatory = $true, ParameterSetName = 'DaysOrCount')]
  [int]
  $Count,

  [Parameter(ParameterSetName = 'DaysAndCount')]
  [switch]
  $And,

  [Parameter(ParameterSetName = 'DaysOrCount')]
  [switch]
  $Or,

  [PSCredential]
  $Credential,

  [switch]
  $SRXConfirm = $false,

  [switch]
  $SRXWhatIf = $false
)

Write-Host $PsCmdlet.ParameterSetName
$Today = Get-Date

try
{
  $FileCollParams = @{
    Path = $Path
    File = $true
  }

  if ($null -ne $Filter)
  {
    $FileCollParams.Add('Filter', $Filter)
  }

  $FileColl = Get-ChildItem @FileCollParams

  $Result = if ($null -ne $FileColl)
  {
    if ($null -ne $Days)
    {
      $FileDaysColl = ($FileColl).where{
        (($Today - ($_.LastWriteTime)).Days -GT $Days)
      }
    }
    if ($null -ne $Count)
    {
      $FileCountColl = $FileColl | Sort-Object -Property LastWriteTime | Select-Object -First $Count
    }

    Switch ($PsCmdlet.ParameterSetName)
    {
      'All'
      {
        $FilteredFileColl = $FileColl
      }
      'Days'
      {
        $FilteredFileColl = $FileDaysColl
      }
      'Count'
      {
        $FilteredFileColl = $FileCountColl
      }
      'DaysAndCount'
      {
        $FilteredFileCollParams = @{
          ReferenceObject  = $FileDaysColl
          DifferenceObject = $FileCountColl
          IncludeEqual     = $true
          ExcludeDifferent = $true
        }
        $FilteredFileColl = (Compare-Object @FilteredFileCollParams).InputObject
      }
      'DaysOrCount'
      {
        $FilteredFileColl = $FileDaysColl + $FileDaysColl | Select-Object -Unique
      }
    }

    $RemoveItemParams = @{
      Force   = $true
      Confirm = $SRXConfirm
      WhatIf  = $SRXWhatIf
    }
    if ($null -ne $AccessAccount)
    {
      $RemoveItemParams.Add('Credential', $Credential)
    }

    foreach ($FilteredFile in $FilteredFileColl)
    {
      $FilteredFile | Remove-Item @RemoveItemParams -ErrorAction Stop
      $FilteredFile.FullName
    }

  }

  if ($SRXWhatIf)
  {
    if ($SRXEnv)
    {
      if ([array]$Result.Count -gt 0)
      {
        $SRXEnv.ResultMessage = 'WhatIf: {0} removed.' -f $Result
      }
      else
      {
        $SRXEnv.ResultMessage = 'WhatIf: {0} No files removed.' -f $Result
      }
    }
    else
    {
      if ([array]$Result.Count -gt 0)
      {
        Write-Output ('WhatIf: {0} removed.' -f $Result)
      }
      else
      {
        Write-Output ('WhatIf: {0} No files removed.' -f $Result)
      }
    }
  }
  else
  {
    if ($SRXEnv)
    {
      if ([array]$Result.Count -gt 0)
      {
        $SRXEnv.ResultMessage = '{0} removed.' -f $Result
      }
      else
      {
        $SRXEnv.ResultMessage = '{0} No files removed.' -f $Result
      }
    }
    else
    {
      if ([array]$Result.Count -gt 0)
      {
        Write-Output ('{0} removed.' -f $Result)
      }
      else
      {
        Write-Output ('{0} No files removed.' -f $Result)
      }
    }
  }
}
catch
{
  throw
}
finally
{
}
