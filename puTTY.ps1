# usage .\puTTY.ps1


# Checks architecture to set variables
$architecture = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($architecture.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'}

If($architecture.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'}


# poplulating more variables
$target = 'c:\temp\Payload'
$URL = 'http://the.earth.li/~sgtatham/putty/latest/x86/putty.exe'
$file = 'putty.exe'
$switches = '/q ALLUSERS=1 REBOOT=ReallySuppress'
$appfolder = "C:\$ProgFiles\puTTY"
$applnk = "puTTY.lnk"
$description = "puTTY"
$lnklocation = "c:\Users\Public\Desktop"


# removes files and folders
Remove-Item "$appfolder" -Recurse -Force -ErrorAction SilentlyContinue
Foreach ($location in $locations) {
Remove-Item "$location\$applnk" -ErrorAction SilentlyContinue}


# create folder on target
New-Item -Path $target -type directory -Force
New-Item -Path "$appfolder" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$appfolder\$file")


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# creates new shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$lnklocation\$applnk")
$Shortcut.TargetPath = "$appfolder\$file"
$Shortcut.IconLocation = "$appfolder\$file"
$shortcut.Arguments = "$arguments"
$Shortcut.Description ="$description"
$Shortcut.WorkingDirectory ="$appfolder"
$Shortcut.Save()


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue