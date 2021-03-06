﻿# usage .\CitrixReceiver.ps1


# Checks architecture to set variables
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'}

If($query.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'}


# poplulating more variables
$target = 'c:\temp\Payload'
$processes = 'wusa','msiexec','citrix*'
$appremove = 'Citrix'
$URL = 'http://downloadplugins.citrix.com.edgesuite.net/Windows/CitrixReceiverWeb.exe'
$file = 'CitrixReceiverWeb.exe'
$switches = '/silent'
$appfolder = "C:\$ProgFiles\Citrix"


# create folder on target
New-Item -Path "$target" -type directory -Force -ErrorAction SilentlyContinue


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# ends task on application
Foreach ($process in $processes) {
Stop-Process -processname $process -Force -ErrorAction SilentlyContinue

}


# uninstalls previous versions
$app = Get-WmiObject -Class Win32_Product | Where-Object ($_.Name -match "$appremove")
$app.Uninstall()


# removes files and folders
Remove-Item "$appfolder" -Recurse -Force -ErrorAction SilentlyContinue


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$target\$file"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue