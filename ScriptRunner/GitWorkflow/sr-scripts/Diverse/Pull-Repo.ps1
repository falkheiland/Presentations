#Requires -Version 5.0
# Requires -Modules ActiveDirectory # check before execute the script

<#
    .SYNOPSIS
        Pulls a git repo and checks out a branch

        .DESCRIPTION
        Pulls a git repo and checks out a branch

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner.
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner.
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function,
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Components needed to execute the script, e.g. Requires Module ActiveDirectory

    .LINK
        Links to the sources and so on

    .Parameter Path
        Path to the Git Repo
    .Parameter Branch
        Branch to check out
#>

param( # parameter block
  [Parameter(Mandatory = $true)]
  [String]
  $Path,

  [Parameter(Mandatory = $true)]
  [String]
  $Branch
)

try
{
  Set-Location -Path $Path
  $Result = Invoke-Command -ScriptBlock {
    & git pull
    & git checkout $args[0]
  } -ArgumentList $Branch
  if ($SRXEnv)
  {
    $SRXEnv.ResultMessage = $Result
  }
  else
  {
    Write-Output $Result
  }
}
catch
{
  throw # throws error for ScriptRunner
}
finally
{
  # final todos, e.g. Disconnect server
}