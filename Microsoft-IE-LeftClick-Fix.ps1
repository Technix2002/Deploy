# usage .\IE-LeftClickFix.ps1


# populating variables
$process = 'iexplore'
$target = 'c:\temp\Payload\'
$hkey = 'HKEY_LOCAL_MACHINE'

# Checks architecture to set set registry key values
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 

If($query.AddressWidth -eq 32) {
$keys = 'SOFTWARE\Microsoft\Ole'}

If($query.AddressWidth -eq 64) {
$keys = 'SOFTWARE\Wow6432Node\Microsoft\Ole'}


# stops process
Stop-Process -Processname $process -Force


# changes registry value to enable hibernation
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$keys" -Name "EnableDCOM" -Type String -Value Y -Force
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$keys" -Name "LegacyAuthenticationLevel" -Type DWORD -Value 2 -Force
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$keys" -Name "LegacyImpersonationLevel" -Type DWORD -Value 3 -Force


# deletes temporary Internet files across all profiles
remove-item "c:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*" -recurse -force
remove-item "c:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -recurse -force


# cleanup installation files
Remove-Item "$target" -Recurse -Force 