# usage .\Disable-Standby-Sleep.ps1


# populating variables
$target = 'c:\temp\Payload'
$hkey = 'HKEY_LOCAL_MACHINE'
$keys = 'SYSTEM\CurrentControlSet\Services\ACPI'
$name = 'Parameters'
$type = 'DWORD'
$value = '112'


# changes registry value to enable standby
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$keys" -Name "$name" -Type $type -Value $value -Force


# cleanup installation files
Remove-Item "$target" -Recurse -Force 