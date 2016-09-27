# usage .\TightVNC.ps1


# Checks architecture to set variables
$architecture = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($architecture.AddressWidth -eq 32) {
$arc = '32bit'
}

If($architecture.AddressWidth -eq 64) {
$arc = '64bit'
}


# poplulating more variables
$ErrorActionPreference = "Stop"
$target = 'c:\temp\Payload'
$processes = 'wusa','msiexec'
$app = 'tightvnc'
$version = '2.7.10'
$file = "$app-$version-setup-$arc.msi"
$URL = "http://www.tightvnc.com/download/$version/$file"
$switches = '/q DESKTOPICON=1 ALLUSERS=1 REBOOT=ReallySuppress'
$appfolder = "C:\Program Files\$app"


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
ForEach ($remove in $app){
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
Remove-Item "$appfolder" -Recurse -Force -ErrorAction SilentlyContinue
}
Catch {
# catch? there is no catch!
}


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("C:\Windows\System32\msiexec.exe /i ""$target\$file"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Try {
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue
}
Catch {
# catch? there is no catch!
}