# usage .\LibreOffice.ps1


# Checks architecture to set variables
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth 
If($query.AddressWidth -eq 32) {
$ProgFiles = 'Program Files'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software'}

If($query.AddressWidth -eq 64) {
$ProgFiles = 'Program Files (x86)'
$Keyvalue = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node'}


# poplulating more variables
$appremove = 'Office'
$URL = 'https://donate.libreoffice.org/home/dl/win-x86/4.1.4/en-US/LibreOffice_4.1.4_Win_x86.msi'
$target = 'c:\temp\Payload'
$file = 'LibreOffice_4.1.4_Win_x86.msi'
$switches = '/q ALLUSERS=1 REBOOT=ReallySuppress'
$appfolder = "C:\$ProgFiles\LibreOffice4"
$locations = 'c:\Users\Public\Desktop','C:\ProgramData\Microsoft\Windows\Start Menu'  
$applnk = "Libre*.lnk"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# ends task on application
Stop-Process -processname "wusa" -Force
Stop-Process -processname "msiexec" -Force


# uninstalls previous versions
$app = Get-WmiObject -Class Win32_Product | Where-Object ($_.Name -match "$appremove")
$app.Uninstall()


# removes files and folders
Remove-Item "$appfolder" -Recurse -Force
Foreach ($location in $locations) {
Remove-Item "$location\$applnk" -Recurse -Force}


# to installs application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("C:\Windows\System32\msiexec.exe /i ""$target\$file"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force