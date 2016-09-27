# usage .\TRENDnet-TU2-ET100-Ethernet2USB.ps1


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
$processes = 'wusa','msiexec','setup.exe'
$URL = 'http://downloads.trendnet.com/tu2-et100_v3/drivers_utilities/driver_tu2-et100(v3.0r)_cd_v3.21.zip'
$zipfile = 'driver_tu2-et100(v3.0r)_cd_v3.21.zip'
$file = 'setup.exe'
$answer = 'setup.iss'
$switches = "/s /f1$target\$answer"


# create folder on target
New-Item -Path "$target" -type directory -Force


# download file from HTTP
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, "$target\$zipfile")


# ends task on application
Try {
Foreach ($process in $prcoesses) {
Stop-Process -processname $process -Force -ErrorAction SilentlyContinue
}
}
Catch {
# catch? there is no catch!
}


# unzip files to directory on target
$shell = new-object -com shell.application
 $zip = $shell.NameSpace(“$target\$zipfile”)
 foreach($item in $zip.items())
 {
 $shell.Namespace(“$target”).copyhere($item, 0x14)
 }


 # creating answer file
$iss = "[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{CAAF899F-D15F-480F-AF10-22B1431A5E9F}-DlgOrder]
Dlg0={CAAF899F-D15F-480F-AF10-22B1431A5E9F}-SdWelcome-0
Count=3
Dlg1={CAAF899F-D15F-480F-AF10-22B1431A5E9F}-SdStartCopy2-0
Dlg2={CAAF899F-D15F-480F-AF10-22B1431A5E9F}-SdFinish-0
[{CAAF899F-D15F-480F-AF10-22B1431A5E9F}-SdWelcome-0]
Result=1
[{CAAF899F-D15F-480F-AF10-22B1431A5E9F}-SdStartCopy2-0]
Result=1
[Application]
Name=TU2-ET100
Version=1.00.0000
Company=
Lang=0409
[{CAAF899F-D15F-480F-AF10-22B1431A5E9F}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"
Foreach ($line in $iss) {
Write-Output "$line" | Out-File "$target\$answer" -Append -Encoding default
}
Clear-Variable line


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("""$target\CD_V3.21\Driver\Windows\$file"" $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
# $newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
# While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue