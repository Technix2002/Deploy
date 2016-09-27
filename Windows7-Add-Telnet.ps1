# usage .\TelnetAdd.ps1


# to add Telnet back to Windows 7
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\Windows\System32\dism.exe /online /Enable-Feature /FeatureName:TelnetClient")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# cleanup installation files
Remove-Item "c:\temp\Payload\" -Recurse -Force