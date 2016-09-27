# usage .\Office-Excel-DDE-error.ps1


# populating variables
$target = 'c:\temp\Payload'
$hkey = 'HKEY_CLASSES_ROOT'
$type = 'String'

    # function ToArray
function ToArray
{
  begin
  {
    $output = @(); 
  }
  process
  {
    $output += $_; 
  }
  end
  {
    return ,$output; 
  }
}


# creates folder on target
New-Item -Path "$target" -type directory -Force


# changes registry value to fix DDE issues

Foreach ($excelsheet in $excelsheets) {
Remove-Item -Path Microsoft.PowerShell.Core\Registry::"$excelsheet\shell\Open\ddeexec" -Recurse -Force -ErrorAction SilentlyContinue

$default = Get-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$excelsheet\shell\Open\command" -Name "(Default)" -ErrorAction SilentlyContinue | Select-Object -Property "(Default)"
$default = $default.'(default)' 
$default = $default -replace "/dde$", '"%1"'
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$excelsheet\shell\Open\command" -Name "(Default)" -Type $type -Value "$default" -Force -ErrorAction SilentlyContinue

$command = "xb'BV5!!!!4!!!!MKKSkEXCELFiles>u2BeT,8X[=]9==,*)Nn] ""%1"""
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$excelsheet\shell\Open\command" -Name "command" -Type MultiString -Value "$command" -Force -ErrorAction SilentlyContinue

Clear-Variable default -ErrorAction SilentlyContinue
Clear-Variable command -ErrorAction SilentlyContinue
}


# cleanup installation files
Remove-Item "$target" -Recurse -Force 