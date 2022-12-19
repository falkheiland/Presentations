#Requires -Version 5.0
#Requires -Modules PSSharedGoods, PSWriteHTML # check before execute the script

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

  .COMPONENT
    Requires Module PSWriteHTML

  .Parameter Property
    Properties of processes, empty for all
#>

param(
  [String[]]
  $Property
)

$DateTime = Get-Date -Format FileDateTime

#region Args
$NewHTMLArgs = @{
}

$NewHTMLTabStyleArgs = @{
  RemoveShadow = $true
}

$NewHTMLTabArgs = @{
  TextSize = 16
}

$NewHTMLSectionArgs = @{
  CanCollapse    = $true
  HeaderTextSize = 16
}

$NewHTMLPanelArgs = @{
}

$NewHTMLTableArgs = @{
  HideFooter             = $true
  AlphabetSearch         = $true
  FuzzySearch            = $true
  FuzzySearchSmartToggle = $true
  DateTimeSortingFormat  = 'DD.MM.YYYY HH:mm:ss', 'M/D/YYYY', 'YYYY-MM-DD'
  #EnableScroller         = $true
  AutoSize               = $true
  PagingLength           = 10
}

$NewHTMLTableOptionArgs = @{
  DataStore       = 'JavaScript'
  DateTimeFormat  = 'dd.MM.yyyy HH:mm:ss'
  ArrayJoin       = $true
  ArrayJoinString = ','
}
#endregion

try
{
  $ServiceColl = if ($null -ne $Property)
  {
    Get-Service | Select-Object -Property $Property
  }
  else
  {
    Get-Service | Select-Object -Property *
  }

  $GroupedServiceStartTypeColl = $ServiceColl | Group-Object -Property StartType |
    Sort-Object -Property Count -Descending | Select-Object -First 10
  $GroupedServiceStatusColl = $ServiceColl | Group-Object -Property Status |
    Sort-Object -Property Count -Descending | Select-Object -First 10
  $GroupedServiceUsernameColl = $ServiceColl | Group-Object -Property UserName |
    Sort-Object -Property Count -Descending | Select-Object -First 10

  $out = New-HTML @NewHTMLArgs -Name 'Report' {
    New-HTMLHeader {
      New-HTMLText -Text "Date of this report $DateTime" -Color Blue -Alignment right
    }
    New-HTMLMain {

      New-HTMLTabStyle @NewHTMLTabStyleArgs
      New-HTMLTableOption @NewHTMLTableOptionArgs
      New-HTMLTab @NewHTMLTabArgs -Name ('{0} Services' -f $ServiceColl.Count) -IconRegular keyboard {
        New-HTMLSection @NewHTMLSectionArgs -Name 'Table' {
          New-HTMLPanel @NewHTMLPanelArgs {
            New-HTMLTable @NewHTMLTableArgs -DataTable $ServiceColl -Title 'All Services'
          }
        }
        New-HTMLSection @NewHTMLSectionArgs -Name 'Diagram' {
          New-HTMLPanel @NewHTMLPanelArgs {
            New-HTMLChart -Title 'Grouped by StartType' {
              New-ChartToolbar -Download
              foreach ($GroupedService in $GroupedServiceStartTypeColl)
              {
                New-ChartPie -Name $GroupedService.Name -Value $GroupedService.Count
              }
            }
          }
          New-HTMLPanel @NewHTMLPanelArgs {
            New-HTMLChart -Title 'Grouped by Status' {
              New-ChartToolbar -Download
              foreach ($GroupedService in $GroupedServiceStatusColl)
              {
                New-ChartBar -Name $GroupedService.Name -Value $GroupedService.Count
              }
            }
          }
          New-HTMLPanel @NewHTMLPanelArgs {
            New-HTMLChart -Title 'Grouped by Username' {
              New-ChartToolbar -Download
              foreach ($GroupedService in $GroupedServiceUsernameColl)
              {
                New-ChartDonut -Name $GroupedService.Name -Value $GroupedService.Count
              }
            }
          }
        }
      }
    }
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