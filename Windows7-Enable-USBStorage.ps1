# usage .\USBStorageEnable.ps1


# populating variables
$target = 'c:\temp\Payload\'
$hkey = 'HKEY_LOCAL_MACHINE'
$keys = 'SYSTEM\CurrentControlSet\Services\UsbStor'
$name = 'Start'
$type = 'DWORD'
$value = '3'
$usbstors = 'c:\Windows\Inf\usbstor.inf','c:\Windows\Inf\usbstor.PNF','c:\Windows\system32\drivers\usbstor.sys'


# changes registry value to enable hibernation
Set-ItemProperty -Path Microsoft.PowerShell.Core\Registry::"$hkey\$keys" -Name "$name" -Type $type -Value $value -Force


# take ownership of directory and/or files
Foreach ($usbstor in $usbstors) {
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\takeown.exe /f ""$usbstor""")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\takeown.exe /f ""$usbstor"" /a")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# sets permissions directory and/or files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$usbstor"" /e /c /r Everyone") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$usbstor"" /e /p SYSTEM:F") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$usbstor"" /e /p Administrators:F") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}
}


# cleanup installation files
Remove-Item "$target" -Recurse -Force 