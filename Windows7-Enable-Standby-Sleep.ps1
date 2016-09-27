# usage .\Enable-Standby-Sleep.ps1


# populating variables
$target = 'c:\temp\Payload'
$hkey = 'HKEY_LOCAL_MACHINE'
$keys = 'SYSTEM\CurrentControlSet\Services\ACPI'
$name = 'Parameters'


# changes registry value to enable standby
Remove-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$keys" -Name "$name" -Force


# cleanup installation files
Remove-Item "$target" -Recurse -Force 