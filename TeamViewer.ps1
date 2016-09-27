# usage .\TeamViewer.ps1


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
$processes = 'wusa','msiexec','teamviewer*'
$URL = 'http://downloadus3.teamviewer.com/download/TeamViewer_Setup_en.exe'
$file = 'TeamViewer_Setup_en.exe'
$switches = '/S'
$appfolder = "c:\$ProgFiles\TeamViewer"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$file")


# ends task on application
Try {
Foreach ($process in $prcoesses) {
Stop-Process -processname $process -Force
}
}
Catch {
# catch? there is no catch!
}


# uninstalls previous versions
If (test-path "c:\$ProgFiles\TeamViewer") {
Try {
$versions = Split-Path "c:\$ProgFiles\TeamViewer\*" -Leaf -Resolve
Foreach ($version in $versions) {
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""c:\$ProgFiles\TeamViewer\$version\uninstall.exe"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}
}
Remove-Item $appfolder -Recurse -Force
}
Catch {
# catch? there is no catch!
}
}


# to extract files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""c:\Program Files\7-Zip\7z.exe"" e -o""c:\temp\payload"" -y ""$target\$file""")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue