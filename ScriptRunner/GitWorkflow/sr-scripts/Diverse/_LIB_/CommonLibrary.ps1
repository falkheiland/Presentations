#Requires -Version 5.0

function Write-SRXOut
{
  <#
  .SYNOPSIS
    Creates output for use with result within Scriptrunner

  .DESCRIPTION
    Creates output for use with result within Scriptrunner.
    Makes it easier to format output in a key value format with alignment

  .Parameter Key
    Key

  .Parameter Key
    Value

  .EXAMPLE
    $out = New-Object 'System.Collections.Generic.List[System.Object]'
    $out.Add((Write-SRXOut -Key 'Name' -Value 'Value' -Separator ''))
    Foreach ( $item in $Object )
    {
      $out.Add((Write-SRXOut -Key $itm.Name -Value $itm.Value -Separator ''))
    }
    $SRXEnv.ResultMessage = $Out

  #>

  [CmdLetBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [string]
    $Key,

    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [string]
    $ValueColl,

    [string]
    $Separator = ':',

    [int]
    $LeftAlign = -15
  )

  ("{0,$LeftAlign}$Separator {1}" -f $Key, $ValueColl)

}
