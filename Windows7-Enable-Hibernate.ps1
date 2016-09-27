# usage .\HibernateEnable.ps1


# populating variables
$target = 'c:\temp\Payload\'
$hkey = 'HKEY_LOCAL_MACHINE'
$keys = 'SYSTEM\CurrentControlSet\Control\Power'
$name = 'HibernateEnabled'
$type = 'DWORD'
$value = '1'


# changes registry value to enable hibernation
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$keys" -Name "$name" -Type $type -Value $value -Force


# cleanup installation files
Remove-Item "$target" -Recurse -Force 