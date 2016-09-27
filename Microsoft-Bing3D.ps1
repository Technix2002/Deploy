# usage .\Bing3D.ps1


# Checks architecture to set variables
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'}

If($query.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'}


# poplulating more variables
$appremove = 'Bing'
$URL = 'http://download.microsoft.com/download/3/B/E/3BE57995-8452-41F1-8297-DD75EF049853/Setup.exe'
$target = 'c:\temp\Payload'
$file = 'Setup.exe'
$switches = '/quiet /norestart'
$appfolder = "C:\$ProgFiles\Virtual Earth 3D"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# ends task on application
Stop-Process -processname "wusa" -Force
Stop-Process -processname "msiexec" -Force
Stop-Process -processname "setup" -Force


# uninstalls previous versions
$app = Get-WmiObject -Class Win32_Product | Where-Object ($_.Name -match "$appremove")
$app.Uninstall()


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$target\$file"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force