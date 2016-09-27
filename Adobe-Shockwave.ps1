# usage .\Shockwave.ps1


# Checks architecture
$query = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth


# applies variables
$URL = "http://www.adobe.com/go/adobeconnect_9_addin_win"
$download = "ac_addin_win_392.zip"
$target = "c:\temp\Payload"
$file = "setup.exe"
$switches = "/verysilent"


# create folders on target
New-Item -Path "$Payload" -type directory -Force


# download newest redistributable flash player from Adobe
$destination = "$target\$download"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($URL, $destination)


# unzip files to target directory
$shell = new-object -com shell.application
 $zip = $shell.NameSpace(“$destination”)
 foreach($item in $zip.items())
 {
 $shell.Namespace(“$target”).copyhere($item)
 }


# terminate Windows Installer
Stop-Process -processname "wusa" -Force
Stop-Process -processname "msiexec" -Force


# to install software
$newProc=([WMICLASS]"root\cimv2:win32_Process").create("$target\$file $switches")
While(Get-WmiObject Win32_Process -filter "ProcessID='$($newProc.ProcessID)'"){start-sleep -seconds 5}


# cleanup installation files
Remove-Item -Recurse -Force "c:\temp\Payload\"