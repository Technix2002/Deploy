# usage .\FileZilla.ps1


# Checks architecture to set variables
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'
}

If($query.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'
}


# poplulating more variables
$target = 'c:\temp\Payload'
$processes = 'wusa','msiexec'
$app = 'FileZilla'
$version = '3.9.0.6'
$arc = 'win32'
$file = "$app" + "_" + "$version" + "_" + "$arc-setup.exe"
$URL = "http://iweb.dl.sourceforge.net/project/filezilla/FileZilla_Client/$version/$file"
$switches = '/S'
$appfolder = "C:\$ProgFiles\FileZilla"
$shortcut = "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\FileZilla FTP Client\FileZilla.lnk"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# ends task on application
Foreach ($process in $prcoesses) {
Stop-Process -processname $process -Force -ErrorAction SilentlyContinue
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
Remove-Item "$appfolder" -Recurse -Force -ErrorAction SilentlyContinue


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# copies shortcut to all user's Desktop
Copy-Item -Path $shortcut -Destination "c:\Users\Public\Desktop" -Force -ErrorAction SilentlyContinue


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue