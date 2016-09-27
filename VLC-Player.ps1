﻿# usage .\VLC-Player.ps1


# Checks architecture to set variables
$architecture = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($architecture.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'
$arc = 'win32'
}

If($architecture.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'
$arc = 'win64'
}


# poplulating more variables
$ErrorActionPreference = "Stop"
$target = 'c:\temp\Payload'
$processes = 'wusa','msiexec','vlc'
$appremove = 'VLC'
$version = '2.1.5'
$file = "vlc-$version-$arc.exe"
$URL = "http://www.gtlib.gatech.edu/pub/videolan/vlc/$version/$arc/$file"
$switches = ' /L=1033 /S'
$appfolder = "C:\Program Files\VideoLAN"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# ends task on application
Try {
Foreach ($process in $prcoesses) {
Stop-Process -processname $process -Force -ErrorAction SilentlyContinue
}
}
Catch {
# catch? there is no catch!
}


# uninstalls previous versions
ForEach ($remove in $appremove){
If ($remove) {
Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%$remove%'" | Foreach-Object {
Write-Host "Uninstalling: $($_.Name)"
$rv = $_.Uninstall().ReturnValue 
if($rv -eq 0) {"$($_.Name) uninstalled successfully"}
}
}
} 


# removes files and folders
Try {
Remove-Item "$appfolder" -Recurse -Force
}
Catch {
# catch? there is no catch!
}


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$target\$file"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue