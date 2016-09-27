# usage .\3CDaemon.ps1


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
$processes = 'wusa','msiexec'
$appremove = 'Rocket','3cdaemon'
$URL = 'http://www.firewall.cx/downloads/ftp-tftp-servers-a-clients/16-1-3cdaemon-server-a-client/file.html'
$zipfile = '3cdv2r10.zip'
$file = 'setup.exe'
$answer = 'install.iss'
$switches = "-s -f1$target\$answer"
$appfolder = "C:\$ProgFiles\3Com"


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


# creating answer file
Write-Output '[InstallShield Silent]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Version=v4.90.000' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'File=Response File' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[DlgOrder]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Dlg0=SdWelcome-0' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Count=7' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Dlg1=SdLicense-0' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Dlg2=SdAskDestPath-0' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Dlg3=SdSelectFolder-0' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Dlg4=SprintfBox-0' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Dlg5=SprintfBox-1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Dlg6=SdFinish-0' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[SdWelcome-0]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Result=1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[SdLicense-0]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Result=1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[SdAskDestPath-0]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output "szDir=C:\$ProgFiles\3Com\3CDaemon" | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Result=1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[SdSelectFolder-0]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'szFolder=3CDaemon' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Result=1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[Application]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Name=3CDaemon' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Version=2.00.00.10' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Company=3Com' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[SprintfBox-0]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Result=1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[SprintfBox-1]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Result=1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output '[SdFinish-0]' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'Result=1' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'bOpt1=0' | Out-File "$target\$answer" -Append -Encoding default
Write-Output 'bOpt2=0' | Out-File "$target\$answer" -Append -Encoding default


# to install application
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# sets permissions on application's directory and files
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("c:\windows\system32\cacls.exe ""$appfolder"" /t /e /p Users:C") #set ACLs
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 15}


# cleans up installation files
Remove-Item -Path "$target" -Recurse -Force -ErrorAction SilentlyContinue