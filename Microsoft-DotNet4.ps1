# usage .\Microsoft-DotNet4.ps1


# Checks architecture to set variables
$architecture = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($architecture.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'}

If($architecture.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'}


# poplulating more variables
$ErrorActionPreference = "Stop"
$target = 'c:\temp\Payload'
$processes = 'wusa','msiexec'
$URL = 'http://download.microsoft.com/download/5/6/2/562A10F9-C9F4-4313-A044-9C94E0A8FAC8/dotNetFx40_Client_x86_x64.exe'
$URL2 = 'http://download.microsoft.com/download/3/3/9/3396A3CA-BFE8-4C9B-83D3-CADAE72C17BE/NDP40-KB2600211-x86-x64.exe'
$file = 'dotNetFx40_Client_x86_x64.exe'
$file2 = 'NDP40-KB2600211-x86-x64.exe'
$switches = '/q /norestart'


# create folder on target
New-Item -Path "$target" -type directory -Force


# ends task on application
Try {
Foreach ($process in $prcoesses) {
Stop-Process -processname $process -Force -ErrorAction SilentlyContinue
}
}
Catch {
# catch? there is no catch!
}


# checks for .Net 4.0
$DotNet = [environment]::Version
If($DotNet.Major -match "4") {write-host Found .Net 4} 
else {
$wc = New-Object System.Net.WebClient
$wc.DownloadFile("$URL", "$target\$file")
$wc.DownloadFile("$URL2", "$target\$file2")

$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 10}

$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file2 $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}
}


# cleans up installation files
Try {
Remove-Item -Path "$target" -Recurse -Force
}
Catch {
# catch? there is no catch!
}