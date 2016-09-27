# usage .\WinSQL.ps1


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
$processes = 'wusa','msiexec','setup','WinSQL'
$appremove = 'WinSQL'
$URL = 'http://www.synametrics.com/files/WinSQL.zip'
$zipfile = 'WinSQL.zip'
$file = 'setup.exe'
$switches = '/s /v/qn'
$appfolder = "C:\$ProgFiles\Synametrics Technologies"
$description = 'WinSQL'
$applnkname = 'WinSQL.lnk'
$app = "Winsql.exe"
$lnklocation = "c:\Users\Public\Desktop"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$zipfile")


# unzip files to directory on target
$shell = new-object -com shell.application
 $zip = $shell.NameSpace(“$target\$zipfile”)
 foreach($item in $zip.items())
 {
 $shell.Namespace(“$target”).copyhere($item, 0x14)
 }


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


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# creates new shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$lnklocation\$applnkname")
$Shortcut.TargetPath = "$appfolder\WinSQL\$app"
$Shortcut.IconLocation = "$appfolder\WinSQL\$app"
$Shortcut.Description ="$description"
$Shortcut.WorkingDirectory ="$appfolder\WinSQL"
$Shortcut.Save()


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue